import '../models/load_post.dart';
import 'services/platform_database_service.dart';

class InitTestLoads {
  static Future<void> insertTestLoads() async {
    // Initialize the database service
    await PlatformDatabaseService.instance.init();

    // Insert test loads
    await PlatformDatabaseService.instance.insertLoad(LoadPost(
      id: '1',
      title: 'Test Load 1',
      origin: 'Origin 1',
      destination: 'Destination 1',
      weight: '1000',
      rate: '500.0',
      isBrokerPost: true,
      isCarrierPost: false,
      postedBy: 'test_broker_1',
      isActive: true,
      volume: 10,
      status: 'available',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isbroken: false,
      isbooked: false,
      originCity: 'City A',
      originCountry: 'Country A',
      originState: 'State A',
      originPostalCode: '12345',
      originDescription: 'Description A',
      destinationCity: 'City B',
      destinationCountry: 'Country B',
      destinationState: 'State B',
      destinationPostalCode: '67890',
      destinationDescription: 'Description B',
      pickupTime: DateTime.now().toIso8601String(),
      deliveryTime: DateTime.now().add(Duration(days: 2)).toIso8601String(),
      appointment: false,
    ));
    
    await PlatformDatabaseService.instance.insertLoad(LoadPost(
      id: '2',
      title: 'Test Load 2',
      origin: 'Origin 2',
      destination: 'Destination 2',
      weight: '2000',
      rate: '1000.0',
      isBrokerPost: true,
      isCarrierPost: false,
      postedBy: 'test_broker_2',
      isActive: true,
      volume: 20,
      status: 'available',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isbroken: false,
      isbooked: false,
      originCity: 'City C',
      originCountry: 'Country C',
      originState: 'State C',
      originPostalCode: '54321',
      originDescription: 'Description C',
      destinationCity: 'City D',
      destinationCountry: 'Country D',
      destinationState: 'State D',
      destinationPostalCode: '09876',
      destinationDescription: 'Description D',
      pickupTime: DateTime.now().toIso8601String(),
      deliveryTime: DateTime.now().add(Duration(days: 3)).toIso8601String(),
      appointment: false,
    ));
  }
}
