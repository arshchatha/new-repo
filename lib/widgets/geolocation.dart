import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'location.dart';

// We use the OpenStreetMap API for geocoding and reverse geocoding
Future<dynamic> makeOpenStreetMapRequest({
  required String path,
  Map<String, dynamic>? queryParams,
}) async {
  try {
    if (queryParams != null) {
      queryParams = queryParams.map((key, value) => MapEntry(key, value.toString()));
    }

    final language = Intl.getCurrentLocale().split('_').first;

    final request = http.Request(
        'GET',
        Uri.https('nominatim.openstreetmap.org', path, {
          if (queryParams != null) ...queryParams,
          'format': 'geojson',
          'addressdetails': '1',
          'accept-language': language,
        }))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'MyApp/1.0 (https://my.app)',
      })
      ..followRedirects = false
      ..persistentConnection = false;

    final streamedResponse = await request.send().timeout(const Duration(seconds: 5), onTimeout: () {
      throw TimeoutException('Request timed out');
    });

    final http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final contentType = response.headers['content-type'] != null
          ? ContentType.parse(response.headers['content-type']!)
          : null;
      if (contentType?.mimeType == 'application/json') {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('error')) {
          throw Exception("Server error: ${data['error']}");
        } else {
          return data;
        }
      }
    } else {
      throw HttpException('Server error: \${response.statusCode}');
    }
  } on TimeoutException {
    throw Exception('Request timed out');
  } on SocketException {
    throw Exception('No internet connection');
  } on HttpException {
    throw Exception('Request error: HttpException');
  } on FormatException {
    throw Exception('Bad response format');
  } catch (error) {
    throw Exception('Error: \$error');
  }
}

Future<List<Location>> searchLocation(String query) async {
  try {
    final data = await makeOpenStreetMapRequest(
      path: 'search',
      queryParams: {
        'q': query,
        'limit': 10,
      },
    );
    if (data is Map && data.containsKey('features')) {
      final results = List<Map<String, dynamic>>.from(data['features'])
          .map((result) => Location.fromGeoJson(result))
          .toList();
      return results;
    } else {
      return [];
    }
  } catch (error) {
    throw Exception('Error searching for location: \$error');
  }
}

Future<Location?> getLocationByCoordinates({
  required double latitude,
  required double longitude,
}) async {
  try {
    final data = await makeOpenStreetMapRequest(
      path: 'reverse',
      queryParams: {
        'lat': latitude,
        'lon': longitude,
      },
    );
    if (data is Map && data.containsKey('features')) {
      final results = List<Map<String, dynamic>>.from(data['features']);
      if (results.isNotEmpty) {
        return Location.fromGeoJson(results.first);
      }
    }
    return null;
  } catch (error) {
    throw Exception('Error getting location from coordinates: \$error');
  }
}

Future<Location?> getLocationByLocale() async {
  try {
    final countryCode = Intl.getCurrentLocale().split('_').last;
    final data = await makeOpenStreetMapRequest(
      path: 'search',
      queryParams: {
        'country': countryCode,
      },
    );
    if (data is Map && data.containsKey('features')) {
      final results = List<Map<String, dynamic>>.from(data['features']);
      if (results.isNotEmpty) {
        return Location.fromGeoJson(results.first);
      }
    }
    return null;
  } catch (error) {
    throw Exception('Error getting location from country code: \$error');
  }
}

Future<Location> getCurrentLocation() async {
  bool locationServiceEnabled;
  LocationPermission locationPermission;

  locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!locationServiceEnabled) {
    return Future.error('Location services are disabled.');
  }

  locationPermission = await Geolocator.checkPermission();
  if (locationPermission == LocationPermission.denied) {
    locationPermission = await Geolocator.requestPermission();
    if (locationPermission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }

  if (locationPermission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are denied permanently. Please enable them in settings.');
  }

  try {
    final Position position = await Geolocator.getCurrentPosition();
    final Location? location = await getLocationByCoordinates(
        latitude: position.latitude, longitude: position.longitude);
    if (location != null) {
      return location;
    } else {
      return Location(latitude: position.latitude, longitude: position.longitude);
    }
  } catch (error) {
    throw Exception('Error getting current location: \$error');
  }
}

Future<Location?> getLastKnownLocation() async {
  try {
    final Position? position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      final Location? location = await getLocationByCoordinates(
          latitude: position.latitude, longitude: position.longitude);
      return location;
    } else {
      return null;
    }
  } catch (error) {
    return null;
  }
}
