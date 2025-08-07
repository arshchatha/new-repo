import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/load_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/safer_web_provider.dart';
import '../models/load_post.dart';
import '../models/user.dart';
import '../widgets/safer_web_info_card.dart';

class AnalyticsRateInsightsScreen extends StatefulWidget {
  const AnalyticsRateInsightsScreen({super.key});

  @override
  State<AnalyticsRateInsightsScreen> createState() => _AnalyticsRateInsightsScreenState();
}

class _AnalyticsRateInsightsScreenState extends State<AnalyticsRateInsightsScreen> {
  List<LoadPost> _allLoads = [];
  final Map<String, double> _laneRates = {};
  final Map<String, int> _laneCounts = {};
  final Map<String, double> _brokerSales = {};
  final Map<String, double> _carrierSales = {};
  final Map<String, int> _frequentLoads = {};
  final Map<String, double> _frequentLoadRates = {};
  final Map<String, double> _frequentLoadPerMileRates = {};
  final Map<String, double> _frequentLoadTotalMiles = {};
  final Map<String, double> _frequentLoadSoldAmounts = {};
  double _averageRatePerMile = 0.0;
  double _totalRevenue = 0.0;
  int _totalLoadsSold = 0;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showAdvancedFilters = false;
  String _selectedSearchType = 'DOT/MC';

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    final loadProvider = Provider.of<LoadProvider>(context, listen: false);
    _allLoads = loadProvider.loads;

    _calculateAnalytics();
    _calculateFrequentLoads();
    
    if (mounted) {
      setState(() {});
    }
  }

  void _calculateAnalytics() {
    // Get confirmed loads (both broker and carrier confirmed)
    final confirmedLoads = _allLoads.where((load) => 
      load.brokerConfirmed && load.carrierConfirmed && 
      load.selectedBidId != null && load.bids.isNotEmpty
    ).toList();
    
    _totalLoadsSold = confirmedLoads.length;
    _totalRevenue = 0.0;
    double totalMiles = 0.0;
    _laneRates.clear();
    _laneCounts.clear();
    _brokerSales.clear();
    _carrierSales.clear();

    for (final load in confirmedLoads) {
      // Find the selected/confirmed bid
      final selectedBid = load.bids.firstWhere(
        (bid) => bid.bidder == load.selectedBidId || 
                 (load.selectedBidId == null && bid.bidStatus == 'accepted'),
        orElse: () => load.bids.where((bid) => bid.bidStatus == 'accepted').isNotEmpty 
          ? load.bids.where((bid) => bid.bidStatus == 'accepted').last
          : load.bids.last,
      );
      
      // Use the confirmed bid amount as the sold price
      final salePrice = selectedBid.amount;
      
      double distance = 0.0;
      if (load.distance != null) {
        final distanceStr = load.distance!.replaceAll(RegExp(r'[^0-9.]'), '');
        distance = double.tryParse(distanceStr) ?? 0.0;
      }
      
      _totalRevenue += salePrice;
      totalMiles += distance;

      final lane = '${load.origin} → ${load.destination}';
      _laneRates[lane] = (_laneRates[lane] ?? 0.0) + salePrice;
      _laneCounts[lane] = (_laneCounts[lane] ?? 0) + 1;

      final brokerId = load.postedBy;
      _brokerSales[brokerId] = (_brokerSales[brokerId] ?? 0.0) + salePrice;

      final carrierId = selectedBid.bidder;
      _carrierSales[carrierId] = (_carrierSales[carrierId] ?? 0.0) + salePrice;
    }

    _averageRatePerMile = totalMiles > 0 ? _totalRevenue / totalMiles : 0.0;

    _laneRates.forEach((lane, total) {
      final count = _laneCounts[lane] ?? 1;
      _laneRates[lane] = total / count;
    });
  }

  void _calculateFrequentLoads() {
    _frequentLoads.clear();
    _frequentLoadRates.clear();
    _frequentLoadPerMileRates.clear();
    _frequentLoadTotalMiles.clear();
    _frequentLoadSoldAmounts.clear();

    // Count frequency of each route and accumulate data
    for (final load in _allLoads) {
      final route = '${load.origin} → ${load.destination}';
      _frequentLoads[route] = (_frequentLoads[route] ?? 0) + 1;
      
      // Calculate rates for this route
      final rate = double.tryParse(load.rate) ?? 0.0;
      if (rate > 0) {
        _frequentLoadRates[route] = (_frequentLoadRates[route] ?? 0.0) + rate;
        
        // Calculate sold amounts from confirmed loads
        if (load.brokerConfirmed && load.carrierConfirmed && load.bids.isNotEmpty) {
          // Find the selected/confirmed bid
          final selectedBid = load.bids.firstWhere(
            (bid) => bid.bidder == load.selectedBidId || 
                     (load.selectedBidId == null && bid.bidStatus == 'accepted'),
            orElse: () => load.bids.where((bid) => bid.bidStatus == 'accepted').isNotEmpty 
              ? load.bids.where((bid) => bid.bidStatus == 'accepted').last
              : load.bids.last,
          );
          _frequentLoadSoldAmounts[route] = (_frequentLoadSoldAmounts[route] ?? 0.0) + selectedBid.amount;
        } else if (load.bids.isNotEmpty) {
          // Fallback to accepted bids for backward compatibility
          final acceptedBids = load.bids.where((bid) => bid.bidStatus == 'accepted').toList();
          if (acceptedBids.isNotEmpty) {
            final lastAcceptedBid = acceptedBids.last;
            _frequentLoadSoldAmounts[route] = (_frequentLoadSoldAmounts[route] ?? 0.0) + lastAcceptedBid.amount;
          }
        }
        
        // Calculate total miles and per-mile rate if distance is available
        if (load.distance != null) {
          final distanceStr = load.distance!.replaceAll(RegExp(r'[^0-9.]'), '');
          final distance = double.tryParse(distanceStr) ?? 0.0;
          if (distance > 0) {
            _frequentLoadTotalMiles[route] = (_frequentLoadTotalMiles[route] ?? 0.0) + distance;
            final perMileRate = rate / distance;
            _frequentLoadPerMileRates[route] = (_frequentLoadPerMileRates[route] ?? 0.0) + perMileRate;
          }
        }
      }
    }

    // Calculate averages for rates and per-mile rates
    _frequentLoadRates.forEach((route, totalRate) {
      final count = _frequentLoads[route] ?? 1;
      _frequentLoadRates[route] = totalRate / count;
    });

    _frequentLoadPerMileRates.forEach((route, totalPerMileRate) {
      final count = _frequentLoads[route] ?? 1;
      _frequentLoadPerMileRates[route] = totalPerMileRate / count;
    });
  }

  Future<void> _performSearch() async {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    final saferWebProvider = Provider.of<SaferWebProvider>(context, listen: false);
    final searchQuery = _searchController.text.trim();
    
    if (searchQuery.isEmpty && 
        _companyNameController.text.isEmpty && 
        _locationController.text.isEmpty) {
      analyticsProvider.clearSearch();
      return;
    }

    if (_selectedSearchType == 'DOT/MC') {
      await analyticsProvider.searchUsers(
        dotNumber: searchQuery.contains('-') ? null : searchQuery,
        mcNumber: searchQuery.contains('MC') ? searchQuery : null,
        companyName: _companyNameController.text.isNotEmpty ? _companyNameController.text : null,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        refresh: true,
      );
    }

    if (searchQuery.isNotEmpty && _selectedSearchType == 'DOT/MC') {
      try {
        await saferWebProvider.fetchSnapshot(searchQuery);
      } catch (e) {
        debugPrint('Safer Web search error: $e');
      }
    }
  }

  Future<void> _selectUser(User user) async {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
    await analyticsProvider.selectUser(user);
  }

  Widget _buildSearchSection() {
    return Consumer2<AnalyticsProvider, SaferWebProvider>(
      builder: (context, analyticsProvider, saferWebProvider, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Search Analytics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _showAdvancedFilters ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _showAdvancedFilters = !_showAdvancedFilters;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: _selectedSearchType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'DOT/MC', child: Text('DOT/MC Number')),
                    DropdownMenuItem(value: 'Company', child: Text('Company Name')),
                    DropdownMenuItem(value: 'Location', child: Text('Location')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSearchType = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: _selectedSearchType == 'DOT/MC' 
                            ? 'Enter USDOT or MC number'
                            : _selectedSearchType == 'Company'
                              ? 'Enter company name'
                              : 'Enter location',
                          border: const OutlineInputBorder(),
                          suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  analyticsProvider.clearSearch();
                                },
                              )
                            : null,
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: analyticsProvider.isSearching ? null : _performSearch,
                        child: analyticsProvider.isSearching 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Search', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
                
                if (analyticsProvider.searchError.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            analyticsProvider.searchError,
                            style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedUserAnalytics(AnalyticsProvider provider) {
    final user = provider.selectedUser!;
    final analytics = provider.userAnalytics;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: user.role == 'broker' 
                  ? Colors.blue.shade100 
                  : Colors.green.shade100,
                child: Icon(
                  user.role == 'broker' ? Icons.business : Icons.local_shipping,
                  color: user.role == 'broker' ? Colors.blue : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.companyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${user.role.toUpperCase()} • ${user.usDotMcNumber}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  value: (analytics['totalLoads']?.toString() ?? provider.userLoads.length.toString()),
                  label: 'Total Loads',
                  icon: Icons.local_shipping,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  value: '\$${((analytics['totalRevenue'] ?? 0.0) / 1000).toStringAsFixed(1)}K',
                  label: 'Total Revenue',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  value: '\$${((analytics['avgRate'] ?? 0.0).toStringAsFixed(2))}',
                  label: 'Avg Rate/Mile',
                  icon: Icons.speed,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsSection(AnalyticsProvider analyticsProvider, SaferWebProvider saferWebProvider) {
    return Column(
      children: [
        if (analyticsProvider.searchResults.isNotEmpty) ...[
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Search Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('${analyticsProvider.searchResults.length} found'),
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      itemCount: analyticsProvider.searchResults.length,
                      separatorBuilder: (context, index) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final user = analyticsProvider.searchResults[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: user.role == 'broker' 
                              ? Colors.blue.shade100 
                              : Colors.green.shade100,
                            child: Icon(
                              user.role == 'broker' ? Icons.business : Icons.local_shipping,
                              color: user.role == 'broker' ? Colors.blue : Colors.green,
                              size: 18,
                            ),
                          ),
                          title: Text(user.companyName),
                          subtitle: Text('${user.name} • ${user.usDotMcNumber}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () => _selectUser(user),
                          ),
                          onTap: () => _selectUser(user),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_searchController.text.isNotEmpty && saferWebProvider.getSnapshot(_searchController.text) != null) ...[
          SaferWebInfoCard(
            identifier: _searchController.text,
            displayMode: SaferWebDisplayMode.analytics,
            showComparisons: true,
            showFullDetails: true,
          ),
        ],
      ],
    );
  }



  Widget _buildAnalyticsOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(
              (Theme.of(context).colorScheme.primary.r * 255.0).round() & 0xff,
              (Theme.of(context).colorScheme.primary.g * 255.0).round() & 0xff,
              (Theme.of(context).colorScheme.primary.b * 255.0).round() & 0xff,
              0.1,
            ),
            Color.fromRGBO(
              (Theme.of(context).colorScheme.primary.r * 255.0).round() & 0xff,
              (Theme.of(context).colorScheme.primary.g * 255.0).round() & 0xff,
              (Theme.of(context).colorScheme.primary.b * 255.0).round() & 0xff,
              0.2,
            ),
          ],
          stops: const [
            0.1,
            0.9,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Color.fromRGBO(
            (Theme.of(context).colorScheme.primary.r * 255.0).round() & 0xff,
            (Theme.of(context).colorScheme.primary.g * 255.0).round() & 0xff,
            (Theme.of(context).colorScheme.primary.b * 255.0).round() & 0xff,
            0.2,
          ),
          width: 1.5,
          
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate Insights Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  value: _totalLoadsSold.toString(),
                  label: 'Total Loads',
                  icon: Icons.local_shipping,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  value: '\$${_averageRatePerMile.toStringAsFixed(2)}',
                  label: 'Avg Rate/Mile',
                  icon: Icons.speed,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  value: '\$${(_totalRevenue / 1000).toStringAsFixed(1)}K',
                  label: 'Total Revenue',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentLoadsSection() {
    if (_frequentLoads.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by frequency (most frequent first)
    final sortedEntries = _frequentLoads.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 10 most frequent routes
    final topRoutes = sortedEntries.take(10).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Most Frequently Posted Loads',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${topRoutes.length} routes'),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(1.2),
                    4: FlexColumnWidth(1.2),
                    5: FlexColumnWidth(1.3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Route',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Count',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Avg Rate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Rate/Mile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Total Miles',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Sold Amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    ...topRoutes.map((entry) {
                      final route = entry.key;
                      final count = entry.value;
                      final avgRate = _frequentLoadRates[route] ?? 0.0;
                      final perMileRate = _frequentLoadPerMileRates[route] ?? 0.0;
                      final totalMiles = _frequentLoadTotalMiles[route] ?? 0.0;
                      final soldAmount = _frequentLoadSoldAmounts[route] ?? 0.0;

                      return TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade100,
                              width: 1,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              route,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                count.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              avgRate > 0 ? '\$${avgRate.toStringAsFixed(0)}' : 'N/A',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: avgRate > 0 ? Colors.green.shade700 : Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              perMileRate > 0 ? '\$${perMileRate.toStringAsFixed(2)}' : 'N/A',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: perMileRate > 0 ? Colors.orange.shade700 : Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              totalMiles > 0 ? '${totalMiles.toStringAsFixed(0)}mi' : 'N/A',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: totalMiles > 0 ? Colors.purple.shade700 : Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              soldAmount > 0 ? '\$${(soldAmount / 1000).toStringAsFixed(1)}K' : 'N/A',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: soldAmount > 0 ? Colors.indigo.shade700 : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(String title, Map<String, dynamic> data, IconData icon, Color color) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (data.isNotEmpty)
                  Chip(
                    label: Text('${data.length} entries'),
                    backgroundColor: Colors.grey[200],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (data.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Count',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      ...entries.map((entry) {
                        return TableRow(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade100,
                                width: 1,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(entry.key),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                entry.value is double 
                                  ? '\$${entry.value.toStringAsFixed(2)}' 
                                  : '\$${entry.value}',
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                _laneCounts[entry.key]?.toString() ?? '-',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO((color.r * 255.0).round() & 0xff, (color.g * 255.0).round() & 0xff, (color.b * 255.0).round() & 0xff, 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color.fromRGBO((color.r * 255.0).round() & 0xff, (color.g * 255.0).round() & 0xff, (color.b * 255.0).round() & 0xff, 0.2),
                  border: Border.all(
                    color: Color.fromRGBO((color.r * 255.0).round() & 0xff, (color.g * 255.0).round() & 0xff, (color.b * 255.0).round() & 0xff, 0.3),
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer2<AnalyticsProvider, SaferWebProvider>(
          builder: (context, analyticsProvider, saferWebProvider, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate Analytics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSearchSection(),
                  const SizedBox(height: 16),
                  
                  if (analyticsProvider.selectedUser != null)
                    _buildSelectedUserAnalytics(analyticsProvider),
                  
                  _buildSearchResultsSection(analyticsProvider, saferWebProvider),
                  
                  _buildAnalyticsOverview(),
                  
                  _buildFrequentLoadsSection(),
                  
                  if (_laneRates.isNotEmpty)
                    _buildTableSection(
                      'Top Lanes by Rate',
                      _laneRates.map((k, v) => MapEntry(k, v)),
                      Icons.route,
                      Colors.blue,
                    ),
                  
                  if (_brokerSales.isNotEmpty)
                    _buildTableSection(
                      'Top Brokers by Revenue',
                      _brokerSales.map((k, v) => MapEntry(k, v)),
                      Icons.business,
                      Colors.green,
                    ),
                  
                  if (_carrierSales.isNotEmpty)
                    _buildTableSection(
                      'Top Carriers by Revenue',
                      _carrierSales.map((k, v) => MapEntry(k, v)),
                      Icons.local_shipping,
                      Colors.orange,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
