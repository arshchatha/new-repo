import 'package:flutter_test/flutter_test.dart';
import 'package:lboard/models/user.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lboard/core/core/database/database_helper.dart';

void main() {
  // Initialize FFI for sqflite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Distance Radius Limit Tests', () {
    late DatabaseHelper dbHelper;
    late Database db;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      db = await openDatabase(inMemoryDatabasePath, version: 8,
          onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            phoneNumber TEXT,
            address TEXT,
            companyName TEXT,
            companyAddress TEXT,
            companyPhoneNumber TEXT,
            companyEmail TEXT,
            companyWebsite TEXT,
            companyLogoUrl TEXT,
            companyTaxId TEXT,
            role TEXT,
            companyId TEXT,
            isLoggedIn INTEGER,
            password TEXT,
            usDotMcNumber TEXT,
            firstName TEXT,
            lastName TEXT,
            addressLine1 TEXT,
            addressLine2 TEXT,
            country TEXT,
            stateProvince TEXT,
            city TEXT,
            postalZipCode TEXT,
            website TEXT,
            portOfEntry TEXT,
            currency TEXT,
            factoringCompany TEXT,
            paymentMethod TEXT,
            account TEXT,
            syncToQB TEXT,
            remarks TEXT,
            phoneExt TEXT,
            altPhoneNumber TEXT,
            altPhoneExt TEXT,
            faxNumber TEXT,
            referenceNumber TEXT,
            type TEXT,
            expenseType TEXT,
            equipment TEXT,
            loadType TEXT,
            lanePreferences TEXT,
            distanceRadiusLimit INTEGER
          )
        ''');
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('Test CRUD operations with distanceRadiusLimit', () async {
      final testUser = User(
        id: 'test_carrier',
        name: 'Test Carrier',
        email: 'test@example.com',
        phoneNumber: '123-456-7890',
        companyName: 'Test Company',
        companyAddress: '123 Test St',
        role: 'carrier',
        password: 'password123',
        usDotMcNumber: 'MC123456',
        addressLine1: '123 Main St',
        city: 'Test City',
        stateProvince: 'TS',
        postalZipCode: '12345',
        country: 'USA',
        distanceRadiusLimit: 250, loadPosts: [],
      );

      // Create
      await dbHelper.insertUser(testUser);

      // Read
      final retrievedUser = await dbHelper.getUser('test_carrier');
      expect(retrievedUser, isNotNull);
      expect(retrievedUser?.distanceRadiusLimit, equals(250));

      // Update
      final updatedUser = testUser.copyWith(distanceRadiusLimit: 300);
      await dbHelper.updateUser(updatedUser);
      
      final retrievedUpdatedUser = await dbHelper.getUser('test_carrier');
      expect(retrievedUpdatedUser?.distanceRadiusLimit, equals(300));
    });

    test('Test database migration adds distanceRadiusLimit column', () async {
      // Create a v7 database
      final dbPath = inMemoryDatabasePath;
      if (await databaseExists(dbPath)) {
        await deleteDatabase(dbPath);
      }

      await openDatabase(dbPath, version: 7,
          onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            phoneNumber TEXT,
            address TEXT,
            companyName TEXT,
            companyAddress TEXT,
            role TEXT,
            password TEXT,
            usDotMcNumber TEXT,
            equipment TEXT,
            loadType TEXT,
            lanePreferences TEXT
          )
        ''');
      });

      // Reopen with the main helper, which should trigger onUpgrade
      final dbV8 = await dbHelper.initDB();
      final tableInfo = await dbV8.rawQuery('PRAGMA table_info(users)');
      
      // Check if the new column exists
      expect(tableInfo.any((col) => col['name'] == 'distanceRadiusLimit'), isTrue);
      
      await dbV8.close();
    });
  });
}
