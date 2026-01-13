import 'dart:async';
import 'package:maps_toolkit/maps_toolkit.dart';

import '../models/location.dart';
import '../models/route.dart';


import '../utils/map_utils.dart';
import '../utils/routing_helper_utils.dart';

/// Result of projecting a GPS location onto the route.
class ProjectedLocationResult {
  final Location original;
  final Location projected;
  final bool isOnRoute;
  final double distanceToRoute;
  final int currentSegmentIndex;
  final int currentDirectionIndex; // Index of current RouteDirectionInfo
  final RouteDirectionInfo? currentDirection; // Current RouteDirectionInfo
  final bool arrived;
  final bool needsRecalculation;

  ProjectedLocationResult({
    required this.original,
    required this.projected,
    required this.isOnRoute,
    required this.distanceToRoute,
    required this.currentSegmentIndex,
    required this.currentDirectionIndex,
    this.currentDirection,
    required this.arrived,
    this.needsRecalculation = false,
  });
}

/// Result of calculating current segment
class _SegmentResult {
  final int directionIndex;
  final int stepIndex;

  _SegmentResult({required this.directionIndex, required this.stepIndex});
}

/// Main routing helper that manages navigation state and GPS projection.
/// Converted from OsmAnd's RoutingHelper.java
///
/// This class handles:
/// - Tracking position along a route
/// - Projecting GPS to route (snap-to-road)
/// - Detecting deviation from route
/// - Detecting wrong direction / U-turn needed
class RoutingHelper {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS (from OsmAnd)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Position tolerance in meters
  static const double posTolerance = 60.0;

  /// Multiplier for deviation threshold
  static const double posToleranceDeviationMultiplier = 1.5;

  /// Maximum GPS accuracy to accept (meters)
  static const double accuracyForRouting = 10.0;

  /// Maximum possible speed (m/s) - about Mach 1
  static const int maxPossibleSpeed = 340;

  /// Distance threshold for long-distance look-ahead (meters)
  static const double longDistanceThreshold = 250.0;

  /// Look-ahead segments for close distance
  static const int lookAheadClose = 8;

  /// Look-ahead segments for long distance
  static const int lookAheadFar = 15;

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════

  List<RouteDirectionInfo> _routeDirections = [];
  int _currentDirectionIndex = 0; // Current RouteDirectionInfo index
  int _currentStepIndex = 0; // Current step index within current direction
  Location? _lastFixedLocation;
  Location? _lastProjection;
  Location? _lastGoodRouteLocation;
  bool _isDeviatedFromRoute = false;
  bool _snapToRoad = true;
  bool _previewNextTurn = true;
  bool _isFollowingMode = false;
  int _deviateFromRouteDetected = 0;
  bool _deviceHasBearing = false;

  // Stream for emitting projected locations
  final _projectedLocationController =
      StreamController<ProjectedLocationResult>.broadcast();

  /// Stream of projected location results
  Stream<ProjectedLocationResult> get projectedLocationStream =>
      _projectedLocationController.stream;

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  List<RouteDirectionInfo> get routeDirections =>
      List.unmodifiable(_routeDirections);
  int get currentDirectionIndex => _currentDirectionIndex;
  int get currentStepIndex => _currentStepIndex;
  int get currentRouteIndex => _currentStepIndex; // For backward compatibility
  Location? get lastProjection => _lastProjection;
  Location? get lastFixedLocation => _lastFixedLocation;
  bool get isDeviatedFromRoute => _isDeviatedFromRoute;
  bool get isFollowingMode => _isFollowingMode;
  bool get hasRoute => _routeDirections.isNotEmpty && _getTotalSteps() >= 2;

  /// Get the current RouteDirectionInfo
  RouteDirectionInfo? get currentDirection {
    if (_currentDirectionIndex < _routeDirections.length) {
      return _routeDirections[_currentDirectionIndex];
    }
    return null;
  }

  /// Get the next route location from current step
  Location? get nextRouteLocation {
    final direction = currentDirection;
    if (direction != null && _currentStepIndex < direction.steps.length) {
      final step = direction.steps[_currentStepIndex];
      return Location.withCoords('route', step.latitude, step.longitude);
    }
    return null;
  }

  /// Get remaining distance to destination in meters
  double get remainingDistance {
    if (!hasRoute || _lastProjection == null) return 0;

    double distance = 0;

    // Distance from current position to next step
    final nextStep = _getStepAt(_currentDirectionIndex, _currentStepIndex);
    if (nextStep != null) {
      distance += _lastProjection!.distanceTo(
        Location.withCoords('route', nextStep.latitude, nextStep.longitude),
      );
    }

    // Sum remaining segment distances
    for (
      int dirIdx = _currentDirectionIndex;
      dirIdx < _routeDirections.length;
      dirIdx++
    ) {
      final direction = _routeDirections[dirIdx];
      int startStepIdx = (dirIdx == _currentDirectionIndex)
          ? _currentStepIndex
          : 0;

      for (
        int stepIdx = startStepIdx;
        stepIdx < direction.steps.length - 1;
        stepIdx++
      ) {
        final step1 = direction.steps[stepIdx];
        final step2 = direction.steps[stepIdx + 1];
        distance += MapUtils.getDistance(
          step1.latitude,
          step1.longitude,
          step2.latitude,
          step2.longitude,
        );
      }

      // Add distance to next direction's first step if exists
      if (dirIdx < _routeDirections.length - 1 && direction.steps.isNotEmpty) {
        final lastStep = direction.steps.last;
        final nextDirection = _routeDirections[dirIdx + 1];
        if (nextDirection.steps.isNotEmpty) {
          final firstStep = nextDirection.steps.first;
          distance += MapUtils.getDistance(
            lastStep.latitude,
            lastStep.longitude,
            firstStep.latitude,
            firstStep.longitude,
          );
        }
      }
    }

    return distance;
  }

  /// Get total number of steps across all directions
  int _getTotalSteps() {
    return _routeDirections.fold(0, (sum, dir) => sum + dir.steps.length);
  }

  /// Get step at given direction and step indices
  LatLng? _getStepAt(int directionIndex, int stepIndex) {
    if (directionIndex < 0 || directionIndex >= _routeDirections.length) {
      return null;
    }
    final direction = _routeDirections[directionIndex];
    if (stepIndex < 0 || stepIndex >= direction.steps.length) {
      return null;
    }
    return direction.steps[stepIndex];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Set the route to follow using RouteDirectionInfo list
  void setRoute(List<RouteDirectionInfo> directions) {
    _routeDirections = List.from(directions);
    _currentDirectionIndex = 0;
    _currentStepIndex = 0;
    _lastProjection = null;
    _lastFixedLocation = null;
    _lastGoodRouteLocation = null;
    _isDeviatedFromRoute = false;
    _deviateFromRouteDetected = 0;
  }

  /// Set route from Route object (uses directions field)
  void setRouteFromRoute(Route route) {
    if (route.directions.isNotEmpty) {
      setRoute(route.directions);
    } else if (route.locations.isNotEmpty) {
      // Fallback: convert locations to a single direction
      final steps = route.locations.map((loc) => loc.toLatLng()).toList();
      setRoute([RouteDirectionInfo(turnType: TurnType.straight, steps: steps)]);
    }
  }

  /// Set route from list of LatLng coordinates (for backward compatibility)
  /// Creates a single RouteDirectionInfo with all points as steps
  void setRouteFromLatLng(List<LatLng> points) {
    setRoute([
      RouteDirectionInfo(turnType: TurnType.straight, steps: List.from(points)),
    ]);
  }

  /// Set route from list of Location (for backward compatibility)
  /// Creates a single RouteDirectionInfo with all locations as steps
  void setRouteFromLocations(List<Location> locations) {
    final steps = locations.map((loc) => loc.toLatLng()).toList();
    setRoute([RouteDirectionInfo(turnType: TurnType.straight, steps: steps)]);
  }

  /// Enable/disable snap to road
  void setSnapToRoad(bool enabled) {
    _snapToRoad = enabled;
  }

  /// Enable/disable preview of next turn bearing
  void setPreviewNextTurn(bool enabled) {
    _previewNextTurn = enabled;
  }

  /// Enable/disable following mode
  void setFollowingMode(bool enabled) {
    _isFollowingMode = enabled;
  }

  /// Clear the current route
  void clearRoute() {
    _routeDirections.clear();
    _currentDirectionIndex = 0;
    _currentStepIndex = 0;
    _lastProjection = null;
    _lastFixedLocation = null;
    _lastGoodRouteLocation = null;
    _isDeviatedFromRoute = false;
    _deviateFromRouteDetected = 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN ENTRY POINT: setCurrentLocation
  // This is the core function that processes each GPS update
  // ═══════════════════════════════════════════════════════════════════════════

  /// Process a new GPS location and return the projected (snapped) location.
  ///
  /// This is the main entry point called for each GPS update during navigation.
  /// It will:
  /// 1. Update the current position on the route
  /// 2. Project the GPS point onto the route segment
  /// 3. Smooth the bearing
  /// 4. Detect if deviated from route
  /// 5. Emit the result via stream
  Location? setCurrentLocation(
    Location currentLocation, {
    bool returnUpdatedLocation = true,
  }) {
    // No route? Just return the location as-is
    if (!hasRoute) {
      return currentLocation;
    }

    // Calculate position tolerance based on GPS accuracy
    double accuracy = currentLocation.hasAccuracy()
        ? currentLocation.accuracy
        : 0;
    double currentPosTolerance = _getPosTolerance(accuracy);

    Location locationProjection = currentLocation;
    _isDeviatedFromRoute = false;
    double distOrth = 0;
    bool needsRecalculation = false;

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 1: Find current route segment (direction and step)
    // ─────────────────────────────────────────────────────────────────────────
    final segmentResult = _calculateCurrentSegment(
      currentLocation,
      currentPosTolerance,
    );
    _currentDirectionIndex = segmentResult.directionIndex;
    _currentStepIndex = segmentResult.stepIndex;

    // Check if arrived at destination
    final lastDirection = _routeDirections.isNotEmpty
        ? _routeDirections.last
        : null;
    if (lastDirection != null &&
        _currentDirectionIndex == _routeDirections.length - 1 &&
        _currentStepIndex >= lastDirection.steps.length - 1) {
      final lastStep = lastDirection.steps.last;
      final lastPoint = Location.withCoords(
        'route',
        lastStep.latitude,
        lastStep.longitude,
      );
      double distToEnd = currentLocation.distanceTo(lastPoint);

      if (distToEnd < currentPosTolerance) {
        // Arrived!
        _projectedLocationController.add(
          ProjectedLocationResult(
            original: currentLocation,
            projected: lastPoint,
            isOnRoute: true,
            distanceToRoute: 0,
            currentSegmentIndex: _currentStepIndex,
            currentDirectionIndex: _currentDirectionIndex,
            currentDirection: lastDirection,
            arrived: true,
          ),
        );
        return null; // Signal arrival
      }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 2: Calculate deviation from route
    // ─────────────────────────────────────────────────────────────────────────
    final currentStep = _getStepAt(_currentDirectionIndex, _currentStepIndex);
    final prevStep = _getPreviousStep(
      _currentDirectionIndex,
      _currentStepIndex,
    );

    if (currentStep == null) {
      return currentLocation;
    }

    if (prevStep == null) {
      // First step - use direct distance
      distOrth = currentLocation.distanceTo(
        Location.withCoords(
          'route',
          currentStep.latitude,
          currentStep.longitude,
        ),
      );
    } else {
      // Calculate orthogonal distance to segment
      distOrth = MapUtils.getOrthogonalDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        prevStep.latitude,
        prevStep.longitude,
        currentStep.latitude,
        currentStep.longitude,
      );
    }

    // Check if deviated from route
    double allowableDeviation =
        currentPosTolerance * posToleranceDeviationMultiplier;
    if (distOrth > allowableDeviation * 10) {
      _isDeviatedFromRoute = true;
      needsRecalculation = true;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 3: Check wrong movement direction
    // ─────────────────────────────────────────────────────────────────────────
    Location? prevRouteLocation = prevStep != null
        ? Location.withCoords('route', prevStep.latitude, prevStep.longitude)
        : null;
    Location currentRouteLocation = Location.withCoords(
      'route',
      currentStep.latitude,
      currentStep.longitude,
    );

    bool wrongDirection = RoutingHelperUtils.checkWrongMovementDirection(
      currentLocation,
      prevRouteLocation,
      currentRouteLocation,
    );

    if (wrongDirection && distOrth > allowableDeviation) {
      _isDeviatedFromRoute = true;
      needsRecalculation = true;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 4: Check for U-turn needed
    // ─────────────────────────────────────────────────────────────────────────
    if (currentLocation.hasBearing()) {
      bool uTurnNeeded = RoutingHelperUtils.identifyUTurnIsNeeded(
        currentLocation,
        currentRouteLocation,
        currentPosTolerance,
      );

      if (uTurnNeeded) {
        int now = DateTime.now().millisecondsSinceEpoch;
        if (_deviateFromRouteDetected == 0) {
          _deviateFromRouteDetected = now;
        } else if (now - _deviateFromRouteDetected > 10000) {
          // U-turn detected for more than 10 seconds
          _isDeviatedFromRoute = true;
        }
      } else {
        _deviateFromRouteDetected = 0;
      }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 5: Project GPS onto route and smooth bearing
    // ─────────────────────────────────────────────────────────────────────────
    if (prevStep != null && !_isDeviatedFromRoute) {
      Location previousRouteLocation = Location.withCoords(
        'route',
        prevStep.latitude,
        prevStep.longitude,
      );

      // Project GPS onto route segment
      locationProjection = RoutingHelperUtils.getProject(
        currentLocation,
        previousRouteLocation,
        currentRouteLocation,
      );

      // Smooth bearing if snap-to-road enabled
      if (_snapToRoad) {
        final nextStep = _getNextStep(
          _currentDirectionIndex,
          _currentStepIndex,
        );
        if (nextStep != null) {
          Location nextRouteLocation = Location.withCoords(
            'route',
            nextStep.latitude,
            nextStep.longitude,
          );
          double maxDist = _getMaxAllowedProjectDist(currentRouteLocation);

          RoutingHelperUtils.approximateBearingIfNeeded(
            projection: locationProjection,
            location: currentLocation,
            previousRouteLocation: previousRouteLocation,
            currentRouteLocation: currentRouteLocation,
            nextRouteLocation: nextRouteLocation,
            maxAllowedProjectDist: maxDist,
            previewNextTurn: _previewNextTurn,
          );
        }
      }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 6: Store state and emit result
    // ─────────────────────────────────────────────────────────────────────────
    _lastFixedLocation = currentLocation;
    _lastProjection = locationProjection;

    if (!_isDeviatedFromRoute) {
      _lastGoodRouteLocation = currentLocation;
    }

    // Get current direction info
    final currentDirection = _currentDirectionIndex < _routeDirections.length
        ? _routeDirections[_currentDirectionIndex]
        : null;

    // Emit result via stream
    _projectedLocationController.add(
      ProjectedLocationResult(
        original: currentLocation,
        projected: locationProjection,
        isOnRoute: !_isDeviatedFromRoute,
        distanceToRoute: distOrth,
        currentSegmentIndex: _currentStepIndex,
        currentDirectionIndex: _currentDirectionIndex,
        currentDirection: currentDirection,
        arrived: false,
        needsRecalculation: needsRecalculation,
      ),
    );

    // Decide which location to return
    double projectDist = currentPosTolerance;
    if (returnUpdatedLocation &&
        currentLocation.distanceTo(locationProjection) < projectDist) {
      return locationProjection; // Return snapped location
    } else {
      return currentLocation; // Return original GPS
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate position tolerance based on GPS accuracy
  double _getPosTolerance(double accuracy) {
    return posTolerance + accuracy;
  }

  /// Get maximum allowed projection distance
  double _getMaxAllowedProjectDist(Location location) {
    double accuracy = location.hasAccuracy() ? location.accuracy : 0;
    double tolerance = _getPosTolerance(accuracy);
    // For fast-moving vehicles, use full tolerance; otherwise half
    return tolerance;
  }

  /// Calculate which segment of the route we're currently on.
  /// This is the core route-following algorithm that works with directions and steps.
  _SegmentResult _calculateCurrentSegment(
    Location currentLocation,
    double posTolerance,
  ) {
    int currentDirIdx = _currentDirectionIndex;
    int currentStepIdx = _currentStepIndex;

    // Ensure we have valid indices
    if (currentDirIdx >= _routeDirections.length) {
      currentDirIdx = 0;
      currentStepIdx = 0;
    } else if (currentDirIdx < 0) {
      currentDirIdx = 0;
      currentStepIdx = 0;
    } else {
      final direction = _routeDirections[currentDirIdx];
      if (currentStepIdx >= direction.steps.length) {
        currentStepIdx = direction.steps.length > 0
            ? direction.steps.length - 1
            : 0;
      } else if (currentStepIdx < 0) {
        currentStepIdx = 0;
      }
    }

    int maxIterations = 20; // Prevent infinite loops
    int iterations = 0;

    while (iterations < maxIterations) {
      iterations++;

      // Calculate distance to current segment
      double dist = _calculateDistanceToSegment(
        currentLocation,
        currentDirIdx,
        currentStepIdx,
      );

      // Determine look-ahead distance based on how far we are
      bool longDistance = dist >= longDistanceThreshold;
      int lookAhead = longDistance ? lookAheadFar : lookAheadClose;

      // Find segment with minimum distance
      final bestSegment = _lookAheadFindMinDistance(
        currentLocation,
        currentDirIdx,
        currentStepIdx,
        lookAhead,
      );

      double newDist = _calculateDistanceToSegment(
        currentLocation,
        bestSegment.directionIndex,
        bestSegment.stepIndex,
      );

      // Decide whether to advance to new segment
      bool shouldAdvance = false;

      if (newDist < dist) {
        shouldAdvance = true;
      }

      if (longDistance) {
        // Far from route - advance if new segment is closer
        shouldAdvance = newDist < dist;
      } else if (newDist < dist || newDist < posTolerance / 8) {
        if (dist > posTolerance) {
          shouldAdvance = true;
        } else if (currentLocation.hasBearing()) {
          // Use bearing to decide
          if (!_deviceHasBearing) {
            _deviceHasBearing = true;
          }

          final currentStep = _getStepAt(currentDirIdx, currentStepIdx);
          final bestStep = _getStepAt(
            bestSegment.directionIndex,
            bestSegment.stepIndex,
          );
          final bestNextStep = _getNextStep(
            bestSegment.directionIndex,
            bestSegment.stepIndex,
          );

          if (currentStep != null && bestStep != null) {
            Location currentStepLoc = Location.withCoords(
              'route',
              currentStep.latitude,
              currentStep.longitude,
            );
            Location bestStepLoc = Location.withCoords(
              'route',
              bestStep.latitude,
              bestStep.longitude,
            );

            double bearingToRoute = currentLocation.bearingTo(currentStepLoc);
            Location bestNextStepLoc = bestNextStep != null
                ? Location.withCoords(
                    'route',
                    bestNextStep.latitude,
                    bestNextStep.longitude,
                  )
                : bestStepLoc;
            double bearingRouteNext = bestStepLoc.bearingTo(bestNextStepLoc);
            double bearingMotion = currentLocation.bearing;

            double diff = MapUtils.degreesDiff(
              bearingMotion,
              bearingToRoute,
            ).abs();
            double diffToNext = MapUtils.degreesDiff(
              bearingMotion,
              bearingRouteNext,
            ).abs();

            if (diff > diffToNext) {
              shouldAdvance = true;
            }
          }
        }
      }

      if (shouldAdvance &&
          (bestSegment.directionIndex > currentDirIdx ||
              (bestSegment.directionIndex == currentDirIdx &&
                  bestSegment.stepIndex > currentStepIdx))) {
        currentDirIdx = bestSegment.directionIndex;
        currentStepIdx = bestSegment.stepIndex;
      } else {
        break;
      }
    }

    return _SegmentResult(
      directionIndex: currentDirIdx,
      stepIndex: currentStepIdx,
    );
  }

  /// Calculate distance from location to a specific segment
  double _calculateDistanceToSegment(
    Location currentLocation,
    int directionIndex,
    int stepIndex,
  ) {
    final step = _getStepAt(directionIndex, stepIndex);
    if (step == null) return double.infinity;

    final prevStep = _getPreviousStep(directionIndex, stepIndex);
    if (prevStep == null) {
      // First step - use direct distance
      return currentLocation.distanceTo(
        Location.withCoords('route', step.latitude, step.longitude),
      );
    } else {
      // Calculate orthogonal distance to segment
      return MapUtils.getOrthogonalDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        prevStep.latitude,
        prevStep.longitude,
        step.latitude,
        step.longitude,
      );
    }
  }

  /// Look ahead to find segment with minimum distance
  _SegmentResult _lookAheadFindMinDistance(
    Location currentLocation,
    int startDirIdx,
    int startStepIdx,
    int maxSegments,
  ) {
    double minDist = double.infinity;
    int bestDirIdx = startDirIdx;
    int bestStepIdx = startStepIdx;

    int segmentsChecked = 0;
    int dirIdx = startDirIdx;
    int stepIdx = startStepIdx;

    while (segmentsChecked < maxSegments && dirIdx < _routeDirections.length) {
      final direction = _routeDirections[dirIdx];

      // Check segments in current direction
      while (stepIdx < direction.steps.length - 1 &&
          segmentsChecked < maxSegments) {
        double dist = _calculateDistanceToSegment(
          currentLocation,
          dirIdx,
          stepIdx,
        );

        if (dist < minDist) {
          minDist = dist;
          bestDirIdx = dirIdx;
          bestStepIdx = stepIdx;
        }

        stepIdx++;
        segmentsChecked++;
      }

      // Move to next direction
      if (stepIdx >= direction.steps.length - 1) {
        dirIdx++;
        stepIdx = 0;
      }
    }

    return _SegmentResult(directionIndex: bestDirIdx, stepIndex: bestStepIdx);
  }

  /// Get previous step (can be from previous direction)
  LatLng? _getPreviousStep(int directionIndex, int stepIndex) {
    if (stepIndex > 0) {
      // Previous step in same direction
      return _getStepAt(directionIndex, stepIndex - 1);
    } else if (directionIndex > 0) {
      // Last step of previous direction
      final prevDirection = _routeDirections[directionIndex - 1];
      if (prevDirection.steps.isNotEmpty) {
        return prevDirection.steps.last;
      }
    }
    return null;
  }

  /// Get next step (can be from next direction)
  LatLng? _getNextStep(int directionIndex, int stepIndex) {
    if (directionIndex < _routeDirections.length) {
      final direction = _routeDirections[directionIndex];
      if (stepIndex + 1 < direction.steps.length) {
        // Next step in same direction
        return direction.steps[stepIndex + 1];
      } else if (directionIndex + 1 < _routeDirections.length) {
        // First step of next direction
        final nextDirection = _routeDirections[directionIndex + 1];
        if (nextDirection.steps.isNotEmpty) {
          return nextDirection.steps.first;
        }
      }
    }
    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Dispose of resources
  void dispose() {
    _projectedLocationController.close();
  }
}
