import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lboard/models/carrier.dart';
import '../models/leaderboard_entry.dart';

class ApiService {
  final String _baseUrl = 'https://api.example.com'; // Replace with your API base URL

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('$_baseUrl/leaderboard'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }

  Future<List<Carrier>> fetchCarriers() async {
    final response = await http.get(Uri.parse('$_baseUrl/carriers'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((carrier) => Carrier.fromJson(carrier)).toList();
    } else {
      throw Exception('Failed to load carriers');
    }
  }
}
