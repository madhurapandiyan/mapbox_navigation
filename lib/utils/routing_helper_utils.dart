import 'dart:math';
import 'package:maps_toolkit/maps_toolkit.dart';

import '../models/location.dart';


import 'map_utils.dart';

/// Utility class for routing calculations and snap-to-road functionality.
/// Converted from OsmAnd's RoutingHelperUtils.java
class RoutingHelperUtils {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const int cacheRadius = 100000;
  static const int maxBearingDeviation = 45;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROJECTION (SNAP TO ROAD)
  // Core function to project GPS location onto route segment
  // ═══════════════════════════════════════════════════════════════════════════

  /// Projects the current GPS location onto the route segment [from → to].
  /// Returns a new Location with the projected coordinates.
  /// 
  /// This is the main "snap to road" function during navigation.
  static Location getProject(Location loc, Location from, Location to) {
    final projection = MapUtils.getProjection(
      loc.latitude, loc.longitude,
      from.latitude, from.longitude,
      to.latitude, to.longitude,
    );
    
    final result = Location.from(loc);
    result.latitude = projection.latitude;
    result.longitude = projection.longitude;
    result.provider = 'projected';
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BEARING APPROXIMATION
  // Smooths the bearing to follow route direction
  // ═══════════════════════════════════════════════════════════════════════════

  /// Approximates and smooths the bearing of the projected location
  /// based on the route geometry.
  /// 
  /// This makes the navigation arrow smoothly follow the road direction
  /// instead of jumping around due to GPS noise.
  /// 
  /// Parameters:
  /// - [projection]: The projected (snapped) location
  /// - [location]: The raw GPS location
  /// - [previousRouteLocation]: The previous point on the route segment
  /// - [currentRouteLocation]: The current point on the route segment
  /// - [nextRouteLocation]: The next point on the route
  /// - [maxAllowedProjectDist]: Maximum distance for projection to apply
  /// - [previewNextTurn]: Whether to blend bearing toward next segment
  static void approximateBearingIfNeeded({
    required Location projection,
    required Location location,
    required Location previousRouteLocation,
    required Location currentRouteLocation,
    required Location nextRouteLocation,
    required double maxAllowedProjectDist,
    bool previewNextTurn = true,
  }) {
    // Check if close enough to route to apply smoothing
    double dist = location.distanceTo(projection);
    if (dist >= maxAllowedProjectDist) {
      return; // Too far from route, don't smooth
    }

    // Calculate position along current segment (0.0 to 1.0)
    double projectionOffsetN = MapUtils.getProjectionCoeff(
      location.latitude, location.longitude,
      previousRouteLocation.latitude, previousRouteLocation.longitude,
      currentRouteLocation.latitude, currentRouteLocation.longitude,
    );

    // Get bearing of current segment
    double currentSegmentBearing = MapUtils.normalizeDegrees360(
      previousRouteLocation.bearingTo(currentRouteLocation),
    );

    double approximatedBearing = currentSegmentBearing;

    // If preview next turn enabled, blend toward next segment
    if (previewNextTurn) {
      // Use quadratic easing for smoother transition
      double offset = projectionOffsetN * projectionOffsetN;
      double nextSegmentBearing = MapUtils.normalizeDegrees360(
        currentRouteLocation.bearingTo(nextRouteLocation),
      );
      double segmentsBearingDelta = MapUtils.unifyRotationDiff(
        currentSegmentBearing,
        nextSegmentBearing,
      ) * offset;
      approximatedBearing = MapUtils.normalizeDegrees360(
        currentSegmentBearing + segmentsBearingDelta,
      );
    }

    // Validate against GPS bearing (avoid large jumps)
    bool setApproximated = true;
    if (location.hasBearing() && dist >= maxAllowedProjectDist / 2) {
      double rotationDiff = MapUtils.unifyRotationDiff(
        location.bearing,
        approximatedBearing,
      );
      setApproximated = rotationDiff.abs() < maxBearingDeviation;
    }

    // Apply smoothed bearing to projection
    if (setApproximated) {
      projection.bearing = approximatedBearing;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORTHOGONAL DISTANCE
  // Calculate perpendicular distance from location to route segment
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate the perpendicular distance from location to route segment.
  static double getOrthogonalDistance(Location loc, Location from, Location to) {
    return MapUtils.getOrthogonalDistance(
      loc.latitude, loc.longitude,
      from.latitude, from.longitude,
      to.latitude, to.longitude,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOOK-AHEAD SEGMENT FINDING
  // Find the closest route segment by searching ahead
  // ═══════════════════════════════════════════════════════════════════════════

  /// Finds the route segment with minimum orthogonal distance to the GPS location.
  /// Searches ahead from [currentRoute] for [iterations] segments.
  /// 
  /// This helps handle cases where GPS jumps or the user is between segments.
  static int lookAheadFindMinOrthogonalDistance(
    Location currentLocation,
    List<Location> routeNodes,
    int currentRoute,
    int iterations,
  ) {
    double minDist = double.infinity;
    int bestIndex = currentRoute;
    int searchIndex = currentRoute;
    int remaining = iterations;

    while (remaining > 0 && searchIndex + 1 < routeNodes.length) {
      double newDist = getOrthogonalDistance(
        currentLocation,
        routeNodes[searchIndex],
        routeNodes[searchIndex + 1],
      );
      
      if (newDist < minDist) {
        minDist = newDist;
        bestIndex = searchIndex;
      }
      
      searchIndex++;
      remaining--;
    }

    return bestIndex;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WRONG DIRECTION DETECTION
  // Detect if user is moving in the wrong direction
  // ═══════════════════════════════════════════════════════════════════════════

  /// Checks if the user is moving in the wrong direction.
  /// 
  /// Wrong movement direction is considered when the difference between
  /// current location bearing and bearing to next route point is more than 90°.
  static bool checkWrongMovementDirection(
    Location currentLocation,
    Location? prevRouteLocation,
    Location nextRouteLocation,
  ) {
    // Can't determine without bearing
    if (!currentLocation.hasBearing()) {
      return false;
    }

    const double assumeAsInvalidBearing = 90.0; // Special case for emulator
    double bearingMotion = currentLocation.bearing;
    
    if (bearingMotion == assumeAsInvalidBearing) {
      return false;
    }

    double bearingToRoute;
    if (prevRouteLocation != null) {
      bearingToRoute = prevRouteLocation.bearingTo(nextRouteLocation);
    } else {
      bearingToRoute = currentLocation.bearingTo(nextRouteLocation);
    }

    double diff = MapUtils.degreesDiff(bearingMotion, bearingToRoute);
    return diff.abs() > 90;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // U-TURN DETECTION
  // Detect if a U-turn is needed
  // ═══════════════════════════════════════════════════════════════════════════

  /// Checks if a U-turn is likely needed.
  /// 
  /// A U-turn is indicated when the bearing difference is more than 135°
  /// and the user is far enough from the route point.
  static bool identifyUTurnIsNeeded(
    Location currentLocation,
    Location nextRoutePosition,
    double posTolerance,
  ) {
    if (!currentLocation.hasBearing()) {
      return false;
    }

    double bearingMotion = currentLocation.bearing;
    double bearingToRoute = currentLocation.bearingTo(nextRoutePosition);
    double diff = MapUtils.degreesDiff(bearingMotion, bearingToRoute);

    if (diff.abs() > 135) {
      double distance = currentLocation.distanceTo(nextRoutePosition);
      if (distance > posTolerance) {
        return true;
      }
    }

    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATION PREDICTION
  // Predict future locations based on speed and route
  // ═══════════════════════════════════════════════════════════════════════════

  /// Predicts future locations along the route based on current speed.
  /// 
  /// Useful for anticipating turns and providing early guidance.
  static List<Location> predictLocations(
    Location previousLocation,
    Location currentLocation,
    double timeInSeconds,
    List<Location> routeLocations,
    int currentRouteIndex,
    int interpolationPercent,
  ) {
    double speedPrev = previousLocation.hasSpeed() ? previousLocation.speed : 0;
    double speedNew = currentLocation.hasSpeed() ? currentLocation.speed : 0;
    double avgSpeed = (speedPrev + speedNew) / 2.0;
    double remainingDistance = avgSpeed * timeInSeconds * (interpolationPercent / 100.0);

    List<Location> predictedLocations = [];
    int routeIndex = currentRouteIndex + 1;

    for (int i = routeIndex; i < routeLocations.length - 1; i++) {
      Location pointA;
      Location pointB;

      if (i == routeIndex) {
        pointA = currentLocation;
        pointB = routeLocations[i];
      } else {
        pointA = routeLocations[i];
        pointB = routeLocations[i + 1];
      }

      double segmentDistance = pointA.distanceTo(pointB);

      if (remainingDistance <= segmentDistance) {
        // Interpolate within this segment
        double fraction = remainingDistance / segmentDistance;
        LatLng interpolated = MapUtils.interpolate(
          pointA.toLatLng(),
          pointB.toLatLng(),
          fraction,
        );
        
        Location predictedPoint = _buildPredictedLocation(
          currentLocation,
          pointA,
          pointB,
        );
        predictedPoint.latitude = interpolated.latitude;
        predictedPoint.longitude = interpolated.longitude;
        predictedLocations.add(predictedPoint);
        break;
      } else {
        predictedLocations.add(_buildPredictedLocation(
          currentLocation,
          pointA,
          pointB,
        ));
        remainingDistance -= segmentDistance;
      }
    }

    // If no predictions made, use last route location
    if (predictedLocations.isEmpty && routeLocations.isNotEmpty) {
      Location lastRouteLocation = routeLocations.last;
      predictedLocations.add(_buildPredictedLocation(
        currentLocation,
        currentLocation,
        lastRouteLocation,
      ));
    }

    return predictedLocations;
  }

  /// Build a predicted location with bearing toward next point
  static Location _buildPredictedLocation(
    Location currentLocation,
    Location pointA,
    Location pointB,
  ) {
    Location predictedPoint = Location.from(currentLocation);
    predictedPoint.provider = 'predicted';
    predictedPoint.latitude = pointB.latitude;
    predictedPoint.longitude = pointB.longitude;
    predictedPoint.bearing = pointA.bearingTo(pointB);
    return predictedPoint;
  }
}

