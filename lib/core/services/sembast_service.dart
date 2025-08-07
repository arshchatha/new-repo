import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:lboard/models/load_post.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/models/broker.dart';
import 'package:lboard/core/services/database_interface.dart';
import 'package:path/path.dart' as path;

class SembastService implements DatabaseInterface {
  static final SembastService instance = SembastService._privateConstructor();
  SembastService._privateConstructor();

  late final Database _db;
  final _loadsStore = intMapStoreFactory.store('loads');
  final _usersStore = intMapStoreFactory.store('users');
  final _settingsStore = intMapStoreFactory.store('settings');
  
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      // Web platform - use databaseFactoryWeb with simple database name
      _db = await databaseFactoryWeb.openDatabase('lboard_web.db');
    } else {
      // Non-web platform - use databaseFactoryIo with proper file path
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = path.join(appDir.path, 'lboard.db');
      _db = await databaseFactoryIo.openDatabase(dbPath);
    }
    _isInitialized = true;
  }

  // Load related methods
  @override
  Future<void> insertLoad(LoadPost load) async {
    await init();
    final loadMap = load.toMap();
    loadMap['_id'] = load.id; // Store original ID for reference
    await _loadsStore.add(_db, loadMap);
  }

  // Settings related methods
  Future<void> saveSetting(String key, String value) async {
    await init();
    final finder = Finder(filter: Filter.equals('key', key));
    final record = await _settingsStore.findFirst(_db, finder: finder);
    if (record != null) {
      await _settingsStore.record(record.key).update(_db, {'key': key, 'value': value});
    } else {
      await _settingsStore.add(_db, {'key': key, 'value': value});
    }
  }

  Future<String?> getSetting(String key) async {
    await init();
    final finder = Finder(filter: Filter.equals('key', key));
    final record = await _settingsStore.findFirst(_db, finder: finder);
    if (record != null) {
      final data = Map<String, dynamic>.from(record.value);
      return data['value'] as String?;
    }
    return null;
  }

  @override
  Future<List<LoadPost>> getLoads() async {
    await init();
    final records = await _loadsStore.find(_db);
    return records.map((record) {
      final data = Map<String, dynamic>.from(record.value);
      return LoadPost.fromMap(data);
    }).toList();
  }

  @override
  Future<void> updateLoadBids(String loadId, List<LoadPostQuote> bids) async {
    await init();
    final finder = Finder(filter: Filter.equals('id', loadId));
    final record = await _loadsStore.findFirst(_db, finder: finder);
    
    if (record != null) {
      final bidString = bids.map((b) => '${b.bidder}:${b.amount}').join(';');
      await _loadsStore.record(record.key).update(_db, {'bids': bidString});
    }
  }

  @override
  Future<void> deleteLoad(String id) async {
    await init();
    final finder = Finder(filter: Filter.equals('id', id));
    await _loadsStore.delete(_db, finder: finder);
  }

  @override
  Future<void> updateLoad(LoadPost load) async {
    await init();
    final finder = Finder(filter: Filter.equals('id', load.id));
    final record = await _loadsStore.findFirst(_db, finder: finder);
    
    if (record != null) {
      await _loadsStore.record(record.key).update(_db, load.toMap());
    }
  }

  // User related methods
  @override
  Future<void> insertUser(User user) async {
    await init();
    final userMap = user.toMap();
    userMap['_id'] = user.id; // Store original ID for reference
    
    // Check if user already exists
    final finder = Finder(filter: Filter.equals('id', user.id));
    final existingRecord = await _usersStore.findFirst(_db, finder: finder);
    
    if (existingRecord != null) {
      await _usersStore.record(existingRecord.key).update(_db, userMap);
    } else {
      await _usersStore.add(_db, userMap);
    }
  }

  @override
  Future<User?> getUser(String username) async {
    await init();
    final finder = Finder(filter: Filter.equals('id', username));
    final record = await _usersStore.findFirst(_db, finder: finder);
    
    if (record != null) {
      return User.fromMap(Map<String, dynamic>.from(record.value));
    }
    return null;
  }

  @override
  Future<void> updateUser(User user) async {
    await init();
    final finder = Finder(filter: Filter.equals('id', user.id));
    final record = await _usersStore.findFirst(_db, finder: finder);
    
    if (record != null) {
      await _usersStore.record(record.key).update(_db, user.toMap());
    }
  }

  // Broker related methods
  @override
  Future<List<Map<String, dynamic>>> getAllBrokersRaw() async {
    await init();
    final finder = Finder(filter: Filter.equals('role', 'broker'));
    final records = await _usersStore.find(_db, finder: finder);
    return records.map((record) => Map<String, dynamic>.from(record.value)).toList();
  }

  @override
  Future<List<Broker>> getAllBrokers() async {
    final rawBrokers = await getAllBrokersRaw();
    return rawBrokers.map((map) => Broker.fromMap(map)).toList();
  }

  @override
  Future<void> insertBroker(Broker broker) async {
    await init();
    final brokerMap = broker.toMap();
    brokerMap['_id'] = broker.id; // Store original ID for reference
    
    // Check if broker already exists
    final finder = Finder(filter: Filter.equals('id', broker.id));
    final existingRecord = await _usersStore.findFirst(_db, finder: finder);
    
    if (existingRecord != null) {
      await _usersStore.record(existingRecord.key).update(_db, brokerMap);
    } else {
      await _usersStore.add(_db, brokerMap);
    }
  }

  @override
  Future<void> updateBroker(Broker broker) async {
    await init();
    final finder = Finder(filter: Filter.equals('id', broker.id));
    final record = await _usersStore.findFirst(_db, finder: finder);
    
    if (record != null) {
      await _usersStore.record(record.key).update(_db, broker.toMap());
    }
  }

  @override
  Future<void> deleteBroker(String brokerId) async {
    await init();
    final finder = Finder(filter: Filter.equals('id', brokerId));
    await _usersStore.delete(_db, finder: finder);
  }

  // Generic methods for compatibility
  Future<int> insert(Map<String, dynamic> data) async {
    await init();
    return await _loadsStore.add(_db, data);
  }

  Future<List<RecordSnapshot<int, Map<String, dynamic>>>> getAll() async {
    await init();
    return await _loadsStore.find(_db);
  }

  Future<void> update(int key, Map<String, dynamic> data) async {
    await init();
    await _loadsStore.record(key).update(_db, data);
  }

  Future<void> delete(int key) async {
    await init();
    await _loadsStore.record(key).delete(_db);
  }

  @override
  Future<List<User>> getUsersByUsdotNumber(String usdotNumber) async {
    await init();
    final finder = Finder(filter: Filter.equals('usDotMcNumber', usdotNumber));
    final records = await _usersStore.find(_db, finder: finder);
    return records.map((record) => User.fromMap(Map<String, dynamic>.from(record.value))).toList();
  }
}
