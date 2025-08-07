import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  final String apiKey;

  GooglePlacesService(this.apiKey);

  Future<List<Map<String, dynamic>>> getPlaceAutocomplete(String input) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&types=establishment'
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return List<Map<String, dynamic>>.from(data['predictions']);
      } else {
        throw Exception('Google Places API error: ${data['status']}');
      }
    } else {
      throw Exception('Failed to fetch place autocomplete');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=name,formatted_address,geometry'
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return data['result'];
      } else {
        throw Exception('Google Places API error: ${data['status']}');
      }
    } else {
      throw Exception('Failed to fetch place details');
    }
  }
}
