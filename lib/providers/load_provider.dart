import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/load_post.dart';
import '../models/user.dart';
import '../core/services/platform_database_service.dart';
import '../core/services/distance_service.dart';
import '../services/notification_service.dart';

class LoadProvider extends ChangeNotifier {
  final Logger _logger = Logger();
  final List<LoadPost> _loads = [];
  final Map<String, String> _distanceCache = {};

  List<LoadPost> get loads => List.unmodifiable(_loads);
  List<LoadPost> get brokerPosts => _loads.where((e) => e.isBrokerPost).toList();
  List<LoadPost> get carrierPosts => _loads.where((e) => e.isCarrierPost).toList();

  // Refactored async method to get posted loads with filtering
  Future<List<LoadPost>> getPostedLoadsForUser(User? user) async {
    if (user == null) return [];

    List<LoadPost> filtered = _loads.where((load) =>
      load.postedBy == user.id &&
      ((user.role == 'broker' && load.isBrokerPost) ||
       (user.role == 'carrier' && load.isCarrierPost))
    ).toList();

    if (user.equipment.isNotEmpty) {
      filtered = filtered.where((load) =>
        load.equipment.isEmpty ||
        load.equipment.any((eq) => user.equipment.contains(eq))
      ).toList();
    }

    if (user.distanceRadiusLimit != null && user.latitude == null && user.longitude == null) {
      final userLat = user.latitude!;
      final userLng = user.longitude!;
      final radiusLimit = user.distanceRadiusLimit!;

      filtered = await Future.wait(filtered.map((load) async {
        if (load.pickupLatitude != null && load.pickupLongitude != null) {
          final distance = _calculateDistance(userLat, userLng, load.pickupLatitude!, load.pickupLongitude!);
          if (distance <= radiusLimit) {
            return load;
          }
        }
        return null;
      })).then((loads) => loads.whereType<LoadPost>().toList());
    }

    return filtered;
  }

  // Refactored async method to get available loads with filtering
  Future<List<LoadPost>> getAvailableLoadsForUser(User? user) async {
    if (user == null) return [];

    List<LoadPost> filtered = _loads.where((load) =>
      load.postedBy != user.id &&
      ((user.role == 'broker' && load.isCarrierPost) ||
       (user.role == 'carrier' && load.isBrokerPost))
    ).toList();

    // Filter out posts from users with the same USDOT number
    if (user.usDotMcNumber.isNotEmpty) {
      final db = PlatformDatabaseService.instance;
      final usersWithSameUsdot = await db.getUsersByUsdotNumber(user.usDotMcNumber);
      final userIdsWithSameUsdot = usersWithSameUsdot.map((u) => u.id).toSet();
      
      // Remove loads posted by users with the same USDOT number
      filtered = filtered.where((load) => !userIdsWithSameUsdot.contains(load.postedBy)).toList();
    }

    if (user.equipment.isNotEmpty) {
      filtered = filtered.where((load) =>
        load.equipment.isEmpty ||
        load.equipment.any((eq) => user.equipment.contains(eq))
      ).toList();
    }

    if (user.distanceRadiusLimit != null && user.latitude != null && user.longitude != null) {
      final userLat = user.latitude!;
      final userLng = user.longitude!;
      final radiusLimit = user.distanceRadiusLimit!;

      filtered = await Future.wait(filtered.map((load) async {
        if (load.pickupLatitude != null && load.pickupLongitude != null) {
          final distance = _calculateDistance(userLat, userLng, load.pickupLatitude!, load.pickupLongitude!);
          if (distance <= radiusLimit) {
            return load;
          }
        }
        return null;
      })).then((loads) => loads.whereType<LoadPost>().toList());
    }

    return filtered;
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusMiles = 3958.8;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMiles * c;
  }

  double _degreesToRadians(double degrees) => degrees * (pi / 180);

  Future<void> fetchLoads() async {
    try {
      final db = PlatformDatabaseService.instance;
      await db.init();
      final loads = await db.getLoads();
      _loads.clear();
      _loads.addAll(loads);
      await Future.wait([
        _calculateDistancesForLoads(),
        updateLoadsWithMatches(),
      ]);
      notifyListeners();
    } catch (e) {
      _logger.e('Error fetching loads: $e');
      _loads.clear();
      notifyListeners();
    }
  }

  Future<void> _calculateDistancesForLoads() async {
    final futures = _loads.map((load) => calculateDistance(load));
    await Future.wait(futures);
  }

  Future<String?> calculateDistance(LoadPost load) async {
    try {
      // Check cache first
      if (_distanceCache.containsKey(load.id)) {
        _logger.d('Returning cached distance for load ${load.id}');
        return _distanceCache[load.id];
      }

      _logger.d('Calculating distance for load ${load.id}: ${load.origin} -> ${load.destination}');

      // Use existing coordinates if available
      LatLng? origin;
      LatLng? destination;

      if (load.pickupLatitude != null && load.pickupLongitude != null) {
        origin = LatLng(load.pickupLatitude!, load.pickupLongitude!);
        _logger.d('Using existing pickup coordinates: $origin');
      } else {
        if (load.origin.trim().isEmpty) {
          _logger.w('Origin address is missing or empty for load ${load.id}');
          return 'Origin address missing';
        }
        origin = await _getLatLng(load.origin);
        if (origin != null) {
          load.pickupLatitude = origin.latitude;
          load.pickupLongitude = origin.longitude;
          _logger.d('Geocoded pickup location: ${load.origin} -> $origin');
        }
      }

      if (load.destinationLatitude != null && load.destinationLongitude != null) {
        destination = LatLng(load.destinationLatitude!, load.destinationLongitude!);
        _logger.d('Using existing destination coordinates: $destination');
      } else {
        if (load.destination.trim().isEmpty) {
          _logger.w('Destination address is missing or empty for load ${load.id}');
          return 'Destination address missing';
        }
        destination = await _getLatLng(load.destination);
        if (destination != null) {
          load.destinationLatitude = destination.latitude;
          load.destinationLongitude = destination.longitude;
          _logger.d('Geocoded destination location: ${load.destination} -> $destination');
        }
      }

      if (origin == null || destination == null) {
        final errorMsg = 'Unable to geocode locations - Origin: ${origin != null ? 'OK' : 'FAILED'}, Destination: ${destination != null ? 'OK' : 'FAILED'}';
        _logger.w(errorMsg);
        _distanceCache[load.id] = 'Location not found';
        return 'Location not found';
      }

      // Calculate distance using enhanced DistanceService
      final service = DistanceService();
      final route = await service.getRoute(origin, destination);
      
      if (route != null) {
        String distanceText = route['distanceText'] ?? 'Unknown distance';
        final source = route['source'] ?? 'unknown';
        final isEstimate = route['isEstimate'] == true;
        
        // Add indicator for estimated distances
        if (isEstimate) {
          distanceText = '$distanceText (est.)';
        }
        
        _logger.i('Distance calculated for load ${load.id}: $distanceText (source: $source)');
        
        // Cache the result
        _distanceCache[load.id] = distanceText;
        load.distance = distanceText;
        
        // Update load in database with new coordinates and distance
        try {
          final loadToUpdate = load.copyWith(matchingLoads: null);
          await PlatformDatabaseService.instance.updateLoad(loadToUpdate);
          _logger.d('Updated load ${load.id} in database with coordinates and distance');
        } catch (dbError) {
          _logger.w('Failed to update load in database: $dbError');
          // Don't fail the distance calculation if database update fails
        }
        
        return distanceText;
      } else {
        // This shouldn't happen with the enhanced DistanceService, but just in case
        final errorMsg = 'Unable to calculate distance between locations';
        _logger.e(errorMsg);
        _distanceCache[load.id] = 'Calculation failed';
        return 'Calculation failed';
      }
    } catch (e, stackTrace) {
      _logger.e('Error calculating distance for load ${load.id}: $e', error: e, stackTrace: stackTrace);
      
      // Try to provide a fallback distance if we have coordinates
      if (load.pickupLatitude != null && load.pickupLongitude != null &&
          load.destinationLatitude != null && load.destinationLongitude != null) {
        try {
          final fallbackDistance = _calculateHaversineDistance(
            load.pickupLatitude!,
            load.pickupLongitude!,
            load.destinationLatitude!,
            load.destinationLongitude!,
          );
          final fallbackText = '${fallbackDistance.toStringAsFixed(1)} km (est.)';
          _logger.i('Using fallback Haversine distance for load ${load.id}: $fallbackText');
          _distanceCache[load.id] = fallbackText;
          return fallbackText;
        } catch (fallbackError) {
          _logger.e('Fallback distance calculation also failed: $fallbackError');
        }
      }
      
      _distanceCache[load.id] = 'Error calculating';
      return 'Error calculating';
    }
  }

  /// Calculate straight-line distance using Haversine formula
  double _calculateHaversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371; // Radius of the earth in km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<String?> calculateDistanceBetweenPickups(dynamic origin1, dynamic origin2) async {
    try {
      String cacheKey;
      LatLng? point1;
      LatLng? point2;

      if (origin1 is String && origin2 is String) {
        cacheKey = '${origin1}_to_$origin2';
        if (_distanceCache.containsKey(cacheKey)) {
          return _distanceCache[cacheKey];
        }
        point1 = await _getLatLng(origin1);
        point2 = await _getLatLng(origin2);
      } else if (origin1 is LatLng && origin2 is LatLng) {
        cacheKey = '${origin1.latitude},${origin1.longitude}_to_${origin2.latitude},${origin2.longitude}';
        if (_distanceCache.containsKey(cacheKey)) {
          return _distanceCache[cacheKey];
        }
        point1 = origin1;
        point2 = origin2;
      } else {
        return null;
      }

      if (point1 != null && point2 != null) {
        final service = DistanceService();
        final route = await service.getRoute(point1, point2);
        final distanceText = route?['distanceText'];
        if (distanceText != null) {
          _distanceCache[cacheKey] = distanceText;
        }
        return distanceText;
      }
      return null;
    } catch (e) {
      _logger.e('Error calculating distance between pickups: $e');
      return null;
    }
  }

  Future<void> updateLoadsWithMatches() async {
    final allBrokerPosts = brokerPosts;
    final allCarrierPosts = carrierPosts;

    for (final brokerPost in allBrokerPosts) {
      final matches = findMatchingLoads(brokerPost, allCarrierPosts);
      brokerPost.matchingLoads = matches;
      for (final match in matches) {
        await match.calculateDestinationDifference(
          brokerPost,
          (origin, destination) => calculateDistanceBetweenPickups(origin, destination),
        );
      }
    }

    for (final carrierPost in allCarrierPosts) {
      final matches = findMatchingLoads(carrierPost, allBrokerPosts);
      carrierPost.matchingLoads = matches;
      for (final match in matches) {
        await match.calculateDestinationDifference(
          carrierPost,
          (origin, destination) => calculateDistanceBetweenPickups(origin, destination),
        );
      }
    }
    notifyListeners();
  }

  List<LoadPost> findMatchingLoads(LoadPost target, List<LoadPost> candidates) {
    return candidates.where((candidate) {
      if (candidate.id == target.id) return false;

      // Equipment matching - must match if specified
      final equipmentMatch = target.equipment.isEmpty || candidate.equipment.isEmpty ||
          target.equipment.any((eq) => candidate.equipment.contains(eq));
      if (!equipmentMatch) return false;

      // Date matching
      final dateMatch = target.pickupDate.isEmpty || candidate.pickupDate.isEmpty || target.pickupDate == candidate.pickupDate;
      if (!dateMatch) return false;

      // Load type matching
      final loadTypeMatch = target.loadType == null || candidate.loadType == null || target.loadType == candidate.loadType;
      if (!loadTypeMatch) return false;

      // Distance-based matching using origin and destination radius
      bool withinOriginRadius = true;
      bool withinDestinationRadius = true;

      // Check origin radius constraint
      if (target.originRadius != null && target.originRadius! > 0 &&
          target.pickupLatitude != null && target.pickupLongitude != null &&
          candidate.pickupLatitude != null && candidate.pickupLongitude != null) {
        final originDistance = _calculateDistance(
          target.pickupLatitude!,
          target.pickupLongitude!,
          candidate.pickupLatitude!,
          candidate.pickupLongitude!,
        );
        withinOriginRadius = originDistance <= target.originRadius!;
      }

      // Check destination radius constraint
      if (target.destinationRadius != null && target.destinationRadius! > 0 &&
          target.destinationLatitude != null && target.destinationLongitude != null &&
          candidate.destinationLatitude != null && candidate.destinationLongitude != null) {
        final destinationDistance = _calculateDistance(
          target.destinationLatitude!,
          target.destinationLongitude!,
          candidate.destinationLatitude!,
          candidate.destinationLongitude!,
        );
        withinDestinationRadius = destinationDistance <= target.destinationRadius!;
      }

      // If no radius is specified, fall back to city/state matching
      if ((target.originRadius == null || target.originRadius == 0) &&
          (target.destinationRadius == null || target.destinationRadius == 0)) {
        final o1 = target.originParts;
        final d1 = target.destinationParts;
        final o2 = candidate.originParts;
        final d2 = candidate.destinationParts;

        final routeMatch = o1[0].toLowerCase() == o2[0].toLowerCase() && d1[0].toLowerCase() == d2[0].toLowerCase();
        return routeMatch;
      }

      return withinOriginRadius && withinDestinationRadius;
    }).toList();
  }

  Future<LatLng?> _getLatLng(String address) async {
    if (address.trim().isEmpty) {
      _logger.w('Empty address provided for geocoding');
      return null;
    }

    try {
      final cleanAddress = address.trim();
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(cleanAddress)}&key=AIzaSyCWht0kEJMXOEHaUjNlERQEz9iVUS6cN2o'
      );
      
      _logger.d('Geocoding address: $cleanAddress');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Geocoding request timeout'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Geocoding API returned status code: ${response.statusCode}');
      }
      
      final data = json.decode(response.body);
      
      if (data['status'] != 'OK') {
        _logger.w('Geocoding API error for "$cleanAddress": ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
        return null;
      }
      
      if (data['results'] == null || (data['results'] as List).isEmpty) {
        _logger.w('No geocoding results found for address: $cleanAddress');
        return null;
      }
      
      final location = data['results'][0]['geometry']['location'];
      final lat = location['lat'] as double;
      final lng = location['lng'] as double;
      
      // Validate coordinates
      if (lat.abs() > 90.0 || lng.abs() > 180.0 || lat.isNaN || lng.isNaN) {
        _logger.w('Invalid coordinates received from geocoding: lat=$lat, lng=$lng');
        return null;
      }
      
      final result = LatLng(lat, lng);
      _logger.d('Successfully geocoded "$cleanAddress" to $result');
      return result;
      
    } catch (e, stackTrace) {
      _logger.e('Error geocoding address "$address": $e', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  void removeLoad(String id) {
    _loads.removeWhere((load) => load.id == id);
    notifyListeners();
  }

  void updateLoad(LoadPost updatedPost) {
    final index = _loads.indexWhere((load) => load.id == updatedPost.id);
    if (index != -1) {
      _loads[index] = updatedPost;
      notifyListeners();
    }
  }

  Future<void> addLoad(LoadPost post) async {
    try {
      final db = PlatformDatabaseService.instance;
      await db.init();
      await db.insertLoad(post);
      _loads.add(post);
      notifyListeners();
    } catch (e) {
      _logger.e('Error adding load: $e');
      rethrow;
    }
  }

  Future<void> addBid(String loadId, LoadPostQuote quote) async {
    try {
      final index = _loads.indexWhere((l) => l.id == loadId);
      if (index != -1) {
        _loads[index].bids.removeWhere((b) => b.bidder == quote.bidder);
        _loads[index].bids.add(quote);
        final db = PlatformDatabaseService.instance;
        await db.init();
        await db.updateLoadBids(loadId, _loads[index].bids);
        notifyListeners();
      } else {
        _logger.w('Load with ID $loadId not found.');
      }
    } catch (e) {
      _logger.e('Error adding bid: $e');
      rethrow;
    }
  }

  Future<void> updateBidStatus(String loadId, String bidder, String status, {double? counterBidAmount}) async {
    try {
      final index = _loads.indexWhere((l) => l.id == loadId);
      if (index != -1) {
        final bidIndex = _loads[index].bids.indexWhere((b) => b.bidder == bidder);
        if (bidIndex != -1) {
          final oldBid = _loads[index].bids[bidIndex];
          _loads[index].bids[bidIndex] = LoadPostQuote(
            bidder: oldBid.bidder,
            amount: oldBid.amount,
            bidStatus: status,
            counterBidAmount: counterBidAmount ?? oldBid.counterBidAmount,
          );

          // If broker accepts a bid, update load status and confirmation flags
          if (status == 'accepted') {
            _loads[index] = _loads[index].copyWith(
              status: 'awaiting_carrier_confirmation',
              selectedBidId: bidder,
              brokerConfirmed: true,
              carrierConfirmed: false,
            );
          }

          final db = PlatformDatabaseService.instance;
          await db.init();
          await db.updateLoadBids(loadId, _loads[index].bids);
          await db.updateLoad(_loads[index]);
          notifyListeners();
        } else {
          _logger.w('Bidder $bidder not found in load $loadId bids.');
        }
      } else {
        _logger.w('Load with ID $loadId not found.');
      }
    } catch (e) {
      _logger.e('Error updating bid status: $e');
      rethrow;
    }
  }

  /// Carrier confirms the accepted load
  Future<void> confirmLoad(String loadId) async {
    try {
      final index = _loads.indexWhere((l) => l.id == loadId);
      if (index != -1) {
        final load = _loads[index];
        _loads[index] = load.copyWith(
          carrierConfirmed: true,
          status: 'confirmed',
        );
        
        final db = PlatformDatabaseService.instance;
        await db.init();
        await db.updateLoad(_loads[index]);
        notifyListeners();
        
        // Send notification to broker about load confirmation
        final notificationService = NotificationService();
        final acceptedBid = load.bids.firstWhere(
          (bid) => bid.bidder == load.selectedBidId && bid.bidStatus == 'accepted',
          orElse: () => LoadPostQuote(bidder: load.selectedBidId ?? '', amount: 0),
        );
        
        notificationService.notifyLoadConfirmed(
          loadId: loadId,
          brokerId: load.postedBy,
          carrierName: load.selectedBidId ?? 'Carrier',
          bidAmount: acceptedBid.amount,
          loadOrigin: load.originParts.isNotEmpty ? load.originParts[0] : load.origin,
          loadDestination: load.destinationParts.isNotEmpty ? load.destinationParts[0] : load.destination,
        );
        
        _logger.i('Load $loadId confirmed by carrier');
      } else {
        _logger.w('Load with ID $loadId not found.');
        throw Exception('Load not found');
      }
    } catch (e) {
      _logger.e('Error confirming load: $e');
      rethrow;
    }
  }

  /// Carrier declines the accepted load
  Future<void> declineLoad(String loadId) async {
    try {
      final index = _loads.indexWhere((l) => l.id == loadId);
      if (index != -1) {
        final load = _loads[index];
        _loads[index] = load.copyWith(
          carrierConfirmed: false,
          status: 'declined_by_carrier',
          selectedBidId: null,
          brokerConfirmed: false,
        );
        
        final db = PlatformDatabaseService.instance;
        await db.init();
        await db.updateLoad(_loads[index]);
        notifyListeners();
        
        // Send notification to broker about load decline
        final notificationService = NotificationService();
        final acceptedBid = load.bids.firstWhere(
          (bid) => bid.bidder == load.selectedBidId && bid.bidStatus == 'accepted',
          orElse: () => LoadPostQuote(bidder: load.selectedBidId ?? '', amount: 0),
        );
        
        notificationService.notifyLoadDeclined(
          loadId: loadId,
          brokerId: load.postedBy,
          carrierName: load.selectedBidId ?? 'Carrier',
          bidAmount: acceptedBid.amount,
          loadOrigin: load.originParts.isNotEmpty ? load.originParts[0] : load.origin,
          loadDestination: load.destinationParts.isNotEmpty ? load.destinationParts[0] : load.destination,
        );
        
        _logger.i('Load $loadId declined by carrier');
      } else {
        _logger.w('Load with ID $loadId not found.');
        throw Exception('Load not found');
      }
    } catch (e) {
      _logger.e('Error declining load: $e');
      rethrow;
    }
  }

  /// Get loads awaiting carrier confirmation for a specific carrier
  Future<List<LoadPost>> getLoadsAwaitingCarrierConfirmation(String carrierId) async {
    return _loads.where((load) => 
      load.status == 'awaiting_carrier_confirmation' &&
      load.selectedBidId == carrierId &&
      load.brokerConfirmed == true &&
      load.carrierConfirmed == false
    ).toList();
  }

  List<LoadPost> getFilteredLoads({
    String? searchQuery,
    String? statusFilter,
    String? equipmentFilter,
    String? loadTypeFilter,
    String? originFilter,
    String? destinationFilter,
    bool isBrokerPosts = true,
  }) {
    final source = isBrokerPosts ? brokerPosts : carrierPosts;
    return source.where((load) =>
      (searchQuery == null || load.matchesSearch(searchQuery)) &&
      load.matchesFilters(
        statusFilter: statusFilter,
        equipmentFilter: equipmentFilter,
        loadTypeFilter: loadTypeFilter,
        originFilter: originFilter,
        destinationFilter: destinationFilter,
      )
    ).toList();
  }

  List<LoadPost> sortLoads(List<LoadPost> loads, String sortBy, bool ascending) {
    final sorted = List<LoadPost>.from(loads);
    sorted.sort((a, b) {
      int cmp = 0;
      switch (sortBy) {
        case 'id': cmp = a.id.compareTo(b.id); break;
        case 'origin': cmp = a.origin.compareTo(b.origin); break;
        case 'destination': cmp = a.destination.compareTo(b.destination); break;
        case 'pickupDate': cmp = a.pickupDate.compareTo(b.pickupDate); break;
        case 'deliveryDate': cmp = a.deliveryDate.compareTo(b.deliveryDate); break;
        case 'rate':
          final r1 = double.tryParse(a.rate) ?? 0;
          final r2 = double.tryParse(b.rate) ?? 0;
          cmp = r1.compareTo(r2);
          break;
        case 'loadType': cmp = (a.loadType ?? '').compareTo(b.loadType ?? ''); break;
        case 'equipment': cmp = a.equipmentString.compareTo(b.equipmentString); break;
        case 'status': cmp = a.status.compareTo(b.status); break;
        default: cmp = a.id.compareTo(b.id);
      }
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }

  static LoadProvider of(BuildContext context) => Provider.of<LoadProvider>(context, listen: false);

  Future<List<LoadPost>> getCarrierBidsWithBrokerResponses(User user) async {
    return _loads.where((load) => load.bids.any((bid) => bid.bidder == user.id)).toList();
  }

  Future<void> deleteLoad(String id) async {
    try {
      final db = PlatformDatabaseService.instance;
      await db.init();
      
      // Remove from database
      await db.deleteLoad(id);
      
      // Remove from local list
      _loads.removeWhere((load) => load.id == id);
      
      // Clear distance cache for this load
      _distanceCache.remove(id);
      
      notifyListeners();
      _logger.i('Load $id deleted successfully');
    } catch (e) {
      _logger.e('Error deleting load $id: $e');
      rethrow;
    }
  }

  Future<List<LoadPost>> brokerPostsForUser(User? user) async {
    if (user == null) return brokerPosts;

    // Restrict to only broker posts posted by this user and isBrokerPost true
    List<LoadPost> filtered = brokerPosts.where((load) => load.postedBy == user.id && load.isBrokerPost).toList();

    // Filter out posts from users with the same USDOT number
    if (user.usDotMcNumber.isNotEmpty) {
      final db = PlatformDatabaseService.instance;
      final usersWithSameUsdot = await db.getUsersByUsdotNumber(user.usDotMcNumber);
      final userIdsWithSameUsdot = usersWithSameUsdot.map((u) => u.id).toSet();
      
      // Remove loads posted by users with the same USDOT number
      filtered = filtered.where((load) => !userIdsWithSameUsdot.contains(load.postedBy)).toList();
    }

    if (user.equipment.isNotEmpty) {
      filtered = filtered.where((load) =>
        load.equipment.isEmpty ||
        load.equipment.any((eq) => user.equipment.contains(eq))
      ).toList();
    }

    if (user.distanceRadiusLimit != null && user.latitude != null && user.longitude != null) {
      final userLat = user.latitude!;
      final userLng = user.longitude!;
      final radiusLimit = user.distanceRadiusLimit!;

      filtered = await Future.wait(filtered.map((load) async {
        if (load.pickupLatitude != null && load.pickupLongitude != null) {
          final distance = _calculateDistance(userLat, userLng, load.pickupLatitude!, load.pickupLongitude!);
          if (distance <= radiusLimit) {
            return load;
          }
        }
        return null;
      })).then((loads) => loads.whereType<LoadPost>().toList());
    }

    return filtered;
  }

  Future<List<LoadPost>> matchingCarrierPostsForUser(User? user) async {
    if (user == null) return [];

    // Determine opposite role posts
    List<LoadPost> oppositeRolePosts;
    if (user.role == 'broker') {
      oppositeRolePosts = carrierPosts;
    } else if (user.role == 'carrier') {
      oppositeRolePosts = brokerPosts;
    } else {
      oppositeRolePosts = [];
    }

    // Filter out posts from users with the same USDOT number
    if (user.usDotMcNumber.isNotEmpty) {
      final db = PlatformDatabaseService.instance;
      final usersWithSameUsdot = await db.getUsersByUsdotNumber(user.usDotMcNumber);
      final userIdsWithSameUsdot = usersWithSameUsdot.map((u) => u.id).toSet();
      
      // Remove loads posted by users with the same USDOT number
      oppositeRolePosts = oppositeRolePosts.where((load) => !userIdsWithSameUsdot.contains(load.postedBy)).toList();
    }

    // Apply equipment filter
    if (user.equipment.isNotEmpty) {
      oppositeRolePosts = oppositeRolePosts.where((load) =>
        load.equipment.isEmpty ||
        load.equipment.any((eq) => user.equipment.contains(eq))
      ).toList();
    }

    // Apply distance radius filter
    if (user.distanceRadiusLimit != null && user.latitude != null && user.longitude != null) {
      final userLat = user.latitude!;
      final userLng = user.longitude!;
      final radiusLimit = user.distanceRadiusLimit!;

      oppositeRolePosts = await Future.wait(oppositeRolePosts.map((load) async {
        if (load.pickupLatitude != null && load.pickupLongitude != null) {
          final distance = _calculateDistance(userLat, userLng, load.pickupLatitude!, load.pickupLongitude!);
          if (distance <= radiusLimit) {
            return load;
          }
        }
        return null;
      })).then((loads) => loads.whereType<LoadPost>().toList());
    }

    // Further filter opposite role posts to those matching user's own postings
    final userPosts = (user.role == 'broker' ? brokerPosts : carrierPosts).where((load) => load.postedBy == user.id).toList();
    final matchingPosts = <LoadPost>[];

    for (final oppositePost in oppositeRolePosts) {
      for (final userPost in userPosts) {
        final o1 = userPost.originParts;
        final d1 = userPost.destinationParts;
        final o2 = oppositePost.originParts;
        final d2 = oppositePost.destinationParts;

        final routeMatch = o1[0].toLowerCase() == o2[0].toLowerCase() && d1[0].toLowerCase() == d2[0].toLowerCase();
        final equipmentMatch = userPost.equipment.isEmpty || oppositePost.equipment.isEmpty ||
            userPost.equipment.any((eq) => oppositePost.equipment.contains(eq));
        final dateMatch = userPost.pickupDate.isEmpty || oppositePost.pickupDate.isEmpty || userPost.pickupDate == oppositePost.pickupDate;
        final loadTypeMatch = userPost.loadType == null || oppositePost.loadType == null || userPost.loadType == oppositePost.loadType;

        if (routeMatch && equipmentMatch && dateMatch && loadTypeMatch) {
          matchingPosts.add(oppositePost);
          break;
        }
      }
    }

    return matchingPosts;
  }

  Future<List<LoadPost>> carrierPostsForUser(User? user, {bool applyFilters = true}) async {
    if (user == null) return carrierPosts;

    // Start with all carrier posts (loads posted by carriers)
    List<LoadPost> filtered = carrierPosts;

    // Filter out posts from users with the same USDOT number
    if (user.usDotMcNumber.isNotEmpty) {
      final db = PlatformDatabaseService.instance;
      final usersWithSameUsdot = await db.getUsersByUsdotNumber(user.usDotMcNumber);
      final userIdsWithSameUsdot = usersWithSameUsdot.map((u) => u.id).toSet();
      
      // Remove loads posted by users with the same USDOT number
      filtered = filtered.where((load) => !userIdsWithSameUsdot.contains(load.postedBy)).toList();
    }

    if (applyFilters) {
      if (user.equipment.isNotEmpty) {
        filtered = filtered.where((load) =>
          load.equipment.isEmpty ||
          load.equipment.any((eq) => user.equipment.contains(eq))
        ).toList();
      }

      if (user.distanceRadiusLimit != null && user.latitude != null && user.longitude != null) {
        final userLat = user.latitude!;
        final userLng = user.longitude!;
        final radiusLimit = user.distanceRadiusLimit!;

        filtered = await Future.wait(filtered.map((load) async {
          if (load.pickupLatitude != null && load.pickupLongitude != null) {
            final distance = _calculateDistance(userLat, userLng, load.pickupLatitude!, load.pickupLongitude!);
            if (distance <= radiusLimit) {
              return load;
            }
          }
          return null;
        })).then((loads) => loads.whereType<LoadPost>().toList());
      }
    }

    // Return all carrier posts - no additional filtering by user role
    // The available loads screen should show all carrier postings
    return filtered;
  }

  List<LoadPost> getMyPostedLoads(User user) {
    return _loads.where((load) =>
      load.postedBy == user.id &&
      ((user.role == 'broker' && load.isBrokerPost) ||
       (user.role == 'carrier' && load.isCarrierPost))
    ).toList();
  }
}
