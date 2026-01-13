
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:uuid/uuid.dart';

import 'location.dart';

/// Represents a calculated route.
/// Simplified version of OsmAnd's RouteCalculationResult.java
class Route {
  /// List of locations along the route
  final List<Location> locations;

  /// List of direction info for turn-by-turn navigation
  final List<RouteDirectionInfo> directions;

  /// Total distance in meters
  final double totalDistance;

  /// Estimated time in seconds
  final double estimatedTime;

  /// Current position index on route
  int currentRouteIndex = 0;

  Route({
    required this.locations,
    this.directions = const [],
    this.totalDistance = 0,
    this.estimatedTime = 0,
  });

  /// Create route from list of LatLng points
  factory Route.fromLatLngs(List<LatLng> points) {
    final locations = points.map((p) {
      return Location.withCoords('route', p.latitude, p.longitude);
    }).toList();

    // Calculate total distance
    double distance = 0;
    for (int i = 0; i < locations.length - 1; i++) {
      distance += locations[i].distanceTo(locations[i + 1]);
    }

    return Route(locations: locations, totalDistance: distance);
  }

  /// Whether route is empty
  bool get isEmpty => locations.length < 2;

  /// Whether route is calculated/valid
  bool get isCalculated => locations.length >= 2;

  /// Get remaining distance from current position
  double getRemainingDistance(Location? currentLocation) {
    if (isEmpty || currentLocation == null) return 0;

    double distance = 0;

    // Distance from current position to next route point
    if (currentRouteIndex < locations.length) {
      distance += currentLocation.distanceTo(locations[currentRouteIndex]);
    }

    // Sum remaining segment distances
    for (int i = currentRouteIndex; i < locations.length - 1; i++) {
      distance += locations[i].distanceTo(locations[i + 1]);
    }

    return distance;
  }

  /// Get the next route location
  Location? getNextRouteLocation() {
    if (currentRouteIndex < locations.length) {
      return locations[currentRouteIndex];
    }
    return null;
  }

  /// Get the destination (last point)
  Location? get destination {
    if (locations.isEmpty) return null;
    return locations.last;
  }

  /// Get the origin (first point)
  Location? get origin {
    if (locations.isEmpty) return null;
    return locations.first;
  }
}

/// Turn-by-turn direction information
class RouteDirectionInfo {
  /// Turn type (e.g., "left", "right", "straight")
  final TurnType turnType;

  /// Street name
  final String? streetName;

  /// Distance to this turn in meters
  final double distance;

  /// Expected time to this turn in seconds
  final double time;

  /// Route point index where this direction starts
  final int routePointOffset;

  /// Speed at this segment in m/s
  final double speed;

  /// Route segment steps
  final List<LatLng> steps;

  /// Start location
  final LatLng? startLocation;

  /// End location
  final LatLng? endLocation;

  String? id;

  RouteDirectionInfo({
    required this.turnType,
    this.streetName,
    this.distance = 0,
    this.time = 0,
    this.routePointOffset = 0,
    this.speed = 0,
    this.endLocation,
    this.startLocation,
    this.steps = const [],
    this.id,
  }) {
    id = Uuid().v4();
  }

  /// Get description for this direction
  String getDescription() {
    String turnDesc = turnType.getDescription();
    if (streetName != null && streetName!.isNotEmpty) {
      return '$turnDesc onto $streetName';
    }
    return turnDesc;
  }
}

/// Turn type enum
enum TurnType {
  straight,
  slightLeft,
  left,
  sharpLeft,
  slightRight,
  right,
  sharpRight,
  uTurn,
  roundabout,
  finish,
}

extension TurnTypeExtension on TurnType {
  String getDescription() {
    switch (this) {
      case TurnType.straight:
        return 'Continue straight';
      case TurnType.slightLeft:
        return 'Turn slight left';
      case TurnType.left:
        return 'Turn left';
      case TurnType.sharpLeft:
        return 'Turn sharp left';
      case TurnType.slightRight:
        return 'Turn slight right';
      case TurnType.right:
        return 'Turn right';
      case TurnType.sharpRight:
        return 'Turn sharp right';
      case TurnType.uTurn:
        return 'Make a U-turn';
      case TurnType.roundabout:
        return 'Enter roundabout';
      case TurnType.finish:
        return 'You have arrived';
    }
  }

  /// Get icon code point for this turn
  int getIconCodePoint() {
    switch (this) {
      case TurnType.straight:
        return 0xe5c8; // arrow_upward
      case TurnType.slightLeft:
        return 0xe5c5; // arrow_back
      case TurnType.left:
        return 0xe5c4; // arrow_back
      case TurnType.sharpLeft:
        return 0xe5c4; // arrow_back
      case TurnType.slightRight:
        return 0xe5c8; // arrow_forward
      case TurnType.right:
        return 0xe5c8; // arrow_forward
      case TurnType.sharpRight:
        return 0xe5c8; // arrow_forward
      case TurnType.uTurn:
        return 0xe5c9; // u_turn_left
      case TurnType.roundabout:
        return 0xe863; // roundabout
      case TurnType.finish:
        return 0xe55f; // place
    }
  }
}
