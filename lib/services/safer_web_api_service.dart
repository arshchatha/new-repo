import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/safer_web_snapshot.dart';

class SaferWebApiService {
  static const String _apiKey = 'a78608806fad40e0b81bd278ebcf178d';
  static const String _baseUrl = 'https://saferwebapi.com/v2';
  final Logger _logger = Logger();

  /// Fetches snapshot data for any identifier (USDOT, MC, MX, or FF)
  Future<SaferWebSnapshot?> fetchSnapshot(String identifier) async {
    try {
      // Clean the identifier
      final cleanIdentifier = identifier.trim().toUpperCase();
      
      // Determine if it's a USDOT number (numeric only) or MC/MX/FF
      final isUsdot = RegExp(r'^[0-9]+$').hasMatch(cleanIdentifier);
      
      final endpoint = isUsdot
          ? '$_baseUrl/usdot/snapshot/$cleanIdentifier'
          : '$_baseUrl/mcmx/snapshot/$cleanIdentifier';

      _logger.i('Fetching data from: $endpoint');

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      _logger.i('Response status: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SaferWebSnapshot.fromJson(data);
      } else if (response.statusCode == 404) {
        _logger.w('No data found for identifier: $identifier');
        return null;
      } else {
        _logger.e('API Error ${response.statusCode}: ${response.body}');
        throw Exception('API Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      _logger.e('Error fetching snapshot for $identifier: $e');
      rethrow;
    }
  }

  /// Validates if an identifier is in the correct format
  bool isValidIdentifier(String identifier) {
    final cleanIdentifier = identifier.trim().toUpperCase();
    
    // USDOT: numeric only
    if (RegExp(r'^[0-9]+$').hasMatch(cleanIdentifier)) {
      return cleanIdentifier.isNotEmpty && cleanIdentifier.length <= 8;
    }
    
    // MC/MX/FF: starts with MC, MX, or FF followed by numbers
    if (RegExp(r'^(MC|MX|FF)[0-9]+$').hasMatch(cleanIdentifier)) {
      return true;
    }
    
    return false;
  }

  /// Gets the identifier type (USDOT, MC, MX, or FF)
  String getIdentifierType(String identifier) {
    final cleanIdentifier = identifier.trim().toUpperCase();
    
    if (RegExp(r'^[0-9]+$').hasMatch(cleanIdentifier)) {
      return 'USDOT';
    } else if (cleanIdentifier.startsWith('MC')) {
      return 'MC';
    } else if (cleanIdentifier.startsWith('MX')) {
      return 'MX';
    } else if (cleanIdentifier.startsWith('FF')) {
      return 'FF';
    }
    
    return 'UNKNOWN';
  }

  /// Batch fetch multiple identifiers
  Future<Map<String, SaferWebSnapshot?>> fetchMultipleSnapshots(List<String> identifiers) async {
    final results = <String, SaferWebSnapshot?>{};
    
    for (final identifier in identifiers) {
      try {
        results[identifier] = await fetchSnapshot(identifier);
        // Add a small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        _logger.e('Error fetching $identifier: $e');
        results[identifier] = null;
      }
    }
    
    return results;
  }

  static Future fetchSaferWebSnapshot(String id) async {}
}
