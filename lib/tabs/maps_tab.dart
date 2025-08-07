import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/load_provider.dart';
import '../models/load_post.dart';

class MapsTab extends StatefulWidget {
  const MapsTab({super.key});

  @override
  State<MapsTab> createState() => _MapsTabState();
}

class _MapsTabState extends State<MapsTab> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String? _selectedLoadId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarkers();
    });
  }

  void _loadMarkers() {
    final loadProvider = Provider.of<LoadProvider>(context, listen: false);
    final loads = loadProvider.loads;

    Set<Marker> markers = {};

    for (var load in loads) {
      LatLng originLatLng = _getLatLngFromAddress(load.origin);

      markers.add(Marker(
        markerId: MarkerId(load.id),
        position: originLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          load.id == _selectedLoadId ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          setState(() {
            _selectedLoadId = load.id;
          });
        },
      ));
    }

    setState(() {
      _markers = markers;
    });
  }

  LatLng _getLatLngFromAddress(String address) {
    int hash = address.hashCode;
    double lat = 37.0 + (hash % 1000) / 1000.0;
    double lng = -122.0 + (hash % 1000) / 1000.0;
    return LatLng(lat, lng);
  }

  void _onLoadTap(LoadPost load) {
    LatLng position = _getLatLngFromAddress(load.origin);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 10));
    setState(() {
      _selectedLoadId = load.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final loadProvider = Provider.of<LoadProvider>(context);
      final loads = loadProvider.loads;

      return Column(
        children: [
          Container(
            height: 300,
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 5,
              ),
              markers: _markers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: loads.length,
              itemBuilder: (context, index) {
                final load = loads[index];
                final isSelected = load.id == _selectedLoadId;
                return ListTile(
                  title: Text(load.title),
                  subtitle: Text('\${load.origin} → \${load.destination}'),
                  trailing: Text('\$ \${load.rate}'),
                  selected: isSelected,
                  onTap: () => _onLoadTap(load),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const Center(
        child: Text('Map is only supported on Windows platform currently.'),
      );
    }
  }
}
