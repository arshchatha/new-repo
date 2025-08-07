import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'geolocation.dart' as geolocation;
import 'location.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({
    super.key,
    this.initialLocation,
    this.onBoundsChanged,
    this.onLocationChanged,
  });

  final Location? initialLocation;
  final Function(Location location)? onLocationChanged;
  final Function(LatLngBounds bounds, LatLng center)? onBoundsChanged;

  @override
  State<StatefulWidget> createState() => LocationMapState();
}

class LocationMapState extends State<LocationMap> {
  final MapController _mapController = MapController();
  Location? _location;
  bool isMapMoved = false;
  Timer? mapMovedTimer;
  final bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Map View',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          if (_location != null) ...[
            Text(
              'Location: ${_location!.displayName ?? 'Unknown'}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ] else
            Text(
              'Loading location...',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> openMapsApp() async {
    if (_location == null) return;
    
    final lat = _location!.latitude;
    final lon = _location!.longitude;
    final currentZoom = _isMapReady ? _mapController.camera.zoom : 10.0;
    final Uri? mapsUri;

    try {
      if (await canLaunchUrl(Uri.parse('maps:'))) {
        mapsUri = Uri.parse('maps://?ll=$lat,$lon&z=$currentZoom');
      } else if (await canLaunchUrl(Uri.parse('geo:'))) {
        mapsUri = Uri.parse('geo:$lat,$lon?z=$currentZoom');
      } else if (await canLaunchUrl(Uri.parse('comgooglemaps:'))) {
        mapsUri = Uri.parse('comgooglemaps://?center=$lat,$lon&zoom=$currentZoom');
      } else if (await canLaunchUrl(Uri.parse('waze:'))) {
        mapsUri = Uri.parse('waze://?ll=$lat,$lon&z=$currentZoom');
      } else {
        throw 'No maps application available';
      }
      await launchUrl(mapsUri);
    } catch (error) {
      _showErrorDialog('Failed to open maps', error.toString());
    }
  }

  void _setLocation(Location location) {
    setState(() {
      _location = location;
      isMapMoved = false;
    });

    if (location != widget.initialLocation) {
      widget.onLocationChanged?.call(location);
    }

    // Only use MapController if map is ready (which it won't be in our placeholder implementation)
    if (_isMapReady) {
      final latLng = LatLng(location.latitude, location.longitude);
      _mapController.move(latLng, 10.0);
      _mapController.rotate(0.0);

      if (location.bounds != null) {
        final bounds = location.bounds!;
        final center = LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        );
        _mapController.move(center, 12.0);
      }
    }
  }

  Future<List<Location>> searchLocation(String query) async {
    try {
      return await geolocation.searchLocation(query);
    } catch (error) {
      _showErrorDialog('Failed to search location', error.toString());
      return [];
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      final location = await geolocation.getCurrentLocation();
      _setLocation(location);
    } catch (error) {
      _showErrorDialog('Failed to get current location', error.toString());
    }
  }

  Future<void> initMap() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final location = widget.initialLocation ??
          await geolocation.getLastKnownLocation() ??
          await geolocation.getLocationByLocale();
      if (location != null) {
        _setLocation(location);
      }
    } catch (error) {
      _showErrorDialog('Failed to get initial location', error.toString());
    }
  }

  void onMapMoved(TapPosition position, bool hasGesture) {
    setState(() {
      isMapMoved = true;
    });

    mapMovedTimer?.cancel();
    mapMovedTimer = Timer(const Duration(milliseconds: 500), () {
      isMapMoved = false;
      mapMovedTimer = null;
      
      // Only use MapController if map is ready
      if (_isMapReady) {
        final mapState = _mapController.camera;
        final bounds = _mapController.camera.visibleBounds;
        final center = mapState.center;
        widget.onBoundsChanged?.call(bounds, center);
        if (_location != null) {
          _setLocation(Location(
            latitude: center.latitude,
            longitude: center.longitude,
            borough: _location!.borough,
            city: _location!.city,
            country: _location!.country,
            countryCode: _location!.countryCode,
            houseNumber: _location!.houseNumber,
            displayName: _location!.displayName,
          ));
        }
      }
    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initMap();
    });
  }

  @override
  void dispose() {
    mapMovedTimer?.cancel();
    super.dispose();
  }
}
