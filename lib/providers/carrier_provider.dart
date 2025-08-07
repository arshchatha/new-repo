import 'package:flutter/material.dart';
import 'package:lboard/models/carrier.dart';
import 'package:lboard/services/api_service.dart';

class CarrierProvider with ChangeNotifier {
  List<Carrier> _carriers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Carrier> get carriers => _carriers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> fetchCarriers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _carriers = await _apiService.fetchCarriers();
    } catch (e) {
      _errorMessage = 'Failed to fetch carriers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}