import 'package:lboard/core/services/platform_database_service.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import '../test_data.dart';

class InitTestUsers {
  static Future<void> insertTestUsers() async {
    final dbHelper = PlatformDatabaseService.instance;
    await dbHelper.init();

    // Check and insert carrier user
    final carrierUser = await dbHelper.getUser(TestUserData.carrierId);
    if (carrierUser == null) {
      final newCarrierUser = User(
        id: TestUserData.carrierId,
        name: 'Test Carrier',
        email: 'carrier@example.com',
        phoneNumber: '123-456-7890',
        companyName: 'Carrier Company',
        companyAddress: '123 Carrier St',
        usDotMcNumber: 'DOT123456',
        password: TestUserData.carrierPassword,
        role: UserRole.carrier.name,
        isLoggedIn: false,
        equipment: ['Van', 'Flatbed'], loadPosts: [], // Add equipment preferences
      );
      await dbHelper.insertUser(newCarrierUser);
    }

    // Check and insert broker user
    final brokerUser = await dbHelper.getUser(TestUserData.brokerId);
    if (brokerUser == null) {
      final newBrokerUser = User(
        id: TestUserData.brokerId,
        name: 'Test Broker',
        email: 'broker@example.com',
        phoneNumber: '987-654-3210',
        companyName: 'Broker Company',
        companyAddress: '456 Broker Ave',
        usDotMcNumber: 'DOT654321',
        password: TestUserData.brokerPassword,
        role: UserRole.broker.name,
        isLoggedIn: false,
        equipment: ['Van', 'Reefer'], loadPosts: [], // Add equipment preferences
      );
      await dbHelper.insertUser(newBrokerUser);
    }
  }
}
