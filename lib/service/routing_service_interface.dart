import 'package:maps_toolkit/maps_toolkit.dart';

import '../models/route.dart';

/// Abstract interface for routing services (Google, Mapbox, etc.)
abstract class RoutingServiceInterface {
  /// Build the URL for fetching directions
  String buildDirectionsUrl(
    LatLng origin,
    LatLng destination, {
    List<LatLng>? waypoints,
  });

  /// Parse the response from the routing API
  Route? parseDirectionsResponse(String jsonResponse);

  /// Get the service name for display
  String get serviceName;
}

/// Routing provider enum
enum RoutingProvider { google, mapbox }

extension RoutingProviderExtension on RoutingProvider {
  String get displayName {
    switch (this) {
      case RoutingProvider.google:
        return 'Google Maps';
      case RoutingProvider.mapbox:
        return 'Mapbox';
    }
  }
}
