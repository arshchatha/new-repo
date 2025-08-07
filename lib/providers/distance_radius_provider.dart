import 'package:flutter/material.dart';
import '../core/core/database/queries/distance_radius_queries.dart';
import '../core/core/database/database_helper.dart';
import '../models/load_post.dart';

class DistanceRadiusProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<LoadPost> _loadsWithinRadius = [];
  List<LoadPost> get loadsWithinRadius => _loadsWithinRadius;

  Future<void> fetchLoadsWithinRadius(
      double latitude, double longitude, double radiusKm) async {
    final results = await _dbHelper.rawQuery(
      selectLoadsWithinRadius,
      [latitude, longitude, latitude, radiusKm],
    );

    _loadsWithinRadius = results.map((map) => LoadPost.fromMap(map)).toList();
    notifyListeners();
  }
}
