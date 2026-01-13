import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

/// A class representing a geographic location sensed at a particular time.
/// Converted from OsmAnd's Location.java
///
/// A location consists of a latitude and longitude, a UTC timestamp,
/// and optionally information on altitude, speed, bearing, and accuracy.
class Location {
  String provider;
  int time;
  double latitude;
  double longitude;
  bool _hasAltitude;
  double _altitude;
  bool _hasSpeed;
  double _speed;
  bool _hasBearing;
  double _bearing;
  bool _hasAccuracy;
  double _accuracy;
  bool _hasVerticalAccuracy;
  double _verticalAccuracy;

  // Cache for distance/bearing calculations
  double _cachedLat1 = 0.0;
  double _cachedLon1 = 0.0;
  double _cachedLat2 = 0.0;
  double _cachedLon2 = 0.0;
  double _cachedDistance = 0.0;
  double _cachedBearing = 0.0;

  /// Constructs a new Location with the given provider.
  Location(this.provider)
    : time = 0,
      latitude = 0.0,
      longitude = 0.0,
      _hasAltitude = false,
      _altitude = 0.0,
      _hasSpeed = false,
      _speed = 0.0,
      _hasBearing = false,
      _bearing = 0.0,
      _hasAccuracy = false,
      _accuracy = 0.0,
      _hasVerticalAccuracy = false,
      _verticalAccuracy = 0.0;

  /// Constructs a new Location with provider, latitude, and longitude.
  Location.withCoords(this.provider, this.latitude, this.longitude)
    : time = 0,
      _hasAltitude = false,
      _altitude = 0.0,
      _hasSpeed = false,
      _speed = 0.0,
      _hasBearing = false,
      _bearing = 0.0,
      _hasAccuracy = false,
      _accuracy = 0.0,
      _hasVerticalAccuracy = false,
      _verticalAccuracy = 0.0;

  /// Constructs a new Location that is a copy of the given location.
  Location.from(Location other)
    : provider = other.provider,
      time = other.time,
      latitude = other.latitude,
      longitude = other.longitude,
      _hasAltitude = other._hasAltitude,
      _altitude = other._altitude,
      _hasSpeed = other._hasSpeed,
      _speed = other._speed,
      _hasBearing = other._hasBearing,
      _bearing = other._bearing,
      _hasAccuracy = other._hasAccuracy,
      _accuracy = other._accuracy,
      _hasVerticalAccuracy = other._hasVerticalAccuracy,
      _verticalAccuracy = other._verticalAccuracy;

  /// Sets the contents of this location to the values from the given location.
  void set(Location other) {
    provider = other.provider;
    time = other.time;
    latitude = other.latitude;
    longitude = other.longitude;
    _hasAltitude = other._hasAltitude;
    _altitude = other._altitude;
    _hasSpeed = other._hasSpeed;
    _speed = other._speed;
    _hasBearing = other._hasBearing;
    _bearing = other._bearing;
    _hasAccuracy = other._hasAccuracy;
    _accuracy = other._accuracy;
    _hasVerticalAccuracy = other._hasVerticalAccuracy;
    _verticalAccuracy = other._verticalAccuracy;
  }

  /// Clears the contents of the location.
  void reset() {
    provider = '';
    time = 0;
    latitude = 0;
    longitude = 0;
    _hasAltitude = false;
    _altitude = 0;
    _hasSpeed = false;
    _speed = 0;
    _hasBearing = false;
    _bearing = 0;
    _hasAccuracy = false;
    _accuracy = 0;
    _hasVerticalAccuracy = false;
    _verticalAccuracy = 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISTANCE AND BEARING CALCULATIONS
  // Based on WGS84 ellipsoid (from OsmAnd's Location.java)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Computes distance and bearing between two coordinates using WGS84 ellipsoid.
  static List<double> _computeDistanceAndBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const int maxIters = 20;

    // Convert to radians
    lat1 = lat1 * pi / 180.0;
    lat2 = lat2 * pi / 180.0;
    lon1 = lon1 * pi / 180.0;
    lon2 = lon2 * pi / 180.0;

    const double a = 6378137.0; // WGS84 major axis
    const double b = 6356752.3142; // WGS84 semi-major axis
    const double f = (a - b) / a;
    const double aSqMinusBSqOverBSq = (a * a - b * b) / (b * b);

    double L = lon2 - lon1;
    double A = 0.0;
    double U1 = atan((1.0 - f) * tan(lat1));
    double U2 = atan((1.0 - f) * tan(lat2));

    double cosU1 = cos(U1);
    double cosU2 = cos(U2);
    double sinU1 = sin(U1);
    double sinU2 = sin(U2);
    double cosU1cosU2 = cosU1 * cosU2;
    double sinU1sinU2 = sinU1 * sinU2;

    double sigma = 0.0;
    double deltaSigma = 0.0;
    double cosSqAlpha = 0.0;
    double cos2SM = 0.0;
    double cosSigma = 0.0;
    double sinSigma = 0.0;
    double cosLambda = 0.0;
    double sinLambda = 0.0;

    double lambda = L;
    for (int iter = 0; iter < maxIters; iter++) {
      double lambdaOrig = lambda;
      cosLambda = cos(lambda);
      sinLambda = sin(lambda);
      double t1 = cosU2 * sinLambda;
      double t2 = cosU1 * sinU2 - sinU1 * cosU2 * cosLambda;
      double sinSqSigma = t1 * t1 + t2 * t2;
      sinSigma = sqrt(sinSqSigma);
      cosSigma = sinU1sinU2 + cosU1cosU2 * cosLambda;
      sigma = atan2(sinSigma, cosSigma);
      double sinAlpha = (sinSigma == 0)
          ? 0.0
          : cosU1cosU2 * sinLambda / sinSigma;
      cosSqAlpha = 1.0 - sinAlpha * sinAlpha;
      cos2SM = (cosSqAlpha == 0)
          ? 0.0
          : cosSigma - 2.0 * sinU1sinU2 / cosSqAlpha;

      double uSquared = cosSqAlpha * aSqMinusBSqOverBSq;
      A =
          1 +
          (uSquared / 16384.0) *
              (4096.0 +
                  uSquared * (-768 + uSquared * (320.0 - 175.0 * uSquared)));
      double B =
          (uSquared / 1024.0) *
          (256.0 + uSquared * (-128.0 + uSquared * (74.0 - 47.0 * uSquared)));
      double C = (f / 16.0) * cosSqAlpha * (4.0 + f * (4.0 - 3.0 * cosSqAlpha));
      double cos2SMSq = cos2SM * cos2SM;
      deltaSigma =
          B *
          sinSigma *
          (cos2SM +
              (B / 4.0) *
                  (cosSigma * (-1.0 + 2.0 * cos2SMSq) -
                      (B / 6.0) *
                          cos2SM *
                          (-3.0 + 4.0 * sinSigma * sinSigma) *
                          (-3.0 + 4.0 * cos2SMSq)));

      lambda =
          L +
          (1.0 - C) *
              f *
              sinAlpha *
              (sigma +
                  C *
                      sinSigma *
                      (cos2SM + C * cosSigma * (-1.0 + 2.0 * cos2SM * cos2SM)));

      double delta = (lambda - lambdaOrig) / lambda;
      if (delta.abs() < 1.0e-12) {
        break;
      }
    }

    double distance = b * A * (sigma - deltaSigma);
    double initialBearing = atan2(
      cosU2 * sinLambda,
      cosU1 * sinU2 - sinU1 * cosU2 * cosLambda,
    );
    initialBearing = initialBearing * 180.0 / pi;

    return [distance, initialBearing];
  }

  /// Returns the approximate distance in meters to the given location.
  double distanceTo(Location dest) {
    if (latitude != _cachedLat1 ||
        longitude != _cachedLon1 ||
        dest.latitude != _cachedLat2 ||
        dest.longitude != _cachedLon2) {
      final results = _computeDistanceAndBearing(
        latitude,
        longitude,
        dest.latitude,
        dest.longitude,
      );
      _cachedLat1 = latitude;
      _cachedLon1 = longitude;
      _cachedLat2 = dest.latitude;
      _cachedLon2 = dest.longitude;
      _cachedDistance = results[0];
      _cachedBearing = results[1];
    }
    return _cachedDistance;
  }

  /// Returns the approximate initial bearing in degrees to the given location.
  double bearingTo(Location dest) {
    if (latitude != _cachedLat1 ||
        longitude != _cachedLon1 ||
        dest.latitude != _cachedLat2 ||
        dest.longitude != _cachedLon2) {
      final results = _computeDistanceAndBearing(
        latitude,
        longitude,
        dest.latitude,
        dest.longitude,
      );
      _cachedLat1 = latitude;
      _cachedLon1 = longitude;
      _cachedLat2 = dest.latitude;
      _cachedLon2 = dest.longitude;
      _cachedDistance = results[0];
      _cachedBearing = results[1];
    }
    return _cachedBearing;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ALTITUDE
  // ═══════════════════════════════════════════════════════════════════════════

  bool hasAltitude() => _hasAltitude;

  double get altitude => _altitude;

  set altitude(double value) {
    _altitude = value;
    _hasAltitude = true;
  }

  void removeAltitude() {
    _altitude = 0.0;
    _hasAltitude = false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SPEED
  // ═══════════════════════════════════════════════════════════════════════════

  bool hasSpeed() => _hasSpeed;

  double get speed => _speed;

  set speed(double value) {
    _speed = value;
    _hasSpeed = true;
  }

  void removeSpeed() {
    _speed = 0.0;
    _hasSpeed = false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BEARING
  // ═══════════════════════════════════════════════════════════════════════════

  bool hasBearing() => _hasBearing;

  double get bearing => _bearing;

  set bearing(double value) {
    double normalized = value;
    while (normalized < 0.0) {
      normalized += 360.0;
    }
    while (normalized >= 360.0) {
      normalized -= 360.0;
    }
    _bearing = normalized;
    _hasBearing = true;
  }

  void removeBearing() {
    _bearing = 0.0;
    _hasBearing = false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCURACY
  // ═══════════════════════════════════════════════════════════════════════════

  bool hasAccuracy() => _hasAccuracy;

  double get accuracy => _accuracy;

  set accuracy(double value) {
    _accuracy = value;
    _hasAccuracy = true;
  }

  void removeAccuracy() {
    _accuracy = 0.0;
    _hasAccuracy = false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VERTICAL ACCURACY
  // ═══════════════════════════════════════════════════════════════════════════

  bool hasVerticalAccuracy() => _hasVerticalAccuracy;

  double get verticalAccuracy => _verticalAccuracy;

  set verticalAccuracy(double value) {
    _verticalAccuracy = value;
    _hasVerticalAccuracy = true;
  }

  void removeVerticalAccuracy() {
    _verticalAccuracy = 0.0;
    _hasVerticalAccuracy = false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  LatLng toLatLng() => LatLng(latitude, longitude);

  @override
  String toString() {
    return 'Location[provider=$provider, time=$time, lat=$latitude, lon=$longitude, '
        'hasAltitude=$_hasAltitude, altitude=$_altitude, '
        'hasSpeed=$_hasSpeed, speed=$_speed, '
        'hasBearing=$_hasBearing, bearing=$_bearing, '
        'hasAccuracy=$_hasAccuracy, accuracy=$_accuracy]';
  }

  Position toPosition() {
    return Position(
      longitude: longitude,
      latitude: latitude,
      timestamp: DateTime.now(),
      accuracy: accuracy,
      altitude: altitude,
      altitudeAccuracy: altitude,
      heading: bearing,
      headingAccuracy: bearing,
      speed: speed,
      speedAccuracy: speed,
    );
  }
}
