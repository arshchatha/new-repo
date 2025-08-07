import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'core/services/distance_service.dart';

class LoadRouteScreen extends StatefulWidget {
  final LatLng origin, destination;
  final double perKmRate;

  const LoadRouteScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.perKmRate,
  });

  @override
  State<LoadRouteScreen> createState() => _LoadRouteScreenState();
}



class _LoadRouteScreenState extends State<LoadRouteScreen> {
  GoogleMapController? _mapController;
  final Set<Polyline> _polylines = {};
  late CameraPosition _initialCamera;
  String distance = '';
  String duration = '';
  double rate = 0;

  @override
  void initState() {
    super.initState();
    _initialCamera = CameraPosition(target: widget.origin, zoom: 10);
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final service = DistanceService();
    final route = await service.getRoute(widget.origin, widget.destination);
    if (route == null) return;

    final points = route['points'] as List<LatLng>;
    final meters = route['distanceValue'] as int;
    final kms = meters / 1000;
    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        width: 4,
        color: Colors.blue,
        points: points,
      ));
      distance = route['distanceText'];
      duration = route['durationText'];
      rate = service.calculateRate(kms, widget.perKmRate);
    });

    final bounds = LatLngBounds(
      southwest: widget.origin.latitude < widget.destination.latitude
          ? widget.origin
          : widget.destination,
      northeast: widget.origin.latitude < widget.destination.latitude
          ? widget.destination
          : widget.origin,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route & Rate')),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: _initialCamera,
              polylines: _polylines,
              markers: {
                Marker(markerId: const MarkerId('origin'), position: widget.origin),
                Marker(markerId: const MarkerId('dest'), position: widget.destination),
              },
              onMapCreated: (c) => _mapController = c,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Distance: \$distance'),
                Text('Duration: \$duration'),
                Text('Rate (@\${widget.perKmRate.toStringAsFixed(2)}/km): \$\${rate.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

