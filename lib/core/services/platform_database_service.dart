import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lboard/core/services/database_interface.dart';
import 'package:lboard/core/core/database/database_helper.dart';
import 'package:lboard/core/services/sembast_service.dart';
import 'package:lboard/models/load_post.dart';
import 'package:lboard/models/user.dart';
import 'package:lboard/models/broker.dart';

class PlatformDatabaseService implements DatabaseInterface {
  static final PlatformDatabaseService instance = PlatformDatabaseService._privateConstructor();
  PlatformDatabaseService._privateConstructor();

  late final DatabaseInterface _implementation;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (!_isInitialized) {
      _implementation = kIsWeb 
          ? SembastService.instance as DatabaseInterface 
          : DatabaseHelper.instance as DatabaseInterface;
      await _implementation.init();
      _isInitialized = true;
    }
  }

  @override
  Future<void> insertLoad(LoadPost load) async {
    await _implementation.insertLoad(load);
  }

  @override
  Future<List<LoadPost>> getLoads() async {
    return await _implementation.getLoads();
  }

  @override
  Future<void> updateLoadBids(String loadId, List<LoadPostQuote> bids) async {
    await _implementation.updateLoadBids(loadId, bids);
  }

  @override
  Future<void> deleteLoad(String id) async {
    await _implementation.deleteLoad(id);
  }

  @override
  Future<void> updateLoad(LoadPost load) async {
    await _implementation.updateLoad(load);
  }

  @override
  Future<void> insertUser(User user) async {
    await _implementation.insertUser(user);
  }

  @override
  Future<User?> getUser(String username) async {
    return await _implementation.getUser(username);
  }

  @override
  Future<void> updateUser(User user) async {
    await _implementation.updateUser(user);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllBrokersRaw() async {
    return await _implementation.getAllBrokersRaw();
  }

  @override
  Future<List<Broker>> getAllBrokers() async {
    return await _implementation.getAllBrokers();
  }

  @override
  Future<void> insertBroker(Broker broker) async {
    await _implementation.insertBroker(broker);
  }

  @override
  Future<void> updateBroker(Broker broker) async {
    await _implementation.updateBroker(broker);
  }

  @override
  Future<void> deleteBroker(String brokerId) async {
    await _implementation.deleteBroker(brokerId);
  }

  @override
  Future<List<User>> getUsersByUsdotNumber(String usdotNumber) async {
    return await _implementation.getUsersByUsdotNumber(usdotNumber);
  }
}
