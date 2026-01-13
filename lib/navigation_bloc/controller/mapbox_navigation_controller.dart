import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_navigation/models/location.dart';
import 'package:mapbox_navigation/models/route.dart';
import 'package:mapbox_navigation/service/location_service.dart';
import 'package:mapbox_navigation/service/routing_helper.dart';
import 'package:mapbox_navigation/service/routing_service_factory.dart';
import 'package:mapbox_navigation/service/routing_settings_service.dart';
import 'package:maps_toolkit/maps_toolkit.dart';


class MapBoxNavigationController {
  MapBoxNavigationController();

  // ═══════════════════════════════════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════════════════════════════════

  final LocationService _locationService = LocationService();
  final RoutingHelper _routingHelper = RoutingHelper();
  final RoutingSettingsService _routingSettings = RoutingSettingsService();

  // Stream controllers
  final _stateController = StreamController<NavigationState>.broadcast();
  final _navigationInfoController =
      StreamController<NavigationInfo>.broadcast();
  final _voiceInstructionController = StreamController<String>.broadcast();

  /// Stream of navigation state changes
  Stream<NavigationState> get stateStream => _stateController.stream;

  /// Stream of navigation info updates
  Stream<NavigationInfo> get navigationInfoStream =>
      _navigationInfoController.stream;

  /// Stream of voice instruction texts
  Stream<String> get voiceInstructionStream =>
      _voiceInstructionController.stream;

  Route? _route;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _projectionSubscription;
  MapBoxPosition? _destination;
  MapBoxPosition? _origin;
  NavigationState _state = NavigationState.idle;

  Set<String> fiftyMeterAlert = {};
  Set<String> twentyMeterAlert = {};

  /// Start navigation from current location to destination
  Future<Route?> startNavigation(
    Position origin,
    Position destination, {
    List<LatLng>? viaPoints,
    Route? preCalculatedRoute,
  }) async {
    _origin = origin.toMapBoxPosition();
    _destination = destination.toMapBoxPosition();
    _updateState(NavigationState.calculating);

    Route? route;

    if (preCalculatedRoute != null) {
      route = preCalculatedRoute;
    } else {
      // Fetch route using selected routing provider
      try {
        await _routingSettings.initialize();
        final provider = await _routingSettings.getRoutingProvider();
        final googleApiKey = await _routingSettings.getGoogleApiKey();
        final mapboxToken = await _routingSettings.getMapboxAccessToken();

        // Create routing service
        final routingService = RoutingServiceFactory.createService(
          provider: provider,
          googleApiKey: googleApiKey,
          mapboxAccessToken: mapboxToken,
        );

        // Build waypoints list
        List<LatLng> waypoints = [];
        if (viaPoints != null) {
          waypoints.addAll(viaPoints);
        }

        // Fetch route from API
        route = await RoutingServiceFactory.getRoute(
          service: routingService,
          origin: origin.toLatLng(),
          destination: destination.toLatLng(),
          waypoints: waypoints.isNotEmpty ? waypoints : null,
        );

        // Fallback to simple route if API call fails
        if (route == null || route.isEmpty) {
          print('Route API call failed, using fallback route');
          List<LatLng> fallbackWaypoints = [origin.toLatLng()];
          if (viaPoints != null) {
            fallbackWaypoints.addAll(viaPoints);
          }
          fallbackWaypoints.add(destination.toLatLng());
          route = Route.fromLatLngs(fallbackWaypoints);
        }
      } catch (e) {
        print('Error fetching route: $e');
        // Fallback to simple route
        List<LatLng> fallbackWaypoints = [origin.toLatLng()];
        if (viaPoints != null) {
          fallbackWaypoints.addAll(viaPoints);
        }
        fallbackWaypoints.add(destination.toLatLng());
        route = Route.fromLatLngs(fallbackWaypoints);
      }
    }

    _route = route;
    _routingHelper.setRouteFromRoute(route);
    fiftyMeterAlert.clear();
    twentyMeterAlert.clear();
    _updateState(NavigationState.navigating);

    // Start listening to location updates
    _setupLocationListener();

    return _route;
  }

  void _onLocationUpdate(Location location) {
    // Process location through routing helper
    _routingHelper.setCurrentLocation(location);
  }

  void _onProjectionResult(ProjectedLocationResult result) {
    if (result.arrived) {
      _updateState(NavigationState.arrived);
      _voiceInstructionController.add('You have arrived at your destination');
      return;
    }

    // if (result.needsRecalculation) {
    //   _updateState(NavigationState.offRoute);
    //   _voiceInstructionController.add('Route recalculation');
    //   // Auto-recalculate after delay
    //   Future.delayed(const Duration(seconds: 2), () async {
    //     if (_state == NavigationState.offRoute) {
    //       await recalculateRoute();
    //     }
    //   });
    //   return;
    // }

    if (!result.isOnRoute && _state != NavigationState.offRoute) {
      _updateState(NavigationState.offRoute);
    } else if (result.isOnRoute && _state == NavigationState.offRoute) {
      _updateState(NavigationState.navigating);
    }

    // Emit navigation info
    _emitNavigationInfo(result);
  }

  void _updateState(NavigationState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
    }
  }

  void _emitNavigationInfo(ProjectedLocationResult result) {
    if (_route == null) return;

    // Find next direction - use currentDirectionIndex to find the next one
    RouteDirectionInfo? nextDirection;
    double distanceToNextTurn = 0;

    if (_route!.directions.isNotEmpty) {
      // Start searching from the next direction after current
      int searchStart = result.currentDirectionIndex + 1;
      if (searchStart < _route!.directions.length) {
        nextDirection = _route!.directions[searchStart];
        // Calculate distance to next turn (simplified - could be improved)
        if (result.currentDirection != null) {
          var value = findDistanceBetweenCurrentSegment(
            result.currentDirection!,
            result.projected,
          );
          // distanceToNextTurn = nextDirection.distance;
          distanceToNextTurn = value;
        }
      }
    }

    // Calculate remaining distance
    double remainingDistance = _routingHelper.remainingDistance;

    // Estimate remaining time (assuming average speed)
    double estimatedTimeRemaining = 0;
    if (result.projected.hasSpeed() && result.projected.speed > 0) {
      estimatedTimeRemaining = remainingDistance / result.projected.speed;
    } else {
      // Assume average speed of 10 m/s (36 km/h)
      estimatedTimeRemaining = remainingDistance / 10;
    }

    _navigationInfoController.add(
      NavigationInfo(
        currentLocation: result.projected,
        rawLocation: result.original,
        isOnRoute: result.isOnRoute,
        remainingDistance: remainingDistance,
        remainingTime: estimatedTimeRemaining,
        nextDirection: nextDirection,
        distanceToNextTurn: distanceToNextTurn,
        currentSegmentIndex: result.currentSegmentIndex,
        currentDirectionIndex: result.currentDirectionIndex,
        currentDirection: result.currentDirection,
        distanceToRoute: result.distanceToRoute,
      ),
    );

    // Check for turn announcements
    _checkTurnAnnouncement(nextDirection, distanceToNextTurn);
    // _instructionService.findCurrentStepIndex(
    //   gm.LatLng(latitude, longitude),
    //   NavigationRoute(
    //     routeId: routeId,
    //     origin: origin,
    //     destination: destination,
    //     legs: legs,
    //     etaInfo: etaInfo,
    //   ),
    // );
  }

  double findDistanceBetweenCurrentSegment(
    RouteDirectionInfo nextDirection,
    Location currentLocation,
  ) {
    return geo.Geolocator.distanceBetween(
      nextDirection.endLocation!.latitude,
      nextDirection.endLocation!.longitude,
      currentLocation.latitude,
      currentLocation.longitude,
    );
  }

  void _checkTurnAnnouncement(
    RouteDirectionInfo? nextDirection,
    double distance,
  ) {
    if (nextDirection == null) return;

    // Announce at different distances
    if (distance <= 50 && distance > 30) {
      if (fiftyMeterAlert.contains(nextDirection.id)) {
        return;
      } else {
        fiftyMeterAlert.add(nextDirection.id!);
        _voiceInstructionController.add(
          'In ${distance.round()} meters, ${nextDirection.getDescription()}',
        );
      }
    } else if (distance <= 30 && distance > 10) {
      if (twentyMeterAlert.contains(nextDirection.id)) {
        return;
      } else {
        twentyMeterAlert.add(nextDirection.id!);

        _voiceInstructionController.add(nextDirection.getDescription());
      }
    }
  }

  void _setupLocationListener() {
    // Cancel existing subscriptions
    _locationSubscription?.cancel();
    _projectionSubscription?.cancel();

    // Listen to raw location updates
    _locationSubscription = _locationService.locationStream.listen((location) {
      _onLocationUpdate(location);
    });

    // Listen to projection results
    _projectionSubscription = _routingHelper.projectedLocationStream.listen((
      result,
    ) {
      _onProjectionResult(result);
    });
  }

  /// Stop navigation
  void stopNavigation() {
    _locationSubscription?.cancel();
    _projectionSubscription?.cancel();
    _routingHelper.clearRoute();
    _route = null;
    _destination = null;
    _origin = null;
    fiftyMeterAlert.clear();
    twentyMeterAlert.clear();
    _updateState(NavigationState.idle);
  }

  void simulateLocation(
    double lat,
    double lon, {
    double? bearing,
    double? speed,
    double? accuracy,
  }) {
    _locationService.setSimulatedLocation(
      lat,
      lon,
      bearing: bearing,
      speed: speed,
      accuracy: accuracy,
    );
  }

  void dispose() {
    _locationSubscription?.cancel();
    _projectionSubscription?.cancel();
    _locationService.dispose();
    _routingHelper.dispose();
    _stateController.close();
    _navigationInfoController.close();
    _voiceInstructionController.close();
  }
}

class MapBoxPosition {
  final double latitude;
  final double longitude;
  final String? address;
  MapBoxPosition({
    required this.longitude,
    required this.latitude,
    this.address,
  });

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  Position toPosition() {
    return Position(longitude, latitude);
  }
}

extension ConvertPositionToMapboxPosition on Position {
  MapBoxPosition toMapBoxPosition() {
    return MapBoxPosition(longitude: lng.toDouble(), latitude: lat.toDouble());
  }

  LatLng toLatLng() {
    return LatLng(lat.toDouble(), lng.toDouble());
  }
}

extension ConvertLatLngToMapboxPosition on LatLng {
  MapBoxPosition toMapBoxPosition() {
    return MapBoxPosition(longitude: latitude, latitude: longitude);
  }

  Position toLatLng() {
    return Position(longitude, latitude);
  }
}

/// Navigation state
enum NavigationState {
  idle, // No navigation active
  calculating, // Route is being calculated
  ready, // Route calculated, ready to start
  navigating, // Active navigation
  offRoute, // User went off route
  recalculating, // Route is being recalculated
  arrived, // User arrived at destination
}

/// Navigation information at a point in time
class NavigationInfo {
  /// Current (snapped) location
  final Location currentLocation;

  /// Raw GPS location
  final Location rawLocation;

  /// Whether currently on route
  final bool isOnRoute;

  /// Remaining distance to destination in meters
  final double remainingDistance;

  /// Estimated remaining time in seconds
  final double remainingTime;

  /// Next turn direction
  final RouteDirectionInfo? nextDirection;

  /// Distance to next turn in meters
  final double distanceToNextTurn;

  /// Current segment index on route
  final int currentSegmentIndex;

  /// Current direction index (RouteDirectionInfo index)
  final int currentDirectionIndex;

  /// Current direction info
  final RouteDirectionInfo? currentDirection;

  /// Distance from GPS to route in meters
  final double distanceToRoute;

  NavigationInfo({
    required this.currentLocation,
    required this.rawLocation,
    required this.isOnRoute,
    required this.remainingDistance,
    required this.remainingTime,
    this.nextDirection,
    this.distanceToNextTurn = 0,
    required this.currentSegmentIndex,
    required this.currentDirectionIndex,
    this.currentDirection,
    required this.distanceToRoute,
  });

  /// Remaining distance formatted
  String get remainingDistanceFormatted {
    if (remainingDistance < 1000) {
      return '${remainingDistance.toInt()} m';
    } else {
      return '${(remainingDistance / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Remaining time formatted
  String get remainingTimeFormatted {
    int minutes = (remainingTime / 60).ceil();
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int mins = minutes % 60;
      return '$hours h $mins min';
    }
  }
}
