import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AnalyticsApiService {
  static const String baseUrl = 'https://api.yourbackend.com/api/v1';
  final String authToken;

  AnalyticsApiService({required this.authToken});

  // Headers for API calls
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };

  /// Search users by USDOT or MC number
  Future<List<User>> searchUsers({
    String? dotNumber,
    String? mcNumber,
    String? companyName,
    String? location,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, String>{};
      if (dotNumber != null && dotNumber.isNotEmpty) {
        params['dot_number'] = dotNumber;
      }
      if (mcNumber != null && mcNumber.isNotEmpty) {
        params['mc_number'] = mcNumber;
      }
      if (companyName != null && companyName.isNotEmpty) {
        params['company_name'] = companyName;
      }
      if (location != null && location.isNotEmpty) {
        params['location'] = location;
      }
      params['limit'] = limit.toString();
      params['offset'] = offset.toString();

      final uri = Uri.parse('$baseUrl/users/search').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['users'] as List).map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to search users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  /// Get user analytics data
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/analytics');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get user analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user analytics: $e');
    }
  }

  /// Get lane rate insights
  Future<List<Map<String, dynamic>>> getLaneRates({
    required String origin,
    required String destination,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 100,
  }) async {
    try {
      final params = <String, String>{
        'origin': origin,
        'destination': destination,
        'limit': limit.toString(),
      };

      if (dateFrom != null) {
        params['date_from'] = dateFrom.toIso8601String();
      }
      if (dateTo != null) {
        params['date_to'] = dateTo.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl/analytics/lane-rates').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['rates']);
      } else {
        throw Exception('Failed to get lane rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting lane rates: $e');
    }
  }

  /// Get market trends
  Future<Map<String, dynamic>> getMarketTrends({
    String? region,
    String? equipmentType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final params = <String, String>{};
      if (region != null) params['region'] = region;
      if (equipmentType != null) params['equipment_type'] = equipmentType;
      if (dateFrom != null) params['date_from'] = dateFrom.toIso8601String();
      if (dateTo != null) params['date_to'] = dateTo.toIso8601String();

      final uri = Uri.parse('$baseUrl/analytics/market-trends').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get market trends: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting market trends: $e');
    }
  }

  /// Get user's load posts with analytics
  Future<List<Map<String, dynamic>>> getUserLoadPosts(String userId, {int limit = 50, int offset = 0}) async {
    try {
      final params = {
        'user_id': userId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      final uri = Uri.parse('$baseUrl/loads/user').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['loads']);
      } else {
        throw Exception('Failed to get user loads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user loads: $e');
    }
  }

  /// Get broker sales records
  Future<List<Map<String, dynamic>>> getBrokerSales({
    String? brokerId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 100,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
      };
      
      if (brokerId != null) params['broker_id'] = brokerId;
      if (dateFrom != null) params['date_from'] = dateFrom.toIso8601String();
      if (dateTo != null) params['date_to'] = dateTo.toIso8601String();

      final uri = Uri.parse('$baseUrl/analytics/broker-sales').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['sales']);
      } else {
        throw Exception('Failed to get broker sales: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting broker sales: $e');
    }
  }

  /// Get carrier sales records
  Future<List<Map<String, dynamic>>> getCarrierSales({
    String? carrierId,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 100,
  }) async {
    try {
      final params = <String, String>{
        'limit': limit.toString(),
      };
      
      if (carrierId != null) params['carrier_id'] = carrierId;
      if (dateFrom != null) params['date_from'] = dateFrom.toIso8601String();
      if (dateTo != null) params['date_to'] = dateTo.toIso8601String();

      final uri = Uri.parse('$baseUrl/analytics/carrier-sales').replace(queryParameters: params);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['sales']);
      } else {
        throw Exception('Failed to get carrier sales: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting carrier sales: $e');
    }
  }
}
