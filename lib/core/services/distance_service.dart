import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'haversine_distance_service.dart';

class DistanceService {
  final String _apiKey = 'AIzaSyCWht0kEJMXOEHaUjNlERQEz9iVUS6cN2o';
  final Logger _logger = Logger();
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Get route with enhanced error handling and fallback mechanisms
  Future<Map<String, dynamic>?> getRoute(LatLng origin, LatLng dest) async {
    // Validate input coordinates
    if (!_isValidCoordinate(origin) || !_isValidCoordinate(dest)) {
      _logger.w('Invalid coordinates provided: origin=$origin, dest=$dest');
      return _getFallbackDistance(origin, dest);
    }

    // Try Google Directions API with retry mechanism
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final result = await _getRouteFromAPI(origin, dest);
        if (result != null) {
          _logger.d('Successfully got route from Google API on attempt $attempt');
          return result;
        }
      } catch (e) {
        _logger.w('Attempt $attempt failed for Google Directions API: $e');
        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay);
        }
      }
    }

    // Fallback to Haversine calculation
    _logger.i('Google API failed, using fallback Haversine calculation');
    return _getFallbackDistance(origin, dest);
  }

  /// Get route from Google Directions API
  Future<Map<String, dynamic>?> _getRouteFromAPI(LatLng origin, LatLng dest) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${dest.latitude},${dest.longitude}'
      '&key=$_apiKey'
    );

    final res = await http.get(url).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('API request timeout'),
    );

    if (res.statusCode != 200) {
      throw Exception('API returned status code: ${res.statusCode}');
    }

    final data = json.decode(res.body);
    
    // Check for API errors
    if (data['status'] != 'OK') {
      throw Exception('API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
    }

    if ((data['routes'] as List).isEmpty) {
      throw Exception('No routes found between the locations');
    }

    final route = data['routes'][0];
    final leg = route['legs'][0];
    
    // Validate response data
    if (leg['distance'] == null || leg['duration'] == null) {
      throw Exception('Invalid route data received from API');
    }

    try {
      final polyline = route['overview_polyline']['points'];
      final poly = PolylinePoints().decodePolyline(polyline)
          .map((e) => LatLng(e.latitude, e.longitude)).toList();

      return {
        'distanceText': leg['distance']['text'],
        'distanceValue': leg['distance']['value'], // meters
        'durationText': leg['duration']['text'],
        'durationValue': leg['duration']['value'], // seconds
        'points': poly,
        'source': 'google_api',
      };
    } catch (e) {
      // If polyline parsing fails, still return basic distance info
      _logger.w('Failed to parse polyline, returning basic distance info: $e');
      return {
        'distanceText': leg['distance']['text'],
        'distanceValue': leg['distance']['value'],
        'durationText': leg['duration']['text'],
        'durationValue': leg['duration']['value'],
        'points': <LatLng>[],
        'source': 'google_api',
      };
    }
  }

  /// Fallback distance calculation using Haversine formula
  Map<String, dynamic> _getFallbackDistance(LatLng origin, LatLng dest) {
    final distanceKm = HaversineDistanceService.calculateDistance(
      origin.latitude,
      origin.longitude,
      dest.latitude,
      dest.longitude,
    );

    final distanceMiles = HaversineDistanceService.calculateDistanceInMiles(
      origin.latitude,
      origin.longitude,
      dest.latitude,
      dest.longitude,
    );

    // Estimate duration based on average speed (assuming 60 mph / 96 km/h)
    final estimatedHours = distanceKm / 96.0;
    final estimatedMinutes = (estimatedHours * 60).round();

    return {
      'distanceText': '${distanceKm.toStringAsFixed(1)} km (${distanceMiles.toStringAsFixed(1)} mi)',
      'distanceValue': (distanceKm * 1000).round(), // convert to meters
      'durationText': _formatDuration(estimatedMinutes),
      'durationValue': estimatedMinutes * 60, // convert to seconds
      'points': <LatLng>[origin, dest],
      'source': 'haversine_fallback',
      'isEstimate': true,
    };
  }

  /// Validate coordinate values
  bool _isValidCoordinate(LatLng coord) {
    return coord.latitude.abs() <= 90.0 && 
           coord.longitude.abs() <= 180.0 &&
           !coord.latitude.isNaN && 
           !coord.longitude.isNaN &&
           !coord.latitude.isInfinite && 
           !coord.longitude.isInfinite;
  }

  /// Format duration in a human-readable format
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $remainingMinutes min';
      }
    }
  }

  /// Calculate rate based on distance
  double calculateRate(double distanceKm, double perKmRate) {
    return distanceKm * perKmRate;
  }

  /// Get distance in different units
  Map<String, double> getDistanceInUnits(double distanceMeters) {
    return {
      'meters': distanceMeters,
      'kilometers': distanceMeters / 1000,
      'miles': distanceMeters / 1609.34,
    };
  }
}
