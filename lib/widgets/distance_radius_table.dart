import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/distance_radius_provider.dart';
import '../models/load_post.dart';
import 'dart:math' as dart_math;

class DistanceRadiusTable extends StatelessWidget {
  final double userLatitude;
  final double userLongitude;
  final double radiusKm;

  const DistanceRadiusTable({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
    required this.radiusKm,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DistanceRadiusProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            ElevatedButton(
              onPressed: () {
                provider.fetchLoadsWithinRadius(
                  userLatitude,
                  userLongitude,
                  radiusKm,
                );
              },
              child: Text('Find Loads Within ${radiusKm}km'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: provider.loadsWithinRadius.isEmpty
                  ? Center(child: Text('No loads found within radius'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Title')),
                          DataColumn(label: Text('Origin')),
                          DataColumn(label: Text('Destination')),
                          DataColumn(label: Text('Rate')),
                          DataColumn(label: Text('Distance (km)')),
                        ],
                        rows: provider.loadsWithinRadius.map((load) {
                          return DataRow(cells: [
                            DataCell(Text(load.title)),
                            DataCell(Text(load.origin)),
                            DataCell(Text(load.destination)),
                            DataCell(Text('\$${(double.tryParse(load.rate) ?? 0.0).toStringAsFixed(2)}')),
                            DataCell(Text(_calculateDistance(load) ?? 'N/A')),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  String? _calculateDistance(LoadPost load) {
    if (load.pickupLatitude != null && load.pickupLongitude != null) {
      final dist = _calculateHaversineDistance(
        userLatitude,
        userLongitude,
        load.pickupLatitude!,
        load.pickupLongitude!,
      );
      // dist is always double from _calculateHaversineDistance
      return dist.toStringAsFixed(2);
    }
    return null;
  }

  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the earth in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = dart_math.sin(dLat / 2) * dart_math.sin(dLat / 2) +
        dart_math.cos(_deg2rad(lat1)) * dart_math.cos(_deg2rad(lat2)) *
        dart_math.sin(dLon / 2) * dart_math.sin(dLon / 2);
    final c = 2 * dart_math.atan2(dart_math.sqrt(a), dart_math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (dart_math.pi / 180);
}
