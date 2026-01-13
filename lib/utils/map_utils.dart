import 'dart:math';


import 'package:maps_toolkit/maps_toolkit.dart';

import '../models/location.dart';

/// Utility class for geographic calculations.
/// Converted from OsmAnd's MapUtils.java
/// 
/// Includes:
/// 1. Distance algorithms (Haversine)
/// 2. Point projection onto line segments
/// 3. Bearing calculations
/// 4. Coordinate validation
class MapUtils {
  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const int roundingError = 3;
  static const int earthRadiusB = 6356752;
  static const int earthRadiusA = 6378137;
  static const double minLatitude = -85.0511;
  static const double maxLatitude = 85.0511;
  static const double latitudeTurn = 180.0;
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;
  static const double longitudeTurn = 360.0;
  static const double defaultLatLonPrecision = 0.00001;
  static const double highLatLonPrecision = 0.0000001;
  static const double metersInDegree = 111320;

  // ═══════════════════════════════════════════════════════════════════════════
  // SCALAR MULTIPLICATION (DOT PRODUCT)
  // Used for projection calculations
  // ═══════════════════════════════════════════════════════════════════════════

  /// Scalar multiplication between vectors (AB, AC)
  /// Returns: (xB - xA) * (xC - xA) + (yB - yA) * (yC - yA)
  static double scalarMultiplication(
    double xA, double yA,
    double xB, double yB,
    double xC, double yC,
  ) {
    return (xB - xA) * (xC - xA) + (yB - yA) * (yC - yA);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MID POINT CALCULATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate the midpoint between two locations
  static Location calculateMidPointLocation(Location s1, Location s2) {
    final latLon = calculateMidPoint(
      s1.latitude, s1.longitude,
      s2.latitude, s2.longitude,
    );
    return Location.withCoords('', latLon[0], latLon[1]);
  }

  /// Calculate the midpoint between two LatLng points
  static LatLng calculateMidPointLatLng(LatLng s1, LatLng s2) {
    final latLon = calculateMidPoint(
      s1.latitude, s1.longitude,
      s2.latitude, s2.longitude,
    );
    return LatLng(latLon[0], latLon[1]);
  }

  /// Calculate the midpoint between two coordinate pairs
  static List<double> calculateMidPoint(
    double firstLat, double firstLon,
    double secondLat, double secondLon,
  ) {
    double lat1 = firstLat / 180 * pi;
    double lon1 = firstLon / 180 * pi;
    double lat2 = secondLat / 180 * pi;
    double lon2 = secondLon / 180 * pi;
    
    double Bx = cos(lat2) * cos(lon2 - lon1);
    double By = cos(lat2) * sin(lon2 - lon1);
    double latMid = atan2(
      sin(lat1) + sin(lat2),
      sqrt((cos(lat1) + Bx) * (cos(lat1) + Bx) + By * By),
    );
    double lonMid = lon1 + atan2(By, cos(lat1) + Bx);
    
    return [
      checkLatitude(latMid * 180 / pi),
      checkLongitude(lonMid * 180 / pi),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERMEDIATE POINT CALCULATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate an intermediate point along a great circle path
  /// [coeff] is the fraction along the path (0.0 = from, 1.0 = to)
  static LatLng calculateIntermediatePoint(
    double fromLat, double fromLon,
    double toLat, double toLon,
    double coeff,
  ) {
    double lat1 = _toRadians(fromLat);
    double lon1 = _toRadians(fromLon);
    double lat2 = _toRadians(toLat);
    double lon2 = _toRadians(toLon);

    double lat1Cos = cos(lat1);
    double lat2Cos = cos(lat2);

    double d = 2 * asin(sqrt(
      pow(sin((lat1 - lat2) / 2), 2) +
      lat1Cos * lat2Cos * pow(sin((lon1 - lon2) / 2), 2),
    ));
    
    double A = sin((1 - coeff) * d) / sin(d);
    double B = sin(coeff * d) / sin(d);
    double x = A * lat1Cos * cos(lon1) + B * lat2Cos * cos(lon2);
    double y = A * lat1Cos * sin(lon1) + B * lat2Cos * sin(lon2);
    double z = A * sin(lat1) + B * sin(lat2);

    double lat = atan2(z, sqrt(pow(x, 2) + pow(y, 2)));
    double lon = atan2(y, x);
    
    return LatLng(
      checkLatitude(lat * 180 / pi),
      checkLongitude(lon * 180 / pi),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORTHOGONAL DISTANCE (PERPENDICULAR DISTANCE TO LINE)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate the perpendicular distance from a point to a line segment.
  /// This is the shortest distance from the point to the line.
  static double getOrthogonalDistance(
    double lat, double lon,
    double fromLat, double fromLon,
    double toLat, double toLon,
  ) {
    final projection = getProjection(lat, lon, fromLat, fromLon, toLat, toLon);
    return getDistance(projection.latitude, projection.longitude, lat, lon);
  }

  /// Calculate orthogonal distance using Location objects
  static double getOrthogonalDistanceLocation(
    Location loc,
    Location from,
    Location to,
  ) {
    return getOrthogonalDistance(
      loc.latitude, loc.longitude,
      from.latitude, from.longitude,
      to.latitude, to.longitude,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // POINT PROJECTION ONTO LINE SEGMENT
  // This is the core algorithm for snap-to-road functionality
  // ═══════════════════════════════════════════════════════════════════════════

  /// Projects a point onto a line segment.
  /// Returns the closest point on the line segment to the given point.
  /// 
  /// Algorithm:
  /// 1. Calculate the squared length of the segment
  /// 2. Use dot product to find projection coefficient
  /// 3. Clamp to segment bounds if necessary
  /// 4. Interpolate to find projected point
  static LatLng getProjection(
    double lat, double lon,           // Point to project
    double fromLat, double fromLon,   // Segment start
    double toLat, double toLon,       // Segment end
  ) {
    // Not very accurate on sphere but OK for distances < 1000m
    
    // Step 1: Calculate squared length of segment
    num mDist = pow(fromLat - toLat, 2) + pow(fromLon - toLon, 2);
    
    // Handle degenerate case where segment is a point
    if (mDist == 0) {
      return LatLng(fromLat, fromLon);
    }
    
    // Step 2: Calculate scalar projection using dot product
    double projection = scalarMultiplication(
      fromLat, fromLon,
      toLat, toLon,
      lat, lon,
    );
    
    double projLat;
    double projLon;
    
    // Step 3: Determine where projection falls and clamp if needed
    if (projection < 0) {
      // Point projects BEFORE segment start
      projLat = fromLat;
      projLon = fromLon;
    } else if (projection >= mDist) {
      // Point projects AFTER segment end
      projLat = toLat;
      projLon = toLon;
    } else {
      // Point projects ONTO segment - interpolate
      double t = projection / mDist;
      projLat = fromLat + (toLat - fromLat) * t;
      projLon = fromLon + (toLon - fromLon) * t;
    }
    
    return LatLng(projLat, projLon);
  }

  /// Project a Location onto a segment defined by two Locations.
  /// Returns a new Location with projected coordinates.
  static Location getProjectionLocation(
    Location loc,
    Location from,
    Location to,
  ) {
    final projection = getProjection(
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
  // PROJECTION COEFFICIENT
  // Returns where on the segment the projection falls (0.0 to 1.0)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate the projection coefficient.
  /// Returns a value between 0.0 (at segment start) and 1.0 (at segment end).
  /// Values outside this range are clamped.
  static double getProjectionCoeff(
    double lat, double lon,
    double fromLat, double fromLon,
    double toLat, double toLon,
  ) {
    num mDist = pow(fromLat - toLat, 2) + pow(fromLon - toLon, 2);
    
    if (mDist == 0) return 0;
    
    double projection = scalarMultiplication(
      fromLat, fromLon,
      toLat, toLon,
      lat, lon,
    );
    
    if (projection < 0) {
      return 0;
    } else if (projection >= mDist) {
      return 1;
    } else {
      return projection / mDist;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DISTANCE CALCULATION (HAVERSINE FORMULA)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate the distance in meters between two points using Haversine formula.
  static double getDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double R = 6372.8; // Haversine uses R = 6372.8 km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double sinHalfLat = sin(dLat / 2);
    double sinHalfLon = sin(dLon / 2);
    double a = sinHalfLat * sinHalfLat +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sinHalfLon * sinHalfLon;
    return 2 * R * 1000 * asin(sqrt(a)); // Convert to meters
  }

  /// Calculate distance between two LatLng points
  static double getDistanceLatLng(LatLng l1, LatLng l2) {
    return getDistance(l1.latitude, l1.longitude, l2.latitude, l2.longitude);
  }

  /// Calculate distance between two Location objects
  static double getDistanceLocation(Location l1, Location l2) {
    return getDistance(l1.latitude, l1.longitude, l2.latitude, l2.longitude);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BEARING CALCULATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate the initial bearing from point 1 to point 2.
  /// Returns bearing in degrees (0-360).
  static double getBearing(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    double lat1Rad = _toRadians(lat1);
    double lat2Rad = _toRadians(lat2);
    double dLon = _toRadians(lon2 - lon1);

    double y = sin(dLon) * cos(lat2Rad);
    double x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    return normalizeDegrees360(atan2(y, x) * 180 / pi);
  }

  /// Calculate bearing between two Location objects
  static double getBearingLocation(Location from, Location to) {
    return getBearing(from.latitude, from.longitude, to.latitude, to.longitude);
  }

  /// Normalize degrees to 0-360 range
  static double normalizeDegrees360(double degrees) {
    double result = degrees % 360;
    if (result < 0) {
      result += 360;
    }
    return result;
  }

  /// Calculate the difference between two bearings.
  /// Returns a value between -180 and 180.
  static double degreesDiff(double a1, double a2) {
    double diff = a1 - a2;
    while (diff > 180) {
      diff -= 360;
    }
    while (diff <= -180) {
      diff += 360;
    }
    return diff;
  }

  /// Unify rotation difference for smooth interpolation.
  /// Returns the shortest angular distance from a1 to a2.
  static double unifyRotationDiff(double a1, double a2) {
    double diff = a2 - a1;
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    return diff;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COORDINATE VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check and normalize longitude to valid range
  static double checkLongitude(double longitude) {
    if (longitude >= minLongitude && longitude <= maxLongitude) {
      return longitude;
    }
    while (longitude <= minLongitude || longitude > maxLongitude) {
      if (longitude < 0) {
        longitude += longitudeTurn;
      } else {
        longitude -= longitudeTurn;
      }
    }
    return longitude;
  }

  /// Check and normalize latitude to valid range
  static double checkLatitude(double latitude) {
    if (latitude >= minLatitude && latitude <= maxLatitude) {
      return latitude;
    }
    while (latitude < -90 || latitude > 90) {
      if (latitude < 0) {
        latitude += latitudeTurn;
      } else {
        latitude -= latitudeTurn;
      }
    }
    if (latitude < minLatitude) {
      return minLatitude;
    } else if (latitude > maxLatitude) {
      return maxLatitude;
    }
    return latitude;
  }

  /// Check if two lat/lon pairs are approximately equal
  static bool areLatLonEqual(
    double lat1, double lon1,
    double lat2, double lon2, {
    double precision = defaultLatLonPrecision,
  }) {
    return (lat1 - lat2).abs() < precision && (lon1 - lon2).abs() < precision;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;

  /// Interpolate between two points by a fraction
  static LatLng interpolate(LatLng from, LatLng to, double fraction) {
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * fraction,
      from.longitude + (to.longitude - from.longitude) * fraction,
    );
  }
}

