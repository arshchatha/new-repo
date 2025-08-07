class SaferWebSnapshot {
  final String legalName;
  final String entityType;
  final String status;
  final String address;
  final String? usdotNumber;
  final String? mcNumber;
  final int? powerUnits;
  final int? drivers;
  final Map<String, dynamic>? inspectionSummary;
  final Map<String, dynamic>? crashSummary;
  final UsInspectionSummary? usInspections;
  final String? usdotStatus;
  final List<String>? operationClassification;
  final List<String>? carrierOperation;
  final List<String>? cargoCarried;

  SaferWebSnapshot({
    required this.legalName,
    required this.entityType,
    required this.status,
    required this.address,
    this.usdotNumber,
    this.mcNumber,
    this.powerUnits,
    this.drivers,
    this.inspectionSummary,
    this.crashSummary,
    this.usInspections,
    this.usdotStatus,
    this.operationClassification,
    this.carrierOperation,
    this.cargoCarried,
  });

  factory SaferWebSnapshot.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      } else if (value is String) {
        // Handle comma-separated string
        return value.split(',').map((s) => s.trim()).toList();
      }
      return [];
    }

    return SaferWebSnapshot(
      legalName: json['legal_name'] ?? json['dba_name'] ?? 'N/A',
      entityType: json['entity_type'] ?? json['entityType'] ?? (json['usdot_number'] != null ? 'Carrier' : 'Broker'),
      status: json['operating_status'] ?? 'UNKNOWN',
      address: json['physical_address'] ?? json['address'] ?? 'N/A',
      usdotNumber: json['usdot_number']?.toString(),
      mcNumber: json['mc_mx_ff_number']?.toString(),
      powerUnits: json['power_units']?.toInt(),
      drivers: json['drivers']?.toInt(),
      inspectionSummary: json['inspection_summary'] as Map<String, dynamic>?,
      crashSummary: json['crash_summary'] as Map<String, dynamic>?,
      usInspections: json['us_inspections'] != null ? UsInspectionSummary.fromJson(json['us_inspections']) : null,
      usdotStatus: json['usdot_status']?.toString(),
      operationClassification: parseStringList(json['operation_classification']),
      carrierOperation: parseStringList(json['carrier_operation']),
      cargoCarried: parseStringList(json['cargo_carried']),
    );
  }

  String get companyName => legalName;
  String get companyAddress => address;
  String get dbaName => legalName; // Alias for compatibility
  String get city => address.split(',').length > 1 ? address.split(',')[1].trim() : '';
  String get state => address.split(',').length > 2 ? address.split(',')[2].trim() : '';
  String get zip => address.split(',').length > 3 ? address.split(',')[3].trim() : '';

  int? get phoneNumber => inspectionSummary?['phone']?.toInt();
  String? get safetyRating => inspectionSummary?['safety_rating'] ?? 'Not Rated';

  String? get usdot => usdotNumber;
  String? get usdotNumberValue => usdotNumber;
  String? get usdotStatusValue => usdotStatus;
  String? get operatingStatus => status;
  String? get mcNumberValue => mcNumber;
  String? get entityTypeValue => entityType;
  String? get legalNameValue => legalName;
  String? get addressValue => address;
  Map<String, dynamic>? get inspectionSummaryValue => inspectionSummary;
  Map<String, dynamic>? get crashSummaryValue => crashSummary;
  UsInspectionSummary? get usInspectionsValue => usInspections;

  // Additional computed getters
  bool get isActive => status.toLowerCase() == 'active';
  bool get isOutOfService => status.toLowerCase() == 'out of service';
  bool get hasValidUsdot => usdotNumber != null && usdotNumber!.isNotEmpty;
  bool get hasValidMcNumber => mcNumber != null && mcNumber!.isNotEmpty;
  String get displayStatus => status.toUpperCase();
  String get displayAddress => address.isNotEmpty ? address : 'Address not available';
  String get displayPowerUnits => powerUnits?.toString() ?? '0';
  String get displayDrivers => drivers?.toString() ?? '0';
  
  // Safety rating display
  String get safetyRatingDisplay {
    final rating = inspectionSummary?['safety_rating'];
    if (rating == null || rating == 'Not Rated') return 'Not Rated';
    return rating.toString();
  }

  String get safetyRatingColor {
    final rating = inspectionSummary?['safety_rating'];
    if (rating == null) return 'gray';
    switch (rating.toString().toUpperCase()) {
      case 'SATISFACTORY':
        return 'green';
      case 'CONDITIONAL':
        return 'orange';
      case 'UNSATISFACTORY':
        return 'red';
      default:
        return 'gray';
    }
  }

  DateTime? get mcs150MileageUpdated => DateTime(inspectionSummary?['mcs150_mileage_updated'] ?? 0);

  int? get mcs150Mileage => inspectionSummary?['mcs150_mileage']?.toInt();

  DateTime? get mcs150Date => inspectionSummary?['mcs150_date'] != null
      ? DateTime.parse(inspectionSummary!['mcs150_date'])
      : null;

  int? get mcs150DateUpdated => inspectionSummary?['mcs150_date_updated']?.toInt();

  DateTime? get insuranceRenewalDate => inspectionSummary?['insurance_renewal_date'] != null
      ? DateTime.parse(inspectionSummary!['insurance_renewal_date'])
      : null;

  DateTime? get lastUpdated => DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'legal_name': legalName,
      'entity_type': entityType,
      'status': status,
      'address': address,
      'Phone': phoneNumber,
      'usdot_number': usdotNumber,
      'mc_mx_ff_number': mcNumber,
      'power_units': powerUnits,
      'drivers': drivers,
      'mcs150_mileage': mcs150Mileage,
      'mcs150_mileage_updated': mcs150MileageUpdated?.toIso8601String(),
      'inspection_summary': inspectionSummary,
      'crash_summary': crashSummary,
      'us_inspections': usInspections?.toJson(),
      'usdot_status': usdotStatus,
      'mcs150_date': mcs150Date?.toIso8601String(),
      'mcs150_date_updated': mcs150DateUpdated,
      'insurance_renewal_date': insuranceRenewalDate?.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
      
    };
  }
}

class UsInspectionCategory {
  final int outOfService;
  final String outOfServicePercent;
  final String nationalAverage;
  final int inspections;


  UsInspectionCategory({
  
    required this.outOfService,
    required this.outOfServicePercent,
    required this.nationalAverage,
    required this.inspections, required String lastUpdated,
  });

  factory UsInspectionCategory.fromJson(Map<String, dynamic> json) {
    return UsInspectionCategory(
      outOfService: json['out_of_service'] ?? 0,
      outOfServicePercent: json['out_of_service_percent'] ?? '0%',
      nationalAverage: json['national_average'] ?? 'N/A',
      inspections: json['inspections'] ?? 0,
      lastUpdated: DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'out_of_service': outOfService,
      'out_of_service_percent': outOfServicePercent,
      'national_average': nationalAverage,
      'inspections': inspections,
      'last_updated': DateTime.now().toIso8601String(),

    };
  }
}

class UsInspectionSummary {
  final UsInspectionCategory driver;
  final UsInspectionCategory vehicle;
  final UsInspectionCategory hazmat;
  final UsInspectionCategory iep;


  UsInspectionSummary({
    required this.driver,
    required this.vehicle,
    required this.hazmat,
    required this.iep,
  });

  factory UsInspectionSummary.fromJson(Map<String, dynamic> json) {
    return UsInspectionSummary(
      driver: UsInspectionCategory.fromJson(json['driver'] ?? {}),
      vehicle: UsInspectionCategory.fromJson(json['vehicle'] ?? {}),
      hazmat: UsInspectionCategory.fromJson(json['hazmat'] ?? {}),
      iep: UsInspectionCategory.fromJson(json['iep'] ?? {}),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      "us_inspections": {
        'driver': driver.toJson(),
        'vehicle': vehicle.toJson(),
        'hazmat': hazmat.toJson(),
        'iep': iep.toJson(),
        'last_updated': DateTime.now().toIso8601String(),
      },
    };
  }
}
