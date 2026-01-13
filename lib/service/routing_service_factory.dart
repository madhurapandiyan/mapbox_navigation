import 'package:http/http.dart' as http;
import 'package:maps_toolkit/maps_toolkit.dart';
import 'routing_service_interface.dart';
import 'google_directions_service.dart';
import 'mapbox_directions_service.dart';
import '../models/route.dart';

/// Factory for creating routing services
class RoutingServiceFactory {
  /// Create a routing service based on provider
  static RoutingServiceInterface createService({
    required RoutingProvider provider,
    String? googleApiKey,
    String? mapboxAccessToken,
  }) {
    switch (provider) {
      case RoutingProvider.google:
        if (googleApiKey == null || googleApiKey.isEmpty) {
          throw ArgumentError('Google API key is required');
        }
        return GoogleDirectionsService(apiKey: googleApiKey);
      case RoutingProvider.mapbox:
        if (mapboxAccessToken == null || mapboxAccessToken.isEmpty) {
          throw ArgumentError('Mapbox access token is required');
        }
        return MapboxDirectionsService(accessToken: mapboxAccessToken);
    }
  }

  /// Get a route using the specified service
  static Future<Route?> getRoute({
    required RoutingServiceInterface service,
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    try {
      final url = service.buildDirectionsUrl(
        origin,
        destination,
        waypoints: waypoints,
      );
      print(Uri.parse(url));
      // Make HTTP request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        print('Error fetching route: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }

      return service.parseDirectionsResponse(response.body);
    } catch (e) {
      print('Error fetching route: $e');
      return null;
    }
  }
}
