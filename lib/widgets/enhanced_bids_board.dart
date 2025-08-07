import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/load_post.dart';
import '../providers/load_provider.dart';
import '../providers/auth_provider.dart';
import '../core/config/app_routes.dart';

class EnhancedBidsBoard extends StatefulWidget {
  const EnhancedBidsBoard({super.key});

  @override
  State<EnhancedBidsBoard> createState() => _EnhancedBidsBoardState();
}

class _EnhancedBidsBoardState extends State<EnhancedBidsBoard> {
  String _searchQuery = '';
  String? _statusFilter;
  String? _equipmentFilter;
  String? _loadTypeFilter;
  String? _originFilter;
  String? _destinationFilter;
  String _sortBy = 'id';
  bool _sortAscending = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search your bids',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Status', _statusFilter, (value) => setState(() => _statusFilter = value)),
                  _buildFilterChip('Equipment', _equipmentFilter, (value) => setState(() => _equipmentFilter = value)),
                  _buildFilterChip('Load Type', _loadTypeFilter, (value) => setState(() => _loadTypeFilter = value)),
                  _buildFilterChip('Origin', _originFilter, (value) => setState(() => _originFilter = value)),
                  _buildFilterChip('Destination', _destinationFilter, (value) => setState(() => _destinationFilter = value)),
                  _buildFilterChip('Search', _searchQuery, (value) => setState(() => _searchQuery = value ?? '')),
                  _buildFilterChip('Sort By', _sortBy, (value) => setState(() => _sortBy = value ?? 'id')),
                  
                  // Clear All Filters
                  if (_hasActiveFilters())
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        label: const Text('Clear All'),
                        onPressed: _clearAllFilters,
                        backgroundColor: Colors.red.shade100,
                      ),
                    ),
                ],
              ),
            ),
            
            // Sort Options
            Row(
              children: [
                const Text('Sort by: '),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'id', child: Text('ID')),
                    DropdownMenuItem(value: 'origin', child: Text('Origin')),
                    DropdownMenuItem(value: 'destination', child: Text('Destination')),
                    DropdownMenuItem(value: 'pickupDate', child: Text('Pickup Date')),
                    DropdownMenuItem(value: 'bidAmount', child: Text('Bid Amount')),
                    DropdownMenuItem(value: 'status', child: Text('Status')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value ?? 'id'),
                ),
                IconButton(
                  icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () => setState(() => _sortAscending = !_sortAscending),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? currentValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(currentValue != null ? '$label: $currentValue' : label),
        selected: currentValue != null,
        onSelected: (selected) {
          if (selected) {
            _showFilterDialog(label, currentValue, onChanged);
          } else {
            onChanged(null);
          }
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    return _statusFilter != null || 
           _equipmentFilter != null || 
           _loadTypeFilter != null || 
           _originFilter != null || 
           _destinationFilter != null;
  }

  void _clearAllFilters() {
    setState(() {
      _statusFilter = null;
      _equipmentFilter = null;
      _loadTypeFilter = null;
      _originFilter = null;
      _destinationFilter = null;
    });
  }

  void _showFilterDialog(String title, String? currentValue, Function(String?) onChanged) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter by $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Enter $title',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onChanged(null);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              onChanged(value.isEmpty ? null : value);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bidData) {
    final LoadPost load = bidData['post'];
    final LoadPostQuote userBid = bidData['userBid'];
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Load #${load.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${load.originParts[0]}, ${load.originParts[1]} → ${load.destinationParts[0]}, ${load.destinationParts[1]}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Your Bid: \$${userBid.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                ),
                Text(
                  'Load Rate: ${load.formattedRate}',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _buildInfoChip(Icons.calendar_today, load.formattedPickupDate),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.local_shipping, load.equipmentString.isEmpty ? 'Any' : load.equipmentString),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.info, load.status),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Load Details
                _buildLoadDetails(load),
                const SizedBox(height: 16),
                
                // Bid Information
                _buildBidDetails(load, userBid),
                const SizedBox(height: 16),
                
                // Action Buttons
                _buildActionButtons(load),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadDetails(LoadPost load) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Load Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem('Origin', load.origin),
            ),
            Expanded(
              child: _buildDetailItem('Destination', load.destination),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem('Pickup Date', load.formattedPickupDate),
            ),
            Expanded(
              child: _buildDetailItem('Delivery Date', load.formattedDeliveryDate),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem('Distance', load.distance ?? 'Calculating...'),
            ),
            Expanded(
              child: _buildDetailItem('Load Type', load.loadType ?? 'N/A'),
            ),
          ],
        ),
        if (load.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailItem('Description', load.description),
        ],
      ],
    );
  }

  Widget _buildBidDetails(LoadPost load, LoadPostQuote userBid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bid Information',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem('Your Bid', '\$${userBid.amount.toStringAsFixed(2)}'),
            ),
            Expanded(
              child: _buildDetailItem('Load Rate', load.formattedRate),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem('Total Bids', '${load.bids.length}'),
            ),
            Expanded(
              child: _buildDetailItem('Bid Status', _getBidStatus(load, userBid)),
            ),
          ],
        ),
      ],
    );
  }

  String _getBidStatus(LoadPost load, LoadPostQuote userBid) {
    if (load.status == 'closed' || load.status == 'awarded') {
      return 'Load Closed';
    }
    
    final sortedBids = List<LoadPostQuote>.from(load.bids)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    
    if (sortedBids.isNotEmpty && sortedBids.first.bidder == userBid.bidder) {
      return 'Highest Bid';
    }
    
    return 'Active';
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButtons(LoadPost load) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.loadDetails,
              arguments: load,
            );
          },
          icon: const Icon(Icons.info_outline),
          label: const Text('Details'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _updateBid(load),
          icon: const Icon(Icons.edit),
          label: const Text('Update Bid'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _withdrawBid(load),
          icon: const Icon(Icons.remove_circle_outline),
          label: const Text('Withdraw'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _updateBid(LoadPost load) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final currentBid = load.bids.firstWhere(
      (bid) => bid.bidder == user.id,
      orElse: () => LoadPostQuote(bidder: user.id, amount: 0),
    );

    final controller = TextEditingController(text: currentBid.amount.toString());
    
    final newBidAmount = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Bid for Load #${load.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Bid: \$${currentBid.amount.toStringAsFixed(2)}'),
            Text('Load Rate: ${load.formattedRate}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Bid Amount (\$)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Update Bid'),
          ),
        ],
      ),
    );

    if (newBidAmount != null && newBidAmount.isNotEmpty && mounted) {
      final loadProvider = Provider.of<LoadProvider>(context, listen: false);
      await loadProvider.addBid(
        load.id,
        LoadPostQuote(
          amount: double.tryParse(newBidAmount) ?? 0,
          bidder: user.id,
        ),
      );
      if (!mounted) return;
      await loadProvider.fetchLoads();
      setState(() {});
    }
  }

  Future<void> _withdrawBid(LoadPost load) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Bid'),
        content: Text('Are you sure you want to withdraw your bid for Load #${load.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Implement bid withdrawal logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid withdrawal functionality to be implemented')),
      );
    }
  }

  List<Map<String, dynamic>> _filterAndSortBids(List<Map<String, dynamic>> bids) {
    var filtered = bids.where((bidData) {
      final LoadPost load = bidData['post'];
      return load.matchesSearch(_searchQuery) &&
             load.matchesFilters(
               statusFilter: _statusFilter,
               equipmentFilter: _equipmentFilter,
               loadTypeFilter: _loadTypeFilter,
               originFilter: _originFilter,
               destinationFilter: _destinationFilter,
             );
    }).toList();

    // Sort the filtered results
    filtered.sort((a, b) {
      final LoadPost loadA = a['post'];
      final LoadPost loadB = b['post'];
      final LoadPostQuote bidA = a['userBid'];
      final LoadPostQuote bidB = b['userBid'];

      int comparison = 0;
      
      switch (_sortBy) {
        case 'id':
          comparison = loadA.id.compareTo(loadB.id);
          break;
        case 'origin':
          comparison = loadA.origin.compareTo(loadB.origin);
          break;
        case 'destination':
          comparison = loadA.destination.compareTo(loadB.destination);
          break;
        case 'pickupDate':
          comparison = loadA.pickupDate.compareTo(loadB.pickupDate);
          break;
        case 'deliveryDate':
          comparison = loadA.deliveryDate.compareTo(loadB.deliveryDate);
          break;
        case 'distance':
          comparison = loadA.distance!.compareTo(loadB.distance!);
          break;
        case 'loadType':
          comparison = loadA.loadType!.compareTo(loadB.loadType!);
          break;
        case 'equipment':
          comparison = loadA.equipmentString.compareTo(loadB.equipmentString);
          break;
        case 'bidAmount':
          comparison = bidA.amount.compareTo(bidB.amount);
          break;
        case 'status':
          comparison = loadA.status.compareTo(loadB.status);
          break;
        default:
          comparison = loadA.id.compareTo(loadB.id);
      }
      
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final loadProvider = Provider.of<LoadProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: Text('Please log in to view your bids'));
    }

    // Filter loads where user has placed bids
    final userBids = loadProvider.loads.where((load) =>
      load.bids.any((bid) => bid.bidder == user.id)
    ).map((load) {
      final userBid = load.bids.firstWhere(
        (bid) => bid.bidder == user.id,
        orElse: () => LoadPostQuote(bidder: user.id, amount: 0),
      );
      return {'post': load, 'userBid': userBid};
    }).toList();

    final filteredAndSortedBids = _filterAndSortBids(userBids);

    return RefreshIndicator(
      onRefresh: () async {
        await loadProvider.fetchLoads();
        setState(() {});
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${filteredAndSortedBids.length} bids found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          if (filteredAndSortedBids.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No bids found matching your criteria',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildBidCard(filteredAndSortedBids[index]),
                childCount: filteredAndSortedBids.length,
              ),
            ),
        ],
      ),
    );
  }
}
