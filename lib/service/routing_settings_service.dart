import 'package:shared_preferences/shared_preferences.dart';
import 'routing_service_interface.dart';

/// Service for managing routing provider settings
class RoutingSettingsService {
  static const String _providerKey = 'routing_provider';
  static const String _googleApiKeyKey = 'google_api_key';
  static const String _mapboxAccessTokenKey = 'mapbox_access_token';

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get current routing provider
  Future<RoutingProvider> getRoutingProvider() async {
    await _ensureInitialized();
    final providerString = _prefs!.getString(_providerKey);
    if (providerString == null) {
      return RoutingProvider.google; // Default
    }
    return RoutingProvider.values.firstWhere(
      (p) => p.toString() == providerString,
      orElse: () => RoutingProvider.google,
    );
  }

  /// Set routing provider
  Future<void> setRoutingProvider(RoutingProvider provider) async {
    await _ensureInitialized();
    await _prefs!.setString(_providerKey, provider.toString());
  }

  /// Get Google API key
  Future<String?> getGoogleApiKey() async {
    await _ensureInitialized();
    return _prefs!.getString(_googleApiKeyKey);
  }

  /// Set Google API key
  Future<void> setGoogleApiKey(String apiKey) async {
    await _ensureInitialized();
    await _prefs!.setString(_googleApiKeyKey, apiKey);
  }

  /// Get Mapbox access token
  Future<String?> getMapboxAccessToken() async {
    await _ensureInitialized();
    return _prefs!.getString(_mapboxAccessTokenKey);
  }

  /// Set Mapbox access token
  Future<void> setMapboxAccessToken(String accessToken) async {
    await _ensureInitialized();
    await _prefs!.setString(_mapboxAccessTokenKey, accessToken);
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
}

