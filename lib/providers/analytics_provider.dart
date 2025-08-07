import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/load_post.dart';

class AnalyticsProvider with ChangeNotifier {
  // Local data state
  List<User> _searchResults = [];
  bool _isSearching = false;
  String _searchError = '';
  User? _selectedUser;
  List<LoadPost> _userLoads = [];
  
  // Analytics data
  Map<String, dynamic> _userAnalytics = {};
  List<Map<String, dynamic>> _laneRates = [];
  Map<String, dynamic> _marketTrends = {};
  List<Map<String, dynamic>> _brokerSales = [];
  List<Map<String, dynamic>> _carrierSales = [];
  
  // Local data sources
  List<LoadPost> _allLoads = [];
  List<User> _allUsers = [];

  // Getters
  List<User> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchError => _searchError;
  User? get selectedUser => _selectedUser;
  List<LoadPost> get userLoads => _userLoads;
  Map<String, dynamic> get userAnalytics => _userAnalytics;
  List<Map<String, dynamic>> get laneRates => _laneRates;
  Map<String, dynamic> get marketTrends => _marketTrends;
  List<Map<String, dynamic>> get brokerSales => _brokerSales;
  List<Map<String, dynamic>> get carrierSales => _carrierSales;

  // Initialize with local data
  void initializeLocalData(List<LoadPost> loads, List<User> users) {
    _allLoads = loads;
    _allUsers = users;
    notifyListeners();
  }

  // Search users locally
  Future<void> searchUsers({
    String? dotNumber,
    String? mcNumber,
    String? companyName,
    String? location,
    bool refresh = false,
  }) async {
    _isSearching = true;
    _searchError = '';
    notifyListeners();

    try {
      // Filter users based on local data
      List<User> filteredUsers = _allUsers.where((user) {
        bool matches = true;
        
        if (dotNumber != null && dotNumber.isNotEmpty) {
          matches = matches && user.usDotMcNumber.contains(dotNumber);
        }
        
        if (mcNumber != null && mcNumber.isNotEmpty) {
          matches = matches && user.usDotMcNumber.contains(mcNumber);
        }
        
        if (companyName != null && companyName.isNotEmpty) {
          matches = matches && user.companyName.toLowerCase().contains(companyName.toLowerCase()) == true;
        }
        
        if (location != null && location.isNotEmpty) {
          matches = matches && user.address?.toLowerCase().contains(location.toLowerCase()) == true;
        }
        
        return matches;
      }).toList();

      _searchResults = filteredUsers;
    } catch (e) {
      _searchError = 'Error searching users: ${e.toString()}';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Select user and calculate local analytics
  Future<void> selectUser(User user) async {
    _selectedUser = user;
    notifyListeners();

    try {
      // Calculate user analytics from local load data
      _userLoads = _allLoads.where((load) => load.postedBy == user.id).toList();
      _calculateUserAnalytics(user);
      notifyListeners();
    } catch (e) {
      _searchError = 'Error loading user data: ${e.toString()}';
      notifyListeners();
    }
  }

  // Calculate user analytics from local data
  void _calculateUserAnalytics(User user) {
    final userLoads = _allLoads.where((load) => load.postedBy == user.id).toList();
    final completedLoads = userLoads.where((load) => load.status == 'completed').toList();
    
    double totalRevenue = 0.0;
    double totalMiles = 0.0;
    int totalLoads = completedLoads.length;

    for (final load in completedLoads) {
      if (load.bids.isNotEmpty) {
        final winningBid = load.bids.reduce((a, b) => a.amount > b.amount ? a : b);
        totalRevenue += winningBid.amount;
        
        if (load.distance != null) {
          final distanceStr = load.distance!.replaceAll(RegExp(r'[^0-9.]'), '');
          totalMiles += double.tryParse(distanceStr) ?? 0.0;
        }
      }
    }

    _userAnalytics = {
      'totalLoads': totalLoads,
      'totalRevenue': totalRevenue,
      'avgRate': totalMiles > 0 ? totalRevenue / totalMiles : 0.0,
    };
  }

  // Clear search
  void clearSearch() {
    _searchResults.clear();
    _selectedUser = null;
    _userLoads.clear();
    _userAnalytics.clear();
    _searchError = '';
    notifyListeners();
  }

  // Calculate lane rates from local data
  Future<void> loadLaneRates({
    required String origin,
    required String destination,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final laneLoads = _allLoads.where((load) {
        bool matches = load.origin == origin && load.destination == destination;
        
        if (dateFrom != null) {
          matches = matches && load.createdAt.isAfter(dateFrom);
        }
        
        if (dateTo != null) {
          matches = matches && load.createdAt.isBefore(dateTo);
        }
        
        return matches && load.status == 'completed';
      }).toList();

      final laneRatesMap = <String, List<double>>{};
      
      for (final load in laneLoads) {
        if (load.bids.isNotEmpty) {
          final winningBid = load.bids.reduce((a, b) => a.amount > b.amount ? a : b);
          final lane = '${load.origin} → ${load.destination}';
          
          if (!laneRatesMap.containsKey(lane)) {
            laneRatesMap[lane] = [];
          }
          laneRatesMap[lane]!.add(winningBid.amount);
        }
      }

      _laneRates = laneRatesMap.entries.map((entry) {
        final rates = entry.value;
        final avgRate = rates.reduce((a, b) => a + b) / rates.length;
        return {
          'lane': entry.key,
          'avgRate': avgRate,
          'count': rates.length,
        };
      }).toList();
      
      notifyListeners();
    } catch (e) {
      _searchError = 'Error loading lane rates: ${e.toString()}';
      notifyListeners();
    }
  }

  // Calculate market trends from local data
  Future<void> loadMarketTrends({
    String? region,
    String? equipmentType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final relevantLoads = _allLoads.where((load) {
        bool matches = load.status == 'completed';
        
        if (region != null) {
          matches = matches && (load.origin.contains(region) || load.destination.contains(region));
        }
        
        if (equipmentType != null) {
          matches = matches && load.equipmentType == equipmentType;
        }
        
        if (dateFrom != null) {
          matches = matches && load.createdAt.isAfter(dateFrom);
        }
        
        if (dateTo != null) {
          matches = matches && load.createdAt.isBefore(dateTo);
        }
        
        return matches;
      }).toList();

      double totalRevenue = 0.0;
      double totalMiles = 0.0;
      int totalLoads = relevantLoads.length;

      for (final load in relevantLoads) {
        if (load.bids.isNotEmpty) {
          final winningBid = load.bids.reduce((a, b) => a.amount > b.amount ? a : b);
          totalRevenue += winningBid.amount;
          
          if (load.distance != null) {
            final distanceStr = load.distance!.replaceAll(RegExp(r'[^0-9.]'), '');
            totalMiles += double.tryParse(distanceStr) ?? 0.0;
          }
        }
      }

      _marketTrends = {
        'totalLoads': totalLoads,
        'totalRevenue': totalRevenue,
        'avgRatePerMile': totalMiles > 0 ? totalRevenue / totalMiles : 0.0,
      };
      
      notifyListeners();
    } catch (e) {
      _searchError = 'Error loading market trends: ${e.toString()}';
      notifyListeners();
    }
  }

  // Calculate broker sales from local data
  Future<void> loadBrokerSales({
    String? brokerId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final brokerLoads = _allLoads.where((load) {
        bool matches = load.status == 'completed';
        
        if (brokerId != null) {
          matches = matches && load.postedBy == brokerId;
        }
        
        if (dateFrom != null) {
          matches = matches && load.createdAt.isAfter(dateFrom);
        }
        
        if (dateTo != null) {
          matches = matches && load.createdAt.isBefore(dateTo);
        }
        
        return matches;
      }).toList();

      final brokerSalesMap = <String, double>{};
      
      for (final load in brokerLoads) {
        if (load.bids.isNotEmpty) {
          final winningBid = load.bids.reduce((a, b) => a.amount > b.amount ? a : b);
          brokerSalesMap[load.postedBy] = (brokerSalesMap[load.postedBy] ?? 0.0) + winningBid.amount;
        }
      }

      _brokerSales = brokerSalesMap.entries.map((entry) {
        return {
          'brokerId': entry.key,
          'totalSales': entry.value,
        };
      }).toList();
      
      notifyListeners();
    } catch (e) {
      _searchError = 'Error loading broker sales: ${e.toString()}';
      notifyListeners();
    }
  }

  // Calculate carrier sales from local data
  Future<void> loadCarrierSales({
    String? carrierId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final carrierLoads = _allLoads.where((load) {
        bool matches = load.status == 'completed';
        
        if (carrierId != null) {
          matches = matches && load.bids.any((bid) => bid.bidder == carrierId);
        }
        
        if (dateFrom != null) {
          matches = matches && load.createdAt.isAfter(dateFrom);
        }
        
        if (dateTo != null) {
          matches = matches && load.createdAt.isBefore(dateTo);
        }
        
        return matches;
      }).toList();

      final carrierSalesMap = <String, double>{};
      
      for (final load in carrierLoads) {
        if (load.bids.isNotEmpty) {
          final winningBid = load.bids.reduce((a, b) => a.amount > b.amount ? a : b);
          carrierSalesMap[winningBid.bidder] = (carrierSalesMap[winningBid.bidder] ?? 0.0) + winningBid.amount;
        }
      }

      _carrierSales = carrierSalesMap.entries.map((entry) {
        return {
          'carrierId': entry.key,
          'totalSales': entry.value,
        };
      }).toList();
      
      notifyListeners();
    } catch (e) {
      _searchError = 'Error loading carrier sales: ${e.toString()}';
      notifyListeners();
    }
  }

  // Load more search results (local only)
  Future<void> loadMoreSearchResults({
    String? dotNumber,
    String? mcNumber,
    String? companyName,
    String? location,
  }) async {
    // No pagination needed for local data
    await searchUsers(
      dotNumber: dotNumber,
      mcNumber: mcNumber,
      companyName: companyName,
      location: location,
    );
  }
}
