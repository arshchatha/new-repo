import 'package:flutter_test/flutter_test.dart';
import 'package:lboard/core/core/database/database_helper.dart';
import 'package:lboard/models/load_post.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI for sqflite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;
    late Database db;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      // Use an in-memory database for testing
      db = await openDatabase(inMemoryDatabasePath, version: 1,
          onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE loads (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            pickupDate TEXT,
            deliveryDate TEXT,
            country TEXT,
            weight TEXT,
            dimensions TEXT,
            rate TEXT,
            origin TEXT,
            destination TEXT,
            isBrokerPost INTEGER,
            postedBy TEXT,
            bids TEXT,
            equipment TEXT,
            contactEmail TEXT,
            contactPhone TEXT,
            loadType TEXT
          )
        ''');
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('Test Database Migration from v5 to v6', () async {
      // Simulate upgrading from a version before the new columns were added
      final dbPath = inMemoryDatabasePath;
      if (await databaseExists(dbPath)) {
        await deleteDatabase(dbPath);
      }

      // Create a v5 database
      await openDatabase(dbPath, version: 5,
          onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE loads (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            pickupDate TEXT,
            deliveryDate TEXT,
            country TEXT,
            weight TEXT,
            dimensions TEXT,
            rate TEXT,
            origin TEXT,
            destination TEXT,
            isBrokerPost INTEGER,
            postedBy TEXT,
            bids TEXT,
            equipment TEXT,
            contactEmail TEXT,
            contactPhone TEXT,
            loadType TEXT,
            pickupLatitude REAL,
            pickupLongitude REAL,
            destinationLatitude REAL,
            destinationLongitude REAL
          )
        ''');
      });

      // Reopen with the main helper, which should trigger onUpgrade
      final dbV6 = await dbHelper.initDB();
      final tableInfo = await dbV6.rawQuery('PRAGMA table_info(loads)');
      
      // Check if the new columns exist
      expect(tableInfo.any((col) => col['name'] == 'distance'), isTrue);
      expect(tableInfo.any((col) => col['name'] == 'destinationDifference'), isTrue);
      expect(tableInfo.any((col) => col['name'] == 'status'), isTrue);
      
      await dbV6.close();
    });

    test('Test CRUD operations for Loads', () async {
      final testLoad = LoadPost(
        id: 'test_load_1',
        title: 'Test Load',
        description: 'A load for testing purposes',
        pickupDate: '2023-01-01',
        deliveryDate: '2023-01-02',
        country: 'USA',
        weight: '10000',
        dimensions: '10x10x10',
        rate: '1500.0',
        origin: 'City A',
        destination: 'City B',
        isBrokerPost: true,
        postedBy: 'broker1',
        bids: [],
        equipment: ['Van'],
        loadType: 'Full',
        pickupLatitude: 34.0522,
        pickupLongitude: -118.2437,
        destinationLatitude: 36.1699,
        destinationLongitude: -115.1398,
        isCarrierPost: false,
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
      testLoad.contactEmail = 'test@example.com';
      testLoad.contactPhone = '123-456-7890';
      testLoad.distance = '270.5';
      testLoad.destinationDifference = '10.2';
      testLoad.status = 'Pending';

      // Create
      await dbHelper.insertLoad(testLoad);

      // Read
      List<LoadPost> loads = await dbHelper.getLoads();
      expect(loads.length, 1);
      expect(loads.first.title, 'Test Load');
      expect(loads.first.status, 'Pending');

      // Update
      final updatedLoad = testLoad.copyWith(status: 'In-Transit');
      await dbHelper.updateLoad(updatedLoad);
      loads = await dbHelper.getLoads();
      expect(loads.first.status, 'In-Transit');

      // Delete
      await dbHelper.deleteLoad(testLoad.id);
      loads = await dbHelper.getLoads();
      expect(loads.isEmpty, isTrue);
    });
  });
}
