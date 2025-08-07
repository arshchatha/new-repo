import 'dart:math';

class HaversineDistanceService {
  /// Calculate the distance between two latitude-longitude points using the Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the earth in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
              sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  /// Convert degrees to radians
  static double _deg2rad(double deg) => deg * (pi / 180);

  /// Check if a location is within a specified radius of another location
  static bool isWithinRadius(
    double centerLat, 
    double centerLon, 
    double targetLat, 
    double targetLon, 
    double radiusKm
  ) {
    final distance = calculateDistance(centerLat, centerLon, targetLat, targetLon);
    return distance <= radiusKm;
  }

  /// Calculate distance in miles instead of kilometers
  static double calculateDistanceInMiles(double lat1, double lon1, double lat2, double lon2) {
    final distanceKm = calculateDistance(lat1, lon1, lat2, lon2);
    return distanceKm * 0.621371; // Convert km to miles
  }
}
