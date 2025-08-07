import 'package:flutter_test/flutter_test.dart';
import 'package:lboard/core/services/haversine_distance_service.dart';

void main() {
  group('HaversineDistanceService', () {
    test('calculateDistance returns correct distance between two points', () {
      // Toronto coordinates
      const double lat1 = 43.6532;
      const double lon1 = -79.3832;
      
      // Ottawa coordinates
      const double lat2 = 45.4215;
      const double lon2 = -75.6972;

      final distance = HaversineDistanceService.calculateDistance(lat1, lon1, lat2, lon2);
      
      // The actual distance between Toronto and Ottawa is approximately 351 km
      expect(distance, closeTo(351.0, 5.0)); // Allow 5km margin of error
    });

    test('isWithinRadius correctly determines if point is within radius', () {
      // Toronto coordinates as center
      const double centerLat = 43.6532;
      const double centerLon = -79.3832;
      
      // Mississauga coordinates (about 28km from Toronto)
      const double targetLat = 43.5890;
      const double targetLon = -79.6441;

      // Test with 30km radius (should be within)
      expect(
        HaversineDistanceService.isWithinRadius(
          centerLat, centerLon, targetLat, targetLon, 30.0
        ),
        true
      );

      // Test with 25km radius (should be outside)
      expect(
        HaversineDistanceService.isWithinRadius(
          centerLat, centerLon, targetLat, targetLon, 25.0
        ),
        false
      );
    });

    test('calculateDistanceInMiles converts kilometers to miles correctly', () {
      // Toronto to Ottawa
      const double lat1 = 43.6532;
      const double lon1 = -79.3832;
      const double lat2 = 45.4215;
      const double lon2 = -75.6972;

      final distanceKm = HaversineDistanceService.calculateDistance(lat1, lon1, lat2, lon2);
      final distanceMiles = HaversineDistanceService.calculateDistanceInMiles(lat1, lon1, lat2, lon2);

      // Verify that miles = kilometers * 0.621371
      expect(distanceMiles, closeTo(distanceKm * 0.621371, 0.1));
    });
  });
}
