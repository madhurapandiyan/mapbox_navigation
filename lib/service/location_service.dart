import 'dart:async';
import 'dart:math';
import '../models/location.dart';

/// Service for handling GPS location updates.
/// Converted from OsmAnd's OsmAndLocationProvider.java
///
/// This service:
/// - Receives GPS updates from the platform
/// - Filters invalid/inaccurate locations
/// - Applies smoothing to compass/bearing
/// - Integrates with RoutingHelper for navigation
class LocationService {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Maximum GPS accuracy to accept for routing (meters)
  static const double accuracyForRouting = 50.0;

  /// Timeout for considering GPS signal lost (milliseconds)
  static const int lostLocationCheckDelay = 18000;

  /// Time before location is considered stale (milliseconds)
  static const int locationTimeoutStale = 2 * 60 * 1000; // 2 minutes

  /// Kalman filter coefficient for bearing smoothing
  static const double kalmanCoefficient = 0.04;

  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════

  Location? _lastLocation;
  Location? _prevLocation;
  int _lastTimeLocationFixed = 0;
  bool _gpsSignalLost = false;

  // Bearing smoothing state
  double _avgValSin = 0;
  double _avgValCos = 0;
  double _smoothedBearing = 0;
  bool _hasSmoothBearing = false;

  // Stream controllers
  final _locationController = StreamController<Location>.broadcast();
  final _gpsStatusController = StreamController<GpsStatus>.broadcast();

  /// Stream of location updates
  Stream<Location> get locationStream => _locationController.stream;

  /// Stream of GPS status updates
  Stream<GpsStatus> get gpsStatusStream => _gpsStatusController.stream;

  /// Last known location
  Location? get lastLocation => _lastLocation;

  /// Whether GPS signal is currently lost
  bool get isGpsSignalLost => _gpsSignalLost;

  /// Get the smoothed bearing
  double get smoothedBearing => _smoothedBearing;

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATION PROCESSING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Process a new location update from the platform.
  /// This should be called by platform-specific GPS code.
  void onLocationChanged(Location location) {
    // Validate location
    if (_shouldIgnoreLocation(location)) {
      return;
    }

    _prevLocation = _lastLocation;

    // Enhance location (smoothing, etc.)
    _enhanceLocation(location);

    // Check GPS accuracy
    if (_isPointAccurateForRouting(location)) {
      _lastTimeLocationFixed = DateTime.now().millisecondsSinceEpoch;
      _notifyGpsRecovered();
    }

    _lastLocation = location;

    // Emit location update
    _locationController.add(location);
  }

  /// Check if location should be ignored
  bool _shouldIgnoreLocation(Location? location) {
    if (location == null) return true;

    // Check for invalid coordinates
    if (location.latitude == 0 && location.longitude == 0) {
      return true;
    }

    // Check for duplicate location
    if (_prevLocation != null) {
      if (location.latitude == _prevLocation!.latitude &&
          location.longitude == _prevLocation!.longitude
      //  &&location.time == _prevLocation!.time
      ) {
        return true;
      }
    }

    return false;
  }

  /// Enhance location with smoothing
  void _enhanceLocation(Location location) {
    // Smooth bearing using Kalman-like filter
    if (location.hasBearing()) {
      _smoothBearing(location.bearing);
      // Optionally apply smoothed bearing back
      // location.bearing = _smoothedBearing;
    }
  }

  /// Check if location is accurate enough for routing
  bool _isPointAccurateForRouting(Location location) {
    if (!location.hasAccuracy()) {
      return true; // Assume OK if no accuracy data
    }
    return location.accuracy <= accuracyForRouting;
  }

  /// Smooth bearing using exponential moving average
  void _smoothBearing(double bearing) {
    double bearingRad = bearing * pi / 180;
    double sinVal = sin(bearingRad);
    double cosVal = cos(bearingRad);

    if (!_hasSmoothBearing) {
      _avgValSin = sinVal;
      _avgValCos = cosVal;
      _hasSmoothBearing = true;
    } else {
      _avgValSin = _avgValSin + kalmanCoefficient * (sinVal - _avgValSin);
      _avgValCos = _avgValCos + kalmanCoefficient * (cosVal - _avgValCos);
    }

    _smoothedBearing = atan2(_avgValSin, _avgValCos) * 180 / pi;
    if (_smoothedBearing < 0) {
      _smoothedBearing += 360;
    }
  }

  /// Notify that GPS signal has been recovered
  void _notifyGpsRecovered() {
    if (_gpsSignalLost) {
      _gpsSignalLost = false;
      _gpsStatusController.add(GpsStatus.recovered);
    }
  }

  /// Called when GPS signal is lost
  void onGpsLost() {
    if (!_gpsSignalLost) {
      _gpsSignalLost = true;
      _gpsStatusController.add(GpsStatus.lost);
    }
  }

  /// Check if location is stale (too old)
  bool isLocationStale(Location location) {
    int now = DateTime.now().millisecondsSinceEpoch;
    return (now - location.time) > locationTimeoutStale;
  }

  /// Reset bearing smoothing
  void resetBearingSmoothing() {
    _hasSmoothBearing = false;
    _avgValSin = 0;
    _avgValCos = 0;
    _smoothedBearing = 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIMULATED LOCATION (for testing)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Set a simulated location (useful for testing)
  void setSimulatedLocation(
    double latitude,
    double longitude, {
    double? bearing,
    double? speed,
    double? accuracy,
  }) {
    Location location = Location.withCoords('simulated', latitude, longitude);
    location.time = DateTime.now().millisecondsSinceEpoch;

    if (bearing != null) location.bearing = bearing;
    if (speed != null) location.speed = speed;
    if (accuracy != null) location.accuracy = accuracy;

    onLocationChanged(location);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Dispose of resources
  void dispose() {
    _locationController.close();
    _gpsStatusController.close();
  }
}

/// GPS status enum
enum GpsStatus { normal, lost, recovered }
