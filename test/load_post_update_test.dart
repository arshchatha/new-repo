import 'package:flutter_test/flutter_test.dart';
import 'package:lboard/models/load_post.dart';
import 'package:lboard/core/services/platform_database_service.dart';

void main() {
  group('LoadPost Database Update Tests', () {
    test('Update LoadPost without matchingLoads field', () async {
      final load = LoadPost(
        id: 'test123',
        title: 'Test Load',
        origin: 'Origin City',
        destination: 'Destination City',
        isBrokerPost: true,
        isCarrierPost: false,
        postedBy: 'user123',
        bids: [],
        equipment: [],
        country: 'USA',
        originCity: null,
        originCountry: null,
        originState: null,
        originPostalCode: null,
        originDescription: null,
        destinationCity: null,
        destinationCountry: null,
        pickupTime: null,
        destinationState: null,
        destinationPostalCode: null,
        destinationDescription: null,
        deliveryTime: null,
        appointment: false,
        isActive: true,
        volume: 0,
        status: 'available',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isbroken: false,
        isbooked: false,
      );

      // Add matchingLoads to simulate the problematic field
      load.matchingLoads = [
        LoadPost(
          id: 'match1',
          title: 'Match Load 1',
          origin: 'Origin City',
          destination: 'Destination City',
          isBrokerPost: false,
          isCarrierPost: true,
          postedBy: 'user456',
          bids: [],
          equipment: [],
          country: 'USA',
          originCity: null,
          originCountry: null,
          originState: null,
          originPostalCode: null,
          originDescription: null,
          destinationCity: null,
          destinationCountry: null,
          pickupTime: null,
          destinationState: null,
          destinationPostalCode: null,
          destinationDescription: null,
          deliveryTime: null,
          appointment: false,
          isActive: true,
          volume: 0,
          status: 'available',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isbroken: false,
          isbooked: false,
        )
      ];

      // Convert to map and ensure matchingLoads is excluded
      final map = load.toMap();
      expect(map.containsKey('matchingLoads'), false);

      // Attempt to update load in database (mock or real)
      // Here we just call updateLoad to ensure no exception is thrown
      try {
        await PlatformDatabaseService.instance.init();
        await PlatformDatabaseService.instance.updateLoad(load);
      } catch (e) {
        fail('UpdateLoad threw an exception: $e');
      }
    });
  });
}
