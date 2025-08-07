import 'package:flutter/material.dart';
import 'package:lboard/models/broker.dart';
import 'package:lboard/services/broker_service.dart';

class BrokerProvider with ChangeNotifier {
  List<Broker> _brokers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Broker> get brokers => _brokers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final BrokerService _brokerService = BrokerService();

  Future<void> fetchBrokers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _brokers = await _brokerService.getBrokers();
    } catch (e) {
      _errorMessage = 'Failed to fetch brokers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
