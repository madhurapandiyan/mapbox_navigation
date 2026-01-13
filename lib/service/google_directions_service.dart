import 'dart:convert';
import 'package:maps_toolkit/maps_toolkit.dart';

import '../models/location.dart';
import '../models/route.dart';
import 'routing_service_interface.dart';

/// Service for fetching routes using Google Directions API.
///
/// Usage:
/// ```dart
/// final service = GoogleDirectionsService(apiKey: 'YOUR_API_KEY');
/// final url = service.buildDirectionsUrl(origin, destination);
/// // Fetch URL and parse response
/// final route = service.parseDirectionsResponse(jsonResponse);
/// ```
class GoogleDirectionsService implements RoutingServiceInterface {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONFIGURATION
  // ═══════════════════════════════════════════════════════════════════════════

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  final String apiKey;
  final String _mode;
  final String _language;
  final bool _alternatives;

  GoogleDirectionsService({
    required this.apiKey,
    String mode = 'driving',
    String language = 'en',
    bool alternatives = false,
  }) : _mode = mode,
       _language = language,
       _alternatives = alternatives;

  // ═══════════════════════════════════════════════════════════════════════════
  // URL BUILDING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build Google Directions API URL
  String buildDirectionsUrl(
    LatLng origin,
    LatLng destination, {
    List<LatLng>? waypoints,
    bool optimizeWaypoints = false,
    String? departureTime,
    String? arrivalTime,
    bool avoidTolls = false,
    bool avoidHighways = false,
    bool avoidFerries = false,
  }) {
    final params = <String, String>{
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': _mode,
      'language': _language,
      'key': apiKey,
    };

    if (_alternatives) {
      params['alternatives'] = 'true';
    }

    if (waypoints != null && waypoints.isNotEmpty) {
      final waypointStr = waypoints
          .map((w) => '${w.latitude},${w.longitude}')
          .join('|');
      params['waypoints'] = optimizeWaypoints
          ? 'optimize:true|$waypointStr'
          : waypointStr;
    }

    if (departureTime != null) {
      params['departure_time'] = departureTime;
    }

    if (arrivalTime != null) {
      params['arrival_time'] = arrivalTime;
    }

    List<String> avoid = [];
    if (avoidTolls) avoid.add('tolls');
    if (avoidHighways) avoid.add('highways');
    if (avoidFerries) avoid.add('ferries');
    if (avoid.isNotEmpty) {
      params['avoid'] = avoid.join('|');
    }

    final queryString = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return '$_baseUrl?$queryString';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESPONSE PARSING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parse Google Directions API response
  Route? parseDirectionsResponse(String jsonResponse) {
    try {
      final Map<String, dynamic> data = json.decode(jsonResponse);

      final status = data['status'] as String?;
      if (status != 'OK') {
        print('Google Directions API error: $status');
        print('Error message: ${data['error_message'] ?? 'No message'}');
        return null;
      }

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return null;
      }

      final routeData = routes[0] as Map<String, dynamic>;

      // Get overview polyline and decode
      final overviewPolyline =
          routeData['overview_polyline'] as Map<String, dynamic>?;
      if (overviewPolyline == null) {
        return null;
      }

      final encodedPoints = overviewPolyline['points'] as String;
      List<LatLng> decodedPoints = _decodePolyline(encodedPoints);

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
          final legDistance = leg['distance'] as Map<String, dynamic>?;
          final legDuration = leg['duration'] as Map<String, dynamic>?;

          if (legDistance != null) {
            totalDistance += (legDistance['value'] as num?)?.toDouble() ?? 0;
          }
          if (legDuration != null) {
            totalDuration += (legDuration['value'] as num?)?.toDouble() ?? 0;
          }

          // Parse steps for turn-by-turn
          final steps = leg['steps'] as List?;
          if (steps != null) {
            for (final step in steps) {
              final startLoc = step['start_location'] as Map<String, dynamic>?;

              final endLoc = step['end_location'] as Map<String, dynamic>?;
              LatLng? startLocation;
              LatLng? endLocation;
              final maneuver = step['maneuver'] as String?;
              final htmlInstructions = step['html_instructions'] as String?;
              final stepDistance = step['distance'] as Map<String, dynamic>?;
              final stepDuration = step['duration'] as Map<String, dynamic>?;
              if (startLoc != null) {
                startLocation = LatLng(startLoc["lat"], startLoc["lng"]);
              }

              if (endLoc != null) {
                endLocation = LatLng(endLoc["lat"], endLoc["lng"]);
              }

              TurnType turnType = _parseManeuver(maneuver);
              String? streetName = _extractStreetName(htmlInstructions);
              List<LatLng> points = [];

              double distance =
                  (stepDistance?['value'] as num?)?.toDouble() ?? 0;
              double duration =
                  (stepDuration?['value'] as num?)?.toDouble() ?? 0;

              // Estimate route point offset from step polyline
              final stepPolyline = step['polyline'] as Map<String, dynamic>?;
              if (stepPolyline != null) {
                final stepPoints = stepPolyline['points'] as String?;
                if (stepPoints != null) {
                  points = _decodePolyline(stepPoints);
                  routePointOffset += points.length;
                }
              }

              directions.add(
                RouteDirectionInfo(
                  startLocation: startLocation,
                  endLocation: endLocation,
                  steps: points,
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

      // Convert to Location list
      List<LatLng> stepPoints = directions.fold(<LatLng>[], (
        previousValue,
        element,
      ) {
        return previousValue..addAll(element.steps);
      });

      var stepLocation = stepPoints.map((p) {
        return Location.withCoords('route', p.latitude, p.longitude);
      }).toList();

      return Route(
        // locations: locations,
        locations: stepLocation,
        directions: directions,
        totalDistance: totalDistance,
        estimatedTime: totalDuration,
      );
    } catch (e) {
      print('Error parsing Google Directions response: $e');
      return null;
    }
  }

  /// Parse multiple routes from response (when alternatives=true)
  List<Route> parseAllRoutes(String jsonResponse) {
    List<Route> result = [];

    try {
      final Map<String, dynamic> data = json.decode(jsonResponse);

      final status = data['status'] as String?;
      if (status != 'OK') {
        return result;
      }

      final routes = data['routes'] as List?;
      if (routes == null) {
        return result;
      }

      for (final routeData in routes) {
        final route = _parseRouteData(routeData as Map<String, dynamic>);
        if (route != null) {
          result.add(route);
        }
      }
    } catch (e) {
      print('Error parsing routes: $e');
    }

    return result;
  }

  Route? _parseRouteData(Map<String, dynamic> routeData) {
    final overviewPolyline =
        routeData['overview_polyline'] as Map<String, dynamic>?;
    if (overviewPolyline == null) return null;

    final encodedPoints = overviewPolyline['points'] as String;
    List<LatLng> decodedPoints = _decodePolyline(encodedPoints);

    List<Location> locations = decodedPoints.map((p) {
      return Location.withCoords('route', p.latitude, p.longitude);
    }).toList();

    double totalDistance = 0;
    double totalDuration = 0;

    final legs = routeData['legs'] as List?;
    if (legs != null) {
      for (final leg in legs) {
        final legDistance = leg['distance'] as Map<String, dynamic>?;
        final legDuration = leg['duration'] as Map<String, dynamic>?;

        if (legDistance != null) {
          totalDistance += (legDistance['value'] as num?)?.toDouble() ?? 0;
        }
        if (legDuration != null) {
          totalDuration += (legDuration['value'] as num?)?.toDouble() ?? 0;
        }
      }
    }

    return Route(
      locations: locations,
      totalDistance: totalDistance,
      estimatedTime: totalDuration,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POLYLINE DECODING (Google's encoded polyline algorithm)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Decode Google's encoded polyline format
  List<LatLng> _decodePolyline(String encoded) {
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

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANEUVER PARSING
  // ═══════════════════════════════════════════════════════════════════════════

  TurnType _parseManeuver(String? maneuver) {
    if (maneuver == null) return TurnType.straight;

    switch (maneuver.toLowerCase()) {
      case 'turn-left':
        return TurnType.left;
      case 'turn-right':
        return TurnType.right;
      case 'turn-slight-left':
        return TurnType.slightLeft;
      case 'turn-slight-right':
        return TurnType.slightRight;
      case 'turn-sharp-left':
        return TurnType.sharpLeft;
      case 'turn-sharp-right':
        return TurnType.sharpRight;
      case 'uturn-left':
      case 'uturn-right':
        return TurnType.uTurn;
      case 'roundabout-left':
      case 'roundabout-right':
        return TurnType.roundabout;
      case 'straight':
      case 'keep-left':
      case 'keep-right':
      case 'merge':
      case 'ramp-left':
      case 'ramp-right':
      case 'fork-left':
      case 'fork-right':
        return TurnType.straight;
      default:
        return TurnType.straight;
    }
  }

  /// Extract street name from HTML instructions
  String? _extractStreetName(String? htmlInstructions) {
    if (htmlInstructions == null) return null;

    // Remove HTML tags
    String text = htmlInstructions.replaceAll(RegExp(r'<[^>]*>'), ' ');
    // Clean up whitespace
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
    return 'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(address)}'
        '&key=$apiKey';
  }

  /// Build reverse geocoding URL for coordinate lookup
  String buildReverseGeocodingUrl(LatLng location) {
    return 'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${location.latitude},${location.longitude}'
        '&key=$apiKey';
  }

  @override
  String get serviceName => 'Google Maps';

  /// Parse geocoding response to get LatLng
  LatLng? parseGeocodingResponse(String jsonResponse) {
    try {
      final Map<String, dynamic> data = json.decode(jsonResponse);

      if (data['status'] != 'OK') return null;

      final results = data['results'] as List?;
      if (results == null || results.isEmpty) return null;

      final location = results[0]['geometry']?['location'];
      if (location == null) return null;

      return LatLng(
        (location['lat'] as num).toDouble(),
        (location['lng'] as num).toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse reverse geocoding response to get address
  String? parseReverseGeocodingResponse(String jsonResponse) {
    try {
      final Map<String, dynamic> data = json.decode(jsonResponse);

      if (data['status'] != 'OK') return null;

      final results = data['results'] as List?;
      if (results == null || results.isEmpty) return null;

      return results[0]['formatted_address'] as String?;
    } catch (e) {
      return null;
    }
  }
}
