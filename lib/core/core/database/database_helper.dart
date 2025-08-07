import 'package:lboard/models/broker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:lboard/models/load_post.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/models/chat_message.dart';
import 'package:lboard/core/services/database_interface.dart';

class DatabaseHelper implements DatabaseInterface {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  static Database? _database;

  @override
  Future<void> init() async {
    _database ??= await initDB();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'load_board.db');

    return await openDatabase(
      path,
      version: 15,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE loads (
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            pickupDate TEXT,
            deliveryDate TEXT,
            weight TEXT,
            dimensions TEXT,
            rate TEXT,
            origin TEXT,
            destination TEXT,
            isBrokerPost INTEGER,
            isCarrierPost INTEGER,
            postedBy TEXT,
            bids TEXT,
            equipment TEXT,
            contactEmail TEXT,
            contactPhone TEXT,
            loadType TEXT,
            country TEXT,
            pickupLatitude REAL,
            pickupLongitude REAL,
            destinationLatitude REAL,
            destinationLongitude REAL,
            originRadius REAL,
            destinationRadius REAL,
            distance TEXT,
            contactPerson TEXT,
            contactAddress TEXT,
            postedByName TEXT,
            destinationDifference TEXT,
            status TEXT,
            safetyRating TEXT,
            originCity TEXT,
            originCountry TEXT,
            originState TEXT,
            originPostalCode TEXT,
            originDescription TEXT,
            destinationCity TEXT,
            destinationCountry TEXT,
            destinationState TEXT,
            destinationPostalCode TEXT,
            destinationDescription TEXT,
            pickupTime TEXT,
            deliveryTime TEXT,
            appointment INTEGER DEFAULT 0,
            createdAt TEXT,
            updatedAt TEXT,
            isActive INTEGER DEFAULT 1,
            volume INTEGER DEFAULT 0,
            isbroken INTEGER DEFAULT 0,
            isbooked INTEGER DEFAULT 0,
            selectedBidId TEXT,
            brokerConfirmed INTEGER DEFAULT 0,
            carrierConfirmed INTEGER DEFAULT 0
          )
        ''');

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
            contactPerson TEXT,
            lanePreferences TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE chat_messages (
            id TEXT PRIMARY KEY,
            senderId TEXT,
            senderName TEXT,
            recipientId TEXT,
            recipientName TEXT,
            message TEXT,
            timestamp TEXT,
            isRead INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE loads ADD COLUMN loadType TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE loads ADD COLUMN pickupLatitude REAL');
          await db.execute('ALTER TABLE loads ADD COLUMN pickupLongitude REAL');
          await db.execute('ALTER TABLE loads ADD COLUMN destinationLatitude REAL');
          await db.execute('ALTER TABLE loads ADD COLUMN destinationLongitude REAL');
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE loads ADD COLUMN distance REAL');
          await db.execute('ALTER TABLE loads ADD COLUMN destinationDifference REAL');
          await db.execute('ALTER TABLE loads ADD COLUMN status TEXT');
        }
        if (oldVersion < 7) {
          // Add new columns to users table
          await db.execute('ALTER TABLE users ADD COLUMN lanePreferences TEXT');
          await db.execute('ALTER TABLE users ADD COLUMN loadType TEXT');
        }
        if (oldVersion < 8) {
          // Add distance radius limit column to users table
          await db.execute('ALTER TABLE users ADD COLUMN distanceRadiusLimit INTEGER');
        }
      if (oldVersion < 9) {
        // Add radius columns to loads table
        await db.execute('ALTER TABLE loads ADD COLUMN originRadius INTEGER');
        await db.execute('ALTER TABLE loads ADD COLUMN destinationRadius INTEGER');
      }
      if (oldVersion < 10) {
        // Add safer snapshot columns to users table
        await db.execute('ALTER TABLE users ADD COLUMN safer_legal_name TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN safer_entity_type TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN safer_status TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN safer_address TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN safer_usdot_number TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN safer_mc_number TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN safer_power_units INTEGER');
        await db.execute('ALTER TABLE users ADD COLUMN safer_drivers INTEGER');
        await db.execute('ALTER TABLE users ADD COLUMN safer_usdot_status TEXT');
      }
      if (oldVersion < 11) {
        // Add contactPerson and other missing columns to loads table
        await db.execute('ALTER TABLE loads ADD COLUMN contactPerson TEXT');
        await db.execute('ALTER TABLE loads ADD COLUMN contactAddress TEXT');
        await db.execute('ALTER TABLE loads ADD COLUMN postedByName TEXT');
        await db.execute('ALTER TABLE loads ADD COLUMN destinationDifference TEXT');
        await db.execute('ALTER TABLE loads ADD COLUMN status TEXT');
        await db.execute('ALTER TABLE loads ADD COLUMN safetyRating TEXT');
        
        // Add detailed location columns
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN originCity TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN originCountry TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN originState TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN originPostalCode TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN originDescription TEXT');
          
          await db.execute('ALTER TABLE loads ADD COLUMN destinationCity TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN destinationCountry TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN destinationState TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN destinationPostalCode TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN destinationDescription TEXT');
          
          await db.execute('ALTER TABLE loads ADD COLUMN pickupTime TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN deliveryTime TEXT');
          await db.execute('ALTER TABLE loads ADD COLUMN appointment INTEGER DEFAULT 0');
        } catch (e) {
          // Columns might already exist, ignore error
        }
      }
      if (oldVersion < 12) {
        // Ensure all required columns exist
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN originCity TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN originCountry TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN originState TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN originPostalCode TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN originDescription TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN destinationCity TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN destinationCountry TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN destinationState TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN destinationPostalCode TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN destinationDescription TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN pickupTime TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN deliveryTime TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN appointment INTEGER DEFAULT 0');
        } catch (e) {
          // Column already exists, ignore error
        }
      }
      if (oldVersion < 13) {
        // Add missing timestamp and status columns
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN createdAt TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN updatedAt TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN isActive INTEGER DEFAULT 1');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN volume INTEGER DEFAULT 0');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN isbroken INTEGER DEFAULT 0');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN isbooked INTEGER DEFAULT 0');
        } catch (e) {
          // Column already exists, ignore error
        }
      }
      if (oldVersion < 14) {
        // Add carrier confirmation columns
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN selectedBidId TEXT');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN brokerConfirmed INTEGER DEFAULT 0');
        } catch (e) {
          // Column already exists, ignore error
        }
        try {
          await db.execute('ALTER TABLE loads ADD COLUMN carrierConfirmed INTEGER DEFAULT 0');
        } catch (e) {
          // Column already exists, ignore error
        }
      }
      },
    );
  }

  // Load related methods
  @override
  Future<void> insertLoad(LoadPost load) async {
    final db = await database;
    await db.insert('loads', load.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<LoadPost>> getLoads() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('loads');
    return List.generate(maps.length, (i) {
      return LoadPost.fromMap(maps[i]);
    });
  }

  @override
  Future<void> updateLoadBids(String loadId, List<LoadPostQuote> bids) async {
    final db = await database;
    final bidString = bids.map((b) => '${b.bidder}:${b.amount}').join(';');
    await db.update(
      'loads',
      {'bids': bidString},
      where: 'id = ?',
      whereArgs: [loadId],
    );
  }

  @override
  Future<void> deleteLoad(String id) async {
    final db = await database;
    await db.delete('loads', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> updateLoad(LoadPost load) async {
    final db = await database;
    await db.update(
      'loads',
      load.toMap(),
      where: 'id = ?',
      whereArgs: [load.id],
    );
  }

  // Broker related methods
  @override
  Future<List<Map<String, dynamic>>> getAllBrokersRaw() async {
    final db = await database;
    return await db.query('users', where: "role = ?", whereArgs: ['broker']);
  }

  // Chat message related methods
  Future<void> insertMessage(ChatMessage message) async {
    final db = await database;
    await db.insert(
      'chat_messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> getMessagesBetweenUsers(String userId1, String userId2) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_messages',
      where: '(senderId = ? AND recipientId = ?) OR (senderId = ? AND recipientId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));
  }

  @override
  Future<List<Broker>> getAllBrokers() async {
    final rawBrokers = await getAllBrokersRaw();
    return rawBrokers.map((map) => Broker.fromMap(map)).toList();
  }

  @override
  Future<void> insertBroker(Broker broker) async {
    final db = await database;
    await db.insert('users', broker.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateBroker(Broker broker) async {
    final db = await database;
    await db.update('users', broker.toMap(), where: 'id = ?', whereArgs: [broker.id]);
  }

  @override
  Future<void> deleteBroker(String brokerId) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [brokerId]);
  }

  // User related methods
  @override
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<User?> getUser(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<List<User>> getUsersByUsdotNumber(String usdotNumber) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'usDotMcNumber = ?',
      whereArgs: [usdotNumber],
    );
    return result.map((map) => User.fromMap(map)).toList();
  }

  // Add rawQuery method for distance calculations
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}
