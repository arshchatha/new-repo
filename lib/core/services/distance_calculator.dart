import 'haversine_distance_service.dart';

/// Helper class for various distance calculations and formatting
class DistanceCalculator {
  /// Format distance with appropriate units
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  /// Get display distance with specified precision
  static String? getDisplayDistance({
    required double? distanceKm,
    required int precision,
  }) {
    if (distanceKm == null) return null;
    return distanceKm.toStringAsFixed(precision);
  }

  /// Calculate distance between two coordinate pairs
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return HaversineDistanceService.calculateDistance(lat1, lon1, lat2, lon2);
  }

  /// Calculate distance in miles
  static double calculateDistanceInMiles({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return HaversineDistanceService.calculateDistanceInMiles(lat1, lon1, lat2, lon2);
  }

  /// Check if location is within radius
  static bool isWithinRadius({
    required double centerLat,
    required double centerLon,
    required double targetLat,
    required double targetLon,
    required double radiusKm,
  }) {
    return HaversineDistanceService.isWithinRadius(
      centerLat, centerLon, targetLat, targetLon, radiusKm
    );
  }

  /// Convert distance units
  static Map<String, double> convertDistance(double distanceKm) {
    return {
      'kilometers': distanceKm,
      'miles': distanceKm * 0.621371,
      'meters': distanceKm * 1000,
      'feet': distanceKm * 3280.84,
    };
  }

  /// Parse distance string and extract numeric value
  static double? parseDistanceString(String distanceStr) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(distanceStr);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Format distance with both km and miles
  static String formatDistanceWithBothUnits(double distanceKm) {
    final distanceMiles = distanceKm * 0.621371;
    return '${distanceKm.toStringAsFixed(1)} km (${distanceMiles.toStringAsFixed(1)} mi)';
  }
}
