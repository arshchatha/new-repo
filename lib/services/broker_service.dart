import 'package:flutter/material.dart';
import 'package:lboard/models/broker.dart';
import 'package:lboard/core/services/platform_database_service.dart';

class BrokerService extends ChangeNotifier {
  final PlatformDatabaseService _dbHelper = PlatformDatabaseService.instance;

  List<Broker> _brokers = [];
  List<Broker> get brokers => _brokers;

  Future<List<Broker>> getBrokers() async {
    try {
      await _dbHelper.init();
      _brokers = await _dbHelper.getAllBrokers();
      notifyListeners();
      return _brokers;
    } catch (e) {
      debugPrint('Error fetching brokers: $e');
      return [];
    }
  }

  Future<bool> addBroker(Broker broker) async {
    try {
      await _dbHelper.init();
      await _dbHelper.insertBroker(broker);
      _brokers.add(broker);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding broker: $e');
      return false;
    }
  }

  Future<bool> updateBroker(Broker broker) async {
    try {
      await _dbHelper.init();
      await _dbHelper.updateBroker(broker);
      int index = _brokers.indexWhere((b) => b.id == broker.id);
      if (index != -1) {
        _brokers[index] = broker;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating broker: $e');
      return false;
    }
  }

  Future<bool> deleteBroker(String brokerId) async {
    try {
      await _dbHelper.init();
      await _dbHelper.deleteBroker(brokerId);
      _brokers.removeWhere((b) => b.id == brokerId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting broker: $e');
      return false;
    }
  }
}
