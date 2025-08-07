import 'lane_preference.dart';
import 'safer_web_snapshot.dart';

class User {
  String id;
  String name;
  String email;
  String phoneNumber;
  String? address;
  String companyName;
  String companyAddress;
  String? companyPhoneNumber;
  String? companyEmail;
  String? companyWebsite;
  String? companyLogoUrl;
  String? companyTaxId;
  String role;
  String? companyId;
  bool isLoggedIn;
  String password;
  String usDotMcNumber;
  String? firstName;
  String? lastName;
  String? addressLine1;
  String? addressLine2;
  String? country;
  String? stateProvince;
  String? city;
  String? postalZipCode;
  String? website;
  String? portOfEntry;
  String? currency;
  String? factoringCompany;
  String? paymentMethod;
  String? account;
  String? syncToQB;
  String? remarks;
  String? phoneExt;
  String? altPhoneNumber;
  String? altPhoneExt;
  String? faxNumber;
  String? referenceNumber;
  String? type;
  String? expenseType;
  List<String> equipment;
  String? loadType;
  List<LanePreference> lanePreferences;
  SaferWebSnapshot? saferWebSnapshot;
  double? distanceRadiusLimit; // Maximum distance in miles for load matching
  double? latitude;
  double? longitude;

  // New safer fields
  String? saferLegalName;
  String? saferEntityType;
  String? saferStatus;
  String? saferAddress;
  String? saferUsdotNumber;
  String? saferMcNumber;
  int? saferPowerUnits;
  int? saferDrivers;
  String? saferUsdotStatus;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.address,
    required this.companyName,
    required this.companyAddress,
    this.companyPhoneNumber,
    this.companyEmail,
    this.companyWebsite,
    this.companyLogoUrl,
    this.companyTaxId,
    required this.role,
    this.companyId,
    this.isLoggedIn = false,
    required this.password,
    required this.usDotMcNumber,
    this.firstName,
    this.lastName,
    this.addressLine1,
    this.addressLine2,
    this.country,
    this.stateProvince,
    this.city,
    this.postalZipCode,
    this.website,
    this.portOfEntry,
    this.currency,
    this.factoringCompany,
    this.paymentMethod,
    this.account,
    this.syncToQB,
    this.remarks,
    this.phoneExt,
    this.altPhoneNumber,
    this.altPhoneExt,
    this.faxNumber,
    this.referenceNumber,
    this.type,
    this.expenseType,
    this.equipment = const [],
    this.loadType,
    this.lanePreferences = const [],
    this.saferWebSnapshot,
    this.distanceRadiusLimit,
    this.latitude,
    this.longitude,
    this.saferLegalName,
    this.saferEntityType,
    this.saferStatus,
    this.saferAddress,
    this.saferUsdotNumber,
    this.saferMcNumber,
    this.saferPowerUnits,
    this.saferDrivers,
    this.saferUsdotStatus,
    required List loadPosts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Parse equipment list
    List<String> equipmentList = [];
    if (json['equipment'] != null) {
      if (json['equipment'] is String) {
        equipmentList = (json['equipment'] as String)
            .split(',')
            .where((e) => e.isNotEmpty)
            .map((e) => e.trim())
            .toList();
      } else if (json['equipment'] is List) {
        equipmentList = List<String>.from(json['equipment']);
      }
    }

    // Parse lane preferences
    List<LanePreference> lanePrefs = [];
    if (json['lanePreferences'] != null) {
      if (json['lanePreferences'] is String) {
        // Parse from pipe-separated string format
        lanePrefs = (json['lanePreferences'] as String)
            .split('|')
            .where((e) => e.isNotEmpty)
            .map((e) {
              final parts = e.split(':');
              return LanePreference(
                origin: parts[0],
                destination: parts[1],
              );
            })
            .toList();
      } else if (json['lanePreferences'] is List) {
        lanePrefs = (json['lanePreferences'] as List)
            .map((e) => LanePreference(
                  origin: e['origin'],
                  destination: e['destination'],
                ))
            .toList();
      }
    }

    SaferWebSnapshot? saferWebSnapshot;
    if (json['saferWebSnapshot'] != null) {
      saferWebSnapshot = SaferWebSnapshot.fromJson(json['saferWebSnapshot']);
    }

    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'],
      companyName: json['companyName'] ?? '',
      companyAddress: json['companyAddress'] ?? '',
      companyPhoneNumber: json['companyPhoneNumber'],
      companyEmail: json['companyEmail'],
      companyWebsite: json['companyWebsite'],
      companyLogoUrl: json['companyLogoUrl'],
      companyTaxId: json['companyTaxId'],
      role: json['role'] ?? '',
      companyId: json['companyId'],
      isLoggedIn: (json['isLoggedIn'] ?? 0) == 1,
      password: json['password'] ?? '',
      usDotMcNumber: json['usDotMcNumber'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      country: json['country'],
      stateProvince: json['stateProvince'],
      city: json['city'],
      postalZipCode: json['postalZipCode'],
      website: json['website'],
      portOfEntry: json['portOfEntry'],
      currency: json['currency'],
      factoringCompany: json['factoringCompany'],
      paymentMethod: json['paymentMethod'],
      account: json['account'],
      syncToQB: json['syncToQB'],
      remarks: json['remarks'],
      phoneExt: json['phoneExt'],
      altPhoneNumber: json['altPhoneNumber'],
      altPhoneExt: json['altPhoneExt'],
      faxNumber: json['faxNumber'],
      referenceNumber: json['referenceNumber'],
      type: json['type'],
      expenseType: json['expenseType'],
      equipment: equipmentList,
      loadType: json['loadType'],
      lanePreferences: lanePrefs,
      saferWebSnapshot: saferWebSnapshot,
      distanceRadiusLimit: json['distanceRadiusLimit'] != null ? double.tryParse(json['distanceRadiusLimit'].toString()) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      saferLegalName: json['safer_legal_name'],
      saferEntityType: json['safer_entity_type'],
      saferStatus: json['safer_status'],
      saferAddress: json['safer_address'],
      saferUsdotNumber: json['safer_usdot_number'],
      saferMcNumber: json['safer_mc_number'],
      saferPowerUnits: json['safer_power_units'],
      saferDrivers: json['safer_drivers'],
      saferUsdotStatus: json['safer_usdot_status'],
      loadPosts: [],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhoneNumber': companyPhoneNumber,
      'companyEmail': companyEmail,
      'companyWebsite': companyWebsite,
      'companyLogoUrl': companyLogoUrl,
      'companyTaxId': companyTaxId,
      'role': role,
      'companyId': companyId,
      'isLoggedIn': isLoggedIn ? 1 : 0,  // Convert bool to int for SQLite
      'password': password,
      'usDotMcNumber': usDotMcNumber,
      'firstName': firstName,
      'lastName': lastName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'country': country,
      'stateProvince': stateProvince,
      'city': city,
      'postalZipCode': postalZipCode,
      'website': website,
      'portOfEntry': portOfEntry,
      'currency': currency,
      'factoringCompany': factoringCompany,
      'paymentMethod': paymentMethod,
      'account': account,
      'syncToQB': syncToQB,
      'remarks': remarks,
      'phoneExt': phoneExt,
      'altPhoneNumber': altPhoneNumber,
      'altPhoneExt': altPhoneExt,
      'faxNumber': faxNumber,
      'referenceNumber': referenceNumber,
      'type': type,
      'expenseType': expenseType,
      'equipment': equipment.join(','),  // Convert List<String> to comma-separated string
      'loadType': loadType,
      'lanePreferences': lanePreferences.map((e) => '${e.origin}:${e.destination}').join('|'),  // Convert lane preferences to string
    };
    if (saferWebSnapshot != null) {
      data['saferWebSnapshot'] = saferWebSnapshot!.toJson();
    }
    if (distanceRadiusLimit != null) {
      data['distanceRadiusLimit'] = distanceRadiusLimit;
    }
    if (latitude != null) {
      data['latitude'] = latitude;
    }
    if (longitude != null) {
      data['longitude'] = longitude;
    }
    return data;
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User.fromJson(map);
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? companyName,
    String? companyAddress,
    String? companyPhoneNumber,
    String? companyEmail,
    String? companyWebsite,
    String? companyLogoUrl,
    String? companyTaxId,
    String? role,
    String? companyId,
    bool? isLoggedIn,
    String? password,
    String? usDotMcNumber,
    String? firstName,
    String? lastName,
    String? addressLine1,
    String? addressLine2,
    String? country,
    String? stateProvince,
    String? city,
    String? postalZipCode,
    String? website,
    String? portOfEntry,
    String? currency,
    String? factoringCompany,
    String? paymentMethod,
    String? account,
    String? syncToQB,
    String? remarks,
    String? phoneExt,
    String? altPhoneNumber,
    String? altPhoneExt,
    String? faxNumber,
    String? referenceNumber,
    String? type,
    String? expenseType,
    List<String>? equipment,
    String? loadType,
    List<LanePreference>? lanePreferences,
    double? distanceRadiusLimit,
    double? latitude,
    double? longitude,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhoneNumber: companyPhoneNumber ?? this.companyPhoneNumber,
      companyEmail: companyEmail ?? this.companyEmail,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      companyTaxId: companyTaxId ?? this.companyTaxId,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      password: password ?? this.password,
      usDotMcNumber: usDotMcNumber ?? this.usDotMcNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      country: country ?? this.country,
      stateProvince: stateProvince ?? this.stateProvince,
      city: city ?? this.city,
      postalZipCode: postalZipCode ?? this.postalZipCode,
      website: website ?? this.website,
      portOfEntry: portOfEntry ?? this.portOfEntry,
      currency: currency ?? this.currency,
      factoringCompany: factoringCompany ?? this.factoringCompany,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      account: account ?? this.account,
      syncToQB: syncToQB ?? this.syncToQB,
      remarks: remarks ?? this.remarks,
      phoneExt: phoneExt ?? this.phoneExt,
      altPhoneNumber: altPhoneNumber ?? this.altPhoneNumber,
      altPhoneExt: altPhoneExt ?? this.altPhoneExt,
      faxNumber: faxNumber ?? this.faxNumber,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      type: type ?? this.type,
      expenseType: expenseType ?? this.expenseType,
      equipment: equipment ?? this.equipment,
      loadType: loadType ?? this.loadType,
      lanePreferences: lanePreferences ?? this.lanePreferences,
      distanceRadiusLimit: distanceRadiusLimit ?? this.distanceRadiusLimit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      loadPosts: [],
    );
  }

  bool get isBroker => role.toLowerCase() == 'broker';
  bool get isCarrier => role.toLowerCase() == 'carrier';
  bool get isAdmin => role.toLowerCase() == 'admin';

  String? get fullName => firstName != null && lastName != null
      ? '$firstName $lastName'
      : name;

  String get displayName => name.isNotEmpty ? name : email;

  bool get isBrokerPost => isBroker || isAdmin;
  bool get isCarrierPost => isCarrier || isAdmin;

  bool get hasCompanyInfo => companyName.isNotEmpty && companyAddress.isNotEmpty;
  bool get hasContactInfo => phoneNumber.isNotEmpty && email.isNotEmpty;
  bool get hasSaferInfo => saferUsdotNumber != null && saferMcNumber != null;
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasDistanceRadius => distanceRadiusLimit != null && distanceRadiusLimit! > 0;

  String get initials {
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length > 1) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  String get formattedPhoneNumber {
    if (phoneNumber.isEmpty) return 'Not provided';
    // Basic US phone formatting
    final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phoneNumber;
  }

  String get companyDisplayName => companyName.isNotEmpty ? companyName : name;

  Map<String, dynamic> get locationInfo => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'city': city,
    'state': stateProvince,
    'country': country,
    'postalCode': postalZipCode,
  };

  bool get isProfileComplete => 
    name.isNotEmpty && 
    email.isNotEmpty && 
    phoneNumber.isNotEmpty && 
    companyName.isNotEmpty && 
    companyAddress.isNotEmpty;

  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'broker':
        return 'Broker';
      case 'carrier':
        return 'Carrier';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  String get equipmentDisplay => equipment.isNotEmpty ? equipment.join(', ') : 'Not specified';
  String get lanePreferencesDisplay => lanePreferences.isNotEmpty 
    ? lanePreferences.map((l) => '${l.origin} → ${l.destination}').join(', ')
    : 'No preferences';

  // Analytics getters for API integration
  int? get totalLoads => null; // Will be populated from API
  double? get totalRevenue => null; // Will be populated from API
  double? get averageRatePerMile => null; // Will be populated from API
  DateTime? get createdAt => null; // Will be populated from API
  DateTime? get updatedAt => null; // Will be populated from API
  String? get mcNumber => saferMcNumber;
  String? get dotNumber => saferUsdotNumber;
  String? get equipmentType => equipment.isNotEmpty ? equipment.first : null;
  String? get region => stateProvince;
  bool? get isVerified => null; // Will be populated from API
  String? get avatarUrl => companyLogoUrl;
  List get loadPosts => []; // Will be populated from API

  bool prefersLane(String origin, String destination) {
    if (lanePreferences.isEmpty) return true; // No preference means all lanes
    return lanePreferences.any((lane) => lane.matches(origin, destination));
  }
}
