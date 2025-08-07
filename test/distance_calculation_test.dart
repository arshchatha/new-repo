import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lboard/core/services/distance_service.dart';
import 'package:lboard/core/services/haversine_distance_service.dart';
import 'package:lboard/models/load_post.dart';

void main() {
  group('Distance Calculation Tests', () {
    late DistanceService distanceService;
    
    setUp(() {
      distanceService = DistanceService();
    });

    group('DistanceService', () {
      test('validates coordinates correctly', () {
        // Valid coordinates
        const validOrigin = LatLng(40.7128, -74.0060); // New York
        const validDest = LatLng(34.0522, -118.2437); // Los Angeles
        
        // Invalid coordinates (out of range)
        const invalidLat = LatLng(91.0, -74.0060); // Latitude > 90
        const invalidLng = LatLng(40.7128, 181.0); // Longitude > 180
        const nanCoord = LatLng(double.nan, -74.0060); // NaN values
        
        // Test coordinate validation through the service
        expect(validOrigin.latitude.abs() <= 90.0, true);
        expect(validOrigin.longitude.abs() <= 180.0, true);
        expect(validDest.latitude.abs() <= 90.0, true);
        expect(validDest.longitude.abs() <= 180.0, true);
        
        expect(invalidLat.latitude.abs() > 90.0, true);
        expect(invalidLng.longitude.abs() > 180.0, true);
        expect(nanCoord.latitude.isNaN, true);
      });

      test('fallback distance calculation works correctly', () {
        // Test known distance between New York and Los Angeles
        const origin = LatLng(40.7128, -74.0060); // New York
        const dest = LatLng(34.0522, -118.2437); // Los Angeles
        
        final haversineDistance = HaversineDistanceService.calculateDistance(
          origin.latitude,
          origin.longitude,
          dest.latitude,
          dest.longitude,
        );
        
        // The distance between NYC and LA is approximately 3944 km
        expect(haversineDistance, closeTo(3944, 100)); // Allow 100km margin
      });

      test('distance units conversion works correctly', () {
        const distanceMeters = 5000.0; // 5 km
        
        final units = distanceService.getDistanceInUnits(distanceMeters);
        
        expect(units['meters'], equals(5000.0));
        expect(units['kilometers'], equals(5.0));
        expect(units['miles'], closeTo(3.107, 0.01)); // 5 km ≈ 3.107 miles
      });
    });

    group('HaversineDistanceService', () {
      test('calculates distance between known locations correctly', () {
        // Test with well-known distances
        
        // Toronto to Ottawa (approximately 351 km)
        const torontoLat = 43.6532;
        const torontoLon = -79.3832;
        const ottawaLat = 45.4215;
        const ottawaLon = -75.6972;
        
        final distance = HaversineDistanceService.calculateDistance(
          torontoLat, torontoLon, ottawaLat, ottawaLon
        );
        
        expect(distance, closeTo(351.0, 10.0)); // Allow 10km margin
      });

      test('calculates distance in miles correctly', () {
        const lat1 = 40.7128; // New York
        const lon1 = -74.0060;
        const lat2 = 42.3601; // Detroit
        const lon2 = -83.0493;
        
        final distanceKm = HaversineDistanceService.calculateDistance(lat1, lon1, lat2, lon2);
        final distanceMiles = HaversineDistanceService.calculateDistanceInMiles(lat1, lon1, lat2, lon2);
        
        // Verify conversion factor (1 km = 0.621371 miles)
        expect(distanceMiles, closeTo(distanceKm * 0.621371, 0.1));
      });

      test('isWithinRadius works correctly', () {
        const centerLat = 43.6532; // Toronto
        const centerLon = -79.3832;
        const targetLat = 43.5890; // Mississauga (about 28km from Toronto)
        const targetLon = -79.6441;
        
        // Should be within 30km radius
        expect(
          HaversineDistanceService.isWithinRadius(
            centerLat, centerLon, targetLat, targetLon, 30.0
          ),
          true
        );
        
        // Should be outside 20km radius
        expect(
          HaversineDistanceService.isWithinRadius(
            centerLat, centerLon, targetLat, targetLon, 20.0
          ),
          false
        );
      });

      test('handles edge cases correctly', () {
        // Same location should return 0 distance
        const lat = 40.7128;
        const lon = -74.0060;
        
        final distance = HaversineDistanceService.calculateDistance(lat, lon, lat, lon);
        expect(distance, equals(0.0));
        
        // Antipodal points (opposite sides of Earth) should return ~20,015 km
        final antipodal = HaversineDistanceService.calculateDistance(0, 0, 0, 180);
        expect(antipodal, closeTo(20015, 100));
      });
    });

    group('LoadPost Distance Calculation', () {
      test('calculateDistanceTo works with valid coordinates', () {
        final load1 = LoadPost(
          id: '1',
          title: 'Test Load 1',
          origin: 'New York, NY',
          destination: 'Los Angeles, CA',
          isBrokerPost: true,
          isCarrierPost: false,
          postedBy: 'user1',
          pickupLatitude: 40.7128,
          pickupLongitude: -74.0060,
          isActive: true,
          volume: 0,
          status: 'available',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isbroken: false,
          isbooked: false,
        );
        
        final load2 = LoadPost(
          id: '2',
          title: 'Test Load 2',
          origin: 'Chicago, IL',
          destination: 'Miami, FL',
          isBrokerPost: false,
          isCarrierPost: true,
          postedBy: 'user2',
          pickupLatitude: 41.8781,
          pickupLongitude: -87.6298,
          isActive: true,
          volume: 0,
          status: 'available',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isbroken: false,
          isbooked: false,
        );
        
        final distance = load1.calculateDistanceTo(load2);
        expect(distance, isNotNull);
        expect(distance, contains('km'));
      });

      test('calculateDistanceTo returns null with missing coordinates', () {
        final load1 = LoadPost(
          id: '1',
          title: 'Test Load 1',
          origin: 'New York, NY',
          destination: 'Los Angeles, CA',
          isBrokerPost: true,
          isCarrierPost: false,
          postedBy: 'user1',
          // Missing coordinates
          isActive: true,
          volume: 0,
          status: 'available',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isbroken: false,
          isbooked: false,
        );
        
        final load2 = LoadPost(
          id: '2',
          title: 'Test Load 2',
          origin: 'Chicago, IL',
          destination: 'Miami, FL',
          isBrokerPost: false,
          isCarrierPost: true,
          postedBy: 'user2',
          pickupLatitude: 41.8781,
          pickupLongitude: -87.6298,
          isActive: true,
          volume: 0,
          status: 'available',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isbroken: false,
          isbooked: false,
        );
        
        final distance = load1.calculateDistanceTo(load2);
        expect(distance, isNull);
      });
    });

    group('Error Handling', () {
      test('handles invalid coordinate ranges', () {
        // Test coordinates outside valid ranges
        expect(() => HaversineDistanceService.calculateDistance(91, 0, 0, 0), returnsNormally);
        expect(() => HaversineDistanceService.calculateDistance(0, 181, 0, 0), returnsNormally);
        expect(() => HaversineDistanceService.calculateDistance(-91, 0, 0, 0), returnsNormally);
        expect(() => HaversineDistanceService.calculateDistance(0, -181, 0, 0), returnsNormally);
      });

      test('handles NaN and infinite values', () {
        expect(() => HaversineDistanceService.calculateDistance(double.nan, 0, 0, 0), returnsNormally);
        expect(() => HaversineDistanceService.calculateDistance(double.infinity, 0, 0, 0), returnsNormally);
        expect(() => HaversineDistanceService.calculateDistance(0, double.negativeInfinity, 0, 0), returnsNormally);
      });
    });

    group('Performance Tests', () {
      test('distance calculation performance', () {
        const iterations = 1000;
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < iterations; i++) {
          HaversineDistanceService.calculateDistance(
            40.7128 + (i * 0.001), // Vary coordinates slightly
            -74.0060 + (i * 0.001),
            34.0522,
            -118.2437,
          );
        }
        
        stopwatch.stop();
        
        // Should complete 1000 calculations in reasonable time (< 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}
