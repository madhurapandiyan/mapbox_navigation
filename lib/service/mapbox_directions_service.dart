import 'dart:convert';

import 'package:maps_toolkit/maps_toolkit.dart';

import '../models/location.dart';
import '../models/route.dart';
import 'routing_service_interface.dart';

/// Service for fetching routes using Mapbox Directions API.
///
/// Usage:
/// ```dart
/// final service = MapboxDirectionsService(accessToken: 'YOUR_ACCESS_TOKEN');
/// final url = service.buildDirectionsUrl(origin, destination);
/// // Fetch URL and parse response
/// final route = service.parseDirectionsResponse(jsonResponse);
/// ```
class MapboxDirectionsService implements RoutingServiceInterface {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════

  static const String _baseUrl = 'https://api.mapbox.com/directions/v5';

  final String accessToken;
  final String _profile;
  final String _language;
  final bool _alternatives;

  MapboxDirectionsService({
    required this.accessToken,
    String profile = 'mapbox/walking',
    String language = 'en',
    bool alternatives = false,
  }) : _profile = profile,
       _language = language,
       _alternatives = alternatives;

  // ═══════════════════════════════════════════════════════════════════════════
  // URL BUILDING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build Mapbox Directions API URL
  String buildDirectionsUrl(
    LatLng origin,
    LatLng destination, {
    List<LatLng>? waypoints,
    bool steps = true,
    bool geometries = true,
    bool overview = true,
    bool annotations = false,
  }) {
    // Build coordinates string: lon,lat;lon,lat;...
    String coords = '${origin.longitude},${origin.latitude}';
    if (waypoints != null && waypoints.isNotEmpty) {
      for (final waypoint in waypoints) {
        coords += ';${waypoint.longitude},${waypoint.latitude}';
      }
    }
    coords += ';${destination.longitude},${destination.latitude}';

    String url = '$_baseUrl/$_profile/$coords';

    List<String> params = ['access_token=$accessToken', 'language=$_language'];

    if (steps) params.add('steps=true');
    if (geometries) params.add('geometries=polyline6');
    if (overview) params.add('overview=full');
    if (annotations) params.add('annotations=duration,distance');
    if (_alternatives) params.add('alternatives=true');

    return '$url?${params.join('&')}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESPONSE PARSING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parse Mapbox Directions API response
  Route? parseDirectionsResponse(String jsonResponse) {
    try {
      final Map<String, dynamic> data = json.decode(jsonResponse);

      final code = data['code'] as String?;
      if (code != 'Ok') {
        print('Mapbox Directions API error: $code');
        print('Error message: ${data['message'] ?? 'No message'}');
        return null;
      }

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return null;
      }

      final routeData = routes.last as Map<String, dynamic>;

      // Decode geometry (polyline6 format)
      String? geometry = routeData['geometry'] as String?;
      if (geometry == null) {
        return null;
      }

      List<LatLng> decodedPoints = _decodePolyline6(geometry);

      // Convert to Location list
      List<Location> locations = decodedPoints.map((p) {
        return Location.withCoords('route', p.latitude, p.longitude);
      }).toList();

      // Parse legs for directions
      List<RouteDirectionInfo> directions = [];
      double totalDistance = 0;
      double totalDuration = 0;
      int routePointOffset = 0;

      final legs = routeData['legs'] as List?;
      if (legs != null) {
        for (final leg in legs) {
          // Accumulate totals
          final legDistance = leg['distance'] as num?;
          final legDuration = leg['duration'] as num?;

          if (legDistance != null) {
            totalDistance += legDistance.toDouble();
          }
          if (legDuration != null) {
            totalDuration += legDuration.toDouble();
          }

          // Parse steps for turn-by-turn
          final steps = leg['steps'] as List?;
          if (steps != null) {
            for (final step in steps) {
              final maneuver = step['maneuver'] as Map<String, dynamic>?;
              final instruction = step['instruction'] as String?;
              final stepDistance = step['distance'] as num?;
              final stepDuration = step['duration'] as num?;
              final stepGeometry = step['geometry'] as String?;

              TurnType turnType = _parseManeuver(maneuver);
              String? streetName = _extractStreetName(instruction);

              double distance = stepDistance?.toDouble() ?? 0;
              double duration = stepDuration?.toDouble() ?? 0;

              // Decode step geometry
              List<LatLng> stepPoints = [];
              if (stepGeometry != null) {
                stepPoints = _decodePolyline6(stepGeometry);
                routePointOffset += stepPoints.length;
              }

              // Get start/end locations from step geometry
              LatLng? startLocation;
              LatLng? endLocation;
              if (stepPoints.isNotEmpty) {
                startLocation = stepPoints.first;
                endLocation = stepPoints.last;
              }

              directions.add(
                RouteDirectionInfo(
                  startLocation: startLocation,
                  endLocation: endLocation,
                  steps: stepPoints,
                  turnType: turnType,
                  streetName: streetName,
                  distance: distance,
                  time: duration,
                  routePointOffset: routePointOffset,
                  speed: duration > 0 ? distance / duration : 0,
                ),
              );
            }
          }
        }
      }

      // Use step points for route locations if available
      List<LatLng> stepPoints = directions.fold(<LatLng>[], (
        previousValue,
        element,
      ) {
        return previousValue..addAll(element.steps);
      });

      var stepLocations = stepPoints.map((p) {
        return Location.withCoords('route', p.latitude, p.longitude);
      }).toList();

      return Route(
        locations: stepLocations.isNotEmpty ? stepLocations : locations,
        directions: directions,
        totalDistance: totalDistance,
        estimatedTime: totalDuration,
      );
    } catch (e) {
      print('Error parsing Mapbox Directions response: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POLYLINE6 DECODING (Mapbox's encoded polyline format)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Decode Mapbox's polyline6 format
  List<LatLng> _decodePolyline6(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e6, lng / 1e6));
    }

    return points;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANEUVER PARSING
  // ═══════════════════════════════════════════════════════════════════════════

  TurnType _parseManeuver(Map<String, dynamic>? maneuver) {
    if (maneuver == null) return TurnType.straight;

    String type = maneuver['type'] as String? ?? 'turn';
    String? modifier = maneuver['modifier'] as String?;

    if (type == 'arrive') {
      return TurnType.finish;
    }

    if (type == 'roundabout' || type == 'rotary') {
      return TurnType.roundabout;
    }

    switch (modifier) {
      case 'straight':
        return TurnType.straight;
      case 'slight left':
        return TurnType.slightLeft;
      case 'left':
        return TurnType.left;
      case 'sharp left':
        return TurnType.sharpLeft;
      case 'slight right':
        return TurnType.slightRight;
      case 'right':
        return TurnType.right;
      case 'sharp right':
        return TurnType.sharpRight;
      case 'uturn':
      case 'uturn left':
      case 'uturn right':
        return TurnType.uTurn;
      default:
        return TurnType.straight;
    }
  }

  /// Extract street name from instruction
  String? _extractStreetName(String? instruction) {
    if (instruction == null) return null;

    // Remove HTML tags if present
    String text = instruction.replaceAll(RegExp(r'<[^>]*>'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Try to extract street name after "onto" or "on"
    final ontoMatch = RegExp(
      r'onto\s+(.+?)(?:\s+toward|\s*$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (ontoMatch != null) {
      return ontoMatch.group(1)?.trim();
    }

    final onMatch = RegExp(
      r'on\s+(.+?)(?:\s+toward|\s*$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (onMatch != null) {
      return onMatch.group(1)?.trim();
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GEOCODING HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build geocoding URL for address lookup
  String buildGeocodingUrl(String address) {
    return 'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(address)}.json'
        '?access_token=$accessToken';
  }

  /// Build reverse geocoding URL for coordinate lookup
  String buildReverseGeocodingUrl(LatLng location) {
    return 'https://api.mapbox.com/geocoding/v5/mapbox.places/${location.longitude},${location.latitude}.json'
        '?access_token=$accessToken';
  }

  /// Parse geocoding response to get LatLng
  LatLng? parseGeocodingResponse(String jsonResponse) {
    try {
      final Map<String, dynamic> data = json.decode(jsonResponse);

      final features = data['features'] as List?;
      if (features == null || features.isEmpty) return null;

      final coordinates = features[0]['geometry']?['coordinates'] as List?;
      if (coordinates == null || coordinates.length < 2) return null;

      // Mapbox returns [longitude, latitude]
      return LatLng(
        (coordinates[1] as num).toDouble(),
        (coordinates[0] as num).toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse reverse geocoding response to get address
  String? parseReverseGeocodingResponse(String jsonResponse) {
    try {
      final Map<String, dynamic> data = json.decode(jsonResponse);

      final features = data['features'] as List?;
      if (features == null || features.isEmpty) return null;

      return features[0]['place_name'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  String get serviceName => 'Mapbox';
}
