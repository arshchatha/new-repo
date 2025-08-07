import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/safer_web_snapshot.dart';
import '../services/safer_web_api_service.dart';

class SaferWebProvider extends ChangeNotifier {
  final SaferWebApiService _apiService = SaferWebApiService();
  final Logger _logger = Logger();
  
  // Cache for snapshots
  final Map<String, SaferWebSnapshot> _snapshotCache = {};
  
  // Loading states
  final Map<String, bool> _loadingStates = {};
  
  // Error states
  final Map<String, String?> _errorStates = {};

  // Getters
  bool isLoading(String identifier) => _loadingStates[identifier] ?? false;
  String? getError(String identifier) => _errorStates[identifier];
  SaferWebSnapshot? getSnapshot(String identifier) => _snapshotCache[identifier];

  /// Fetch a snapshot for a given identifier
  Future<SaferWebSnapshot?> fetchSnapshot(String identifier) async {
    try {
      // Check if we already have it cached
      if (_snapshotCache.containsKey(identifier)) {
        return _snapshotCache[identifier];
      }

      // Validate identifier format
      if (!_apiService.isValidIdentifier(identifier)) {
        throw Exception('Invalid identifier format');
      }

      // Set loading state
      _loadingStates[identifier] = true;
      _errorStates[identifier] = null;
      notifyListeners();

      // Fetch the snapshot
      final snapshot = await _apiService.fetchSnapshot(identifier);
      
      if (snapshot != null) {
        _snapshotCache[identifier] = snapshot;
      }

      _loadingStates[identifier] = false;
      notifyListeners();

      return snapshot;
    } catch (e) {
      _logger.e('Error fetching snapshot for $identifier: $e');
      _loadingStates[identifier] = false;
      _errorStates[identifier] = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Fetch multiple snapshots at once
  Future<Map<String, SaferWebSnapshot?>> fetchMultipleSnapshots(List<String> identifiers) async {
    try {
      // Filter out invalid identifiers
      final validIdentifiers = identifiers.where(_apiService.isValidIdentifier).toList();
      
      if (validIdentifiers.isEmpty) {
        throw Exception('No valid identifiers provided');
      }

      // Set loading states
      for (final id in validIdentifiers) {
        _loadingStates[id] = true;
        _errorStates[id] = null;
      }
      notifyListeners();

      // Fetch snapshots
      final results = await _apiService.fetchMultipleSnapshots(validIdentifiers);
      
      // Update cache and states
      results.forEach((id, snapshot) {
        _loadingStates[id] = false;
        if (snapshot != null) {
          _snapshotCache[id] = snapshot;
        }
      });

      notifyListeners();
      return results;
    } catch (e) {
      _logger.e('Error fetching multiple snapshots: $e');
      // Reset loading states
      for (final id in identifiers) {
        _loadingStates[id] = false;
        _errorStates[id] = e.toString();
      }
      notifyListeners();
      return {};
    }
  }

  /// Clear cache for a specific identifier
  void clearCache(String identifier) {
    _snapshotCache.remove(identifier);
    _loadingStates.remove(identifier);
    _errorStates.remove(identifier);
    notifyListeners();
  }

  /// Clear all cached data
  void clearAllCache() {
    _snapshotCache.clear();
    _loadingStates.clear();
    _errorStates.clear();
    notifyListeners();
  }

  /// Get identifier type (USDOT, MC, MX, or FF)
  String getIdentifierType(String identifier) {
    return _apiService.getIdentifierType(identifier);
  }

  /// Check if an identifier is valid
  bool isValidIdentifier(String identifier) {
    return _apiService.isValidIdentifier(identifier);
  }
}
