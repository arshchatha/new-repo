import 'package:lboard/core/core/database/database_helper.dart';
import 'package:lboard/core/services/haversine_distance_service.dart';

class LoadPost {
  final String id;
  final String title;
  final String description;
  final String pickupDate;
  final String deliveryDate;
  final String weight;
  final String dimensions;
  final String rate;
  final String origin;
  final String destination;
  final bool isBrokerPost;
  final bool isCarrierPost; // Added for clarity
  final String? typingIndicator; // New field for typing indicators
  final String postedBy;
  String? postedByName;
  String? contactPerson;
  String? contactPhone;
  String? contactEmail;
  String? contactAddress;
  String? loadType;
  String? country;
  final List<LoadPostQuote> bids;
  final List<String> equipment;
  
  // Add missing timestamp fields
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Add missing fields for analytics
  final bool isActive;
  final int volume;
  final bool isbroken;
  final bool isbooked;

  // New fields to define
  String? originCity;
  String? originCountry;
  String? originState;
  String? originPostalCode;
  String? originDescription;

  String? destinationCity;
  String? destinationCountry;
  String? destinationState;
  String? destinationPostalCode;
  String? destinationDescription;

  String? pickupTime;
  String? deliveryTime;
  bool? appointment;

  // Enhanced fields for better load board functionality
  String? distance;
  String? destinationDifference;
  String? _status;
  List<LoadPost>? matchingLoads;
  double? pickupLatitude;
  double? pickupLongitude;
  double? destinationLatitude;
  double? destinationLongitude;
  int? originRadius;
  int? destinationRadius;

  // New safetyRating field
  String? safetyRating;

  // Carrier confirmation flow fields
  String? selectedBidId;
  bool brokerConfirmed;
  bool carrierConfirmed;

  // Calculate destination difference with another load
  Future<void> calculateDestinationDifference(LoadPost otherLoad, Future<String?> Function(String, String) distanceCalculator) async {
    if (destination.isEmpty || otherLoad.destination.isEmpty) {
      destinationDifference = null;
      return;
    }
    try {
      destinationDifference = await distanceCalculator(destination, otherLoad.destination);
    } catch (e) {
      destinationDifference = 'Error calculating';
    }
  }

  LoadPost({
    required this.id,
    required this.title,
    required this.origin,
    required this.destination,
    required this.isBrokerPost,
    required this.isCarrierPost,
    required this.postedBy,
    required this.isActive,
    required this.volume,
    required this.isbroken,
    required this.isbooked,
    this.brokerConfirmed = false,
    this.carrierConfirmed = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.description = '',
    this.pickupDate = '',
    this.deliveryDate = '',
    this.weight = '',
    this.dimensions = '',
    this.rate = '',
    this.bids = const [],
    this.equipment = const [],
    this.loadType,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.originRadius,
    this.destinationRadius,
    this.distance,
    this.matchingLoads,
    this.country,
    this.safetyRating,
    this.selectedBidId,
    this.originCity,
    this.originCountry,
    this.originState,
    this.originPostalCode,
    this.originDescription,
    this.destinationCity,
    this.destinationCountry,
    this.destinationState,
    this.destinationPostalCode,
    this.destinationDescription,
    this.pickupTime,
    this.deliveryTime,
    this.appointment = false,
    String? status,
    this.typingIndicator = '',
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       _status = status;

  // Status getter with default value
  String get status => _status ?? (bids.isNotEmpty ? 'Has Bids' : 'Available');
  set status(String? value) => _status = value;

  // Helper method to get parsed address components
  List<String> get originParts {
    final parts = origin.split(',').map((e) => e.trim()).toList();
    while (parts.length < 4) {
      parts.add('');
    }
    return parts;
  }

  List<String> get destinationParts {
    final parts = destination.split(',').map((e) => e.trim()).toList();
    while (parts.length < 4) {
      parts.add('');
    }
    return parts;
  }

  // Helper method to get equipment as a formatted string
  String get equipmentString => equipment.join(', ');
  
  // Add equipmentType getter for analytics compatibility
  String? get equipmentType => equipment.isNotEmpty ? equipment.first : null;

  // Helper method to get formatted pickup date
  String get formattedPickupDate {
    if (pickupDate.isEmpty) return 'Not specified';
    try {
      if (pickupDate.length >= 10) {
        return pickupDate.substring(0, 10);
      }
      return pickupDate;
    } catch (e) {
      return pickupDate;
    }
  }

  // Helper method to get formatted delivery date
  String get formattedDeliveryDate {
    if (deliveryDate.isEmpty) return 'Not specified';
    try {
      if (deliveryDate.length >= 10) {
        return deliveryDate.substring(0, 10);
      }
      return deliveryDate;
    } catch (e) {
      return deliveryDate;
    }
  }

  // Helper method to get formatted rate
  String get formattedRate {
    try {
      final parsedRate = double.tryParse(rate);
      if (parsedRate != null) {
        return '\$${parsedRate.toStringAsFixed(2)}';
      }
      return rate;
    } catch (e) {
      return rate;
    }
  }

  // Helper method to check if load matches search criteria
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    return id.toLowerCase().contains(lowerQuery) ||
           title.toLowerCase().contains(lowerQuery) ||
           origin.toLowerCase().contains(lowerQuery) ||
           destination.toLowerCase().contains(lowerQuery) ||
           loadType?.toLowerCase().contains(lowerQuery) == true ||
           equipment.any((eq) => eq.toLowerCase().contains(lowerQuery));
  }

  // Helper method to check if load matches filters
  bool matchesFilters({
    String? statusFilter,
    String? equipmentFilter,
    String? loadTypeFilter,
    String? originFilter,
    String? destinationFilter,
  }) {
    if (statusFilter != null && statusFilter.isNotEmpty && status != statusFilter) {
      return false;
    }
    if (equipmentFilter != null && equipmentFilter.isNotEmpty && 
        !equipment.any((eq) => eq.toLowerCase().contains(equipmentFilter.toLowerCase()))) {
      return false;
    }
    if (loadTypeFilter != null && loadTypeFilter.isNotEmpty && 
        (loadType?.toLowerCase() != loadTypeFilter.toLowerCase())) {
      return false;
    }
    if (originFilter != null && originFilter.isNotEmpty && 
        !origin.toLowerCase().contains(originFilter.toLowerCase())) {
      return false;
    }
    if (destinationFilter != null && destinationFilter.isNotEmpty && 
        !destination.toLowerCase().contains(destinationFilter.toLowerCase())) {
      return false;
    }
    return true;
  }

  Future<List<LoadPost>> fetchAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('loads');
    return List<LoadPost>.from(maps.map((map) => LoadPost.fromMap(map)));
  }

  static Future<int> countUniquePostedBy() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(DISTINCT postedBy) as count FROM loads');
    return (result.first['count'] as int?) ?? 0;
  }

  factory LoadPost.fromMap(Map<String, dynamic> map) {
    final post = LoadPost(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      pickupDate: map['pickupDate'] ?? '',
      deliveryDate: map['deliveryDate'] ?? '',
      weight: map['weight'] ?? '',
      dimensions: map['dimensions'] ?? '',
      rate: map['rate'] != null ? map['rate'].toString() : '',
      origin: map['origin'],
      destination: map['destination'],
      isBrokerPost: map['isBrokerPost'] == 1,
      postedBy: map['postedBy'],
      isCarrierPost: map['isCarrierPost'] == 1, // Added for clarity
      bids: (map['bids'] as String?)
          ?.split(';')
          .map((b) => LoadPostQuote.fromString(b))
          .toList() ??
          [],
      equipment: (map['equipment'] as String?)?.split(';') ?? [],
      loadType: map['loadType'],
      country: map['country'],
      pickupLatitude: map['pickupLatitude'] is double ? map['pickupLatitude'] : (map['pickupLatitude'] is int ? (map['pickupLatitude'] as int).toDouble() : null),
      pickupLongitude: map['pickupLongitude'] is double ? map['pickupLongitude'] : (map['pickupLongitude'] is int ? (map['pickupLongitude'] as int).toDouble() : null),
      destinationLatitude: map['destinationLatitude'] is double ? map['destinationLatitude'] : (map['destinationLatitude'] is int ? (map['destinationLatitude'] as int).toDouble() : null),
      destinationLongitude: map['destinationLongitude'] is double ? map['destinationLongitude'] : (map['destinationLongitude'] is int ? (map['destinationLongitude'] as int).toDouble() : null),
      originRadius: map['originRadius'] is int ? map['originRadius'] : (map['originRadius'] is double ? (map['originRadius'] as double).round() : null),
      destinationRadius: map['destinationRadius'] is int ? map['destinationRadius'] : (map['destinationRadius'] is double ? (map['destinationRadius'] as double).round() : null),
      safetyRating: map['safetyRating'], // Added safetyRating mapping

      // Carrier confirmation fields
      selectedBidId: map['selectedBidId'],
      brokerConfirmed: map['brokerConfirmed'] == 1,
      carrierConfirmed: map['carrierConfirmed'] == 1,

      // New fields mapping
      originCity: map['originCity'],
      originCountry: map['originCountry'],
      originState: map['originState'],
      originPostalCode: map['originPostalCode'],
      originDescription: map['originDescription'],

      destinationCity: map['destinationCity'],
      destinationCountry: map['destinationCountry'],
      destinationState: map['destinationState'],
      destinationPostalCode: map['destinationPostalCode'],
      destinationDescription: map['destinationDescription'],

      pickupTime: map['pickupTime'],
      deliveryTime: map['deliveryTime'],
      appointment: map['appointment'] == 1,
      isActive: map['isActive'] == 1,
      volume: map['volume'] ?? 0,
      status: map['status'] ?? 'available',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      isbroken: map['isbroken'] == 1,
      isbooked: map['isbooked'] == 1,
    );

    post.contactEmail = map['contactEmail'];
    post.contactPhone = map['contactPhone'];
    post.distance = map['distance']?.toString();
    post.destinationDifference = map['destinationDifference']?.toString();
    post._status = map['status'];
    return post;
  }

  bool get pickup => pickupLatitude != null && pickupLongitude != null;
  

  // 1. Distance between pickup and delivery locations for this load
  String? get pickupToDeliveryDistance {
    if (pickupLatitude == null || 
        pickupLongitude == null || 
        destinationLatitude == null || 
        destinationLongitude == null) {
      return null;
    }
    
    final double distanceKm = HaversineDistanceService.calculateDistance(
      pickupLatitude!,
      pickupLongitude!,
      destinationLatitude!,
      destinationLongitude!,
    );
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  // 2. Distance between pickup addresses of two loads
  String? pickupToPickupDistance(LoadPost otherLoad) {
    if (pickupLatitude == null || 
        pickupLongitude == null || 
        otherLoad.pickupLatitude == null || 
        otherLoad.pickupLongitude == null) {
      return null;
    }
    
    final double distanceKm = HaversineDistanceService.calculateDistance(
      pickupLatitude!,
      pickupLongitude!,
      otherLoad.pickupLatitude!,
      otherLoad.pickupLongitude!,
    );
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  // 3. Distance between destination addresses of two loads
  String? destinationToDestinationDistance(LoadPost otherLoad) {
    if (destinationLatitude == null || 
        destinationLongitude == null || 
        otherLoad.destinationLatitude == null || 
        otherLoad.destinationLongitude == null) {
      return null;
    }
    
    final double distanceKm = HaversineDistanceService.calculateDistance(
      destinationLatitude!,
      destinationLongitude!,
      otherLoad.destinationLatitude!,
      otherLoad.destinationLongitude!,
    );
    return '${distanceKm.toStringAsFixed(2)} km';
  }

  // Legacy method for backward compatibility (uses pickup-to-pickup distance)
  String? calculateDistanceTo(LoadPost other) {
    return pickupToPickupDistance(other);
  }

  // Find matching loads within specified pickup and destination radii
  Future<List<LoadPost>> findMatchingLoads({
    required int pickupRadiusKm,
    required int destinationRadiusKm,
  }) async {
    final allLoads = await fetchAll();
    final matchingLoads = <LoadPost>[];
    
    for (final load in allLoads) {
      // Skip same load
      if (load.id == id) continue;
      
      // Get distances
      final pickupDist = pickupToPickupDistance(load);
      final destDist = destinationToDestinationDistance(load);
      
      if (pickupDist == null || destDist == null) continue;
      
      // Extract numeric distance values
      final pickupDistValue = double.tryParse(pickupDist.split(' ')[0]);
      final destDistValue = double.tryParse(destDist.split(' ')[0]);
      
      if (pickupDistValue != null && 
          destDistValue != null &&
          pickupDistValue <= pickupRadiusKm &&
          destDistValue <= destinationRadiusKm) {
        matchingLoads.add(load);
      }
    }
    
    return matchingLoads;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pickupDate': pickupDate,
      'deliveryDate': deliveryDate,
      'weight': weight,
      'dimensions': dimensions,
      'rate': rate,
      'origin': origin,
      'destination': destination,
      'isBrokerPost': isBrokerPost ? 1 : 0,
      'postedBy': postedBy,
      'bids': bids.map((b) => b.toString()).join(';'),
      'equipment': equipment.join(';'),
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'loadType': loadType,
      'country': country,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'originRadius': originRadius,
      'destinationRadius': destinationRadius,
      'distance': distance,
      'isCarrierPost': isCarrierPost ? 1 : 0, // Added for clarity
      'contactPerson': contactPerson,
      'contactAddress': contactAddress,
      'postedByName': postedByName,
      'destinationDifference': destinationDifference,
      'status': _status,
      'safetyRating': safetyRating, // Added safetyRating to map

      // Carrier confirmation fields
      'selectedBidId': selectedBidId,
      'brokerConfirmed': brokerConfirmed ? 1 : 0,
      'carrierConfirmed': carrierConfirmed ? 1 : 0,

      // New fields
      'originCity': originCity,
      'originCountry': originCountry,
      'originState': originState,
      'originPostalCode': originPostalCode,
      'originDescription': originDescription,

      'destinationCity': destinationCity,
      'destinationCountry': destinationCountry,
      'destinationState': destinationState,
      'destinationPostalCode': destinationPostalCode,
      'destinationDescription': destinationDescription,

      'pickupTime': pickupTime,
      'deliveryTime': deliveryTime,
      'appointment': appointment == true ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'volume': volume,
      'isbroken': isbroken ? 1 : 0,
      'isbooked': isbooked ? 1 : 0,
    };
  }

  // Create a copy of the load post with updated fields
  LoadPost copyWith({
    String? id,
    String? title,
    String? description,
    String? pickupDate,
    String? deliveryDate,
    String? weight,
    String? dimensions,
    String? rate,
    String? origin,
    String? destination,
    bool? isBrokerPost,
    String? postedBy,
    List<LoadPostQuote>? bids,
    List<String>? equipment,
    String? loadType,
    String? distance,
    String? destinationDifference,
    String? status,
    List<LoadPost>? matchingLoads,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    int? originRadius,
    int? destinationRadius,
    String? safetyRating,
    String? selectedBidId,
    bool? brokerConfirmed,
    bool? carrierConfirmed,
  }) {
    final newPost = LoadPost(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      rate: rate ?? this.rate,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      isBrokerPost: isBrokerPost ?? this.isBrokerPost,
      postedBy: postedBy ?? this.postedBy,
      bids: bids ?? this.bids,
      equipment: equipment ?? this.equipment,
      loadType: loadType ?? this.loadType,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude: destinationLongitude ?? this.destinationLongitude,
      originRadius: originRadius ?? this.originRadius,
      destinationRadius: destinationRadius ?? this.destinationRadius,
      country: country,
      safetyRating: safetyRating ?? this.safetyRating,
      selectedBidId: selectedBidId ?? this.selectedBidId,
      brokerConfirmed: brokerConfirmed ?? this.brokerConfirmed,
      carrierConfirmed: carrierConfirmed ?? this.carrierConfirmed,
      isCarrierPost: isCarrierPost,
      isActive: true, // Assuming active by default
      volume: 0, // Assuming default volume
      status: status ?? _status ?? 'available',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isbroken: false,
      isbooked: false,
    );

    newPost.contactEmail = contactEmail;
    newPost.contactPhone = contactPhone;
    newPost.contactPerson = contactPerson;
    newPost.contactAddress = contactAddress;
    newPost.postedByName = postedByName;
    newPost.distance = distance ?? newPost.distance;
    newPost.destinationDifference = destinationDifference ?? newPost.destinationDifference;
    newPost._status = status ?? _status;
    newPost.matchingLoads = matchingLoads ?? newPost.matchingLoads;

    return newPost;
  }
}

class LoadPostQuote {
  final String bidder;
  final double amount;
  final String bidStatus; // e.g., 'pending', 'accepted', 'rejected', 'countered'
  final double? counterBidAmount; // For raised bids by broker

  LoadPostQuote({
    required this.bidder,
    required this.amount,
    this.bidStatus = 'pending',
    this.counterBidAmount,
  });

  factory LoadPostQuote.fromString(String quote) {
    if (quote.isEmpty) {
      return LoadPostQuote(bidder: 'Unknown', amount: 0.0);
    }

    final parts = quote.split(':');
    if (parts.length < 2) {
      return LoadPostQuote(bidder: 'Unknown', amount: 0.0);
    }

    final double? amount = double.tryParse(parts[1]);
    String bidStatus = 'pending';
    double? counterBidAmount;

    if (parts.length >= 3) {
      bidStatus = parts[2];
    }
    if (parts.length >= 4) {
      counterBidAmount = double.tryParse(parts[3]);
    }

    if (amount == null) {
      return LoadPostQuote(bidder: parts[0], amount: 0.0, bidStatus: bidStatus, counterBidAmount: counterBidAmount);
    }

    return LoadPostQuote(bidder: parts[0], amount: amount, bidStatus: bidStatus, counterBidAmount: counterBidAmount);
  }

  @override
  String toString() {
    return '$bidder:$amount:$bidStatus:${counterBidAmount ?? ''}';
  }
}
