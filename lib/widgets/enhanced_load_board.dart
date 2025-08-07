import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/load_post.dart';
import '../providers/load_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/safer_web_provider.dart';
import '../core/config/app_routes.dart';
import '../models/user.dart';
import '../widgets/load_details_popup.dart';
import '../widgets/safer_web_info_card.dart';
import 'chat_tile.dart';

class EnhancedLoadBoard extends StatefulWidget {
  final bool showPostedLoads;
  final List<LoadPost>? loads;
  final bool isAvailableLoadsScreen; // New flag to indicate available loads screen
  
  const EnhancedLoadBoard({
    super.key,
    this.showPostedLoads = true,
    this.loads,
    this.isAvailableLoadsScreen = false,
  });

  @override
  State<EnhancedLoadBoard> createState() => EnhancedLoadBoardState();
}

class EnhancedLoadBoardState extends State<EnhancedLoadBoard> {
  EnhancedLoadBoardState();

  int? _sortColumnIndex;
  bool _sortAscending = true;
  
  final ScrollController _scrollController = ScrollController();
  bool _isDisposed = false;

  final String originFilter = '';
  final String destinationFilter = '';

  // State for chat tile
  String? chatUserId;
  String? chatUserName;

  void _sort<T>(Comparable<T> Function(LoadPost d) getField, int columnIndex, bool ascending) {
    if (!mounted || _isDisposed) return;
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void openChatTile(String userId, String userName) {
    if (!mounted || _isDisposed) return;
    setState(() {
      chatUserId = userId;
      chatUserName = userName;
    });
  }

  void closeChatTile() {
    if (!mounted || _isDisposed) return;
    setState(() {
      chatUserId = null;
      chatUserName = null;
    });
  }

  void _confirmDeleteLoad(LoadPost load) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete Load #${load.id}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              navigator.pop();
              if (_isDisposed || !mounted) return;
              
              try {
                final loadProvider = Provider.of<LoadProvider>(context, listen: false);
                await loadProvider.deleteLoad(load.id);
                if (mounted && !_isDisposed) {
                  setState(() {});
                }
              } catch (e) {
                // Handle error silently if widget is disposed
                if (mounted && !_isDisposed) {
                  // Show error message if widget is still mounted
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error deleting load: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  String _searchQuery = '';
  String? _statusFilter;
  String? _equipmentFilter;
  String? _loadTypeFilter;
  String? _originFilter;
  String? _destinationFilter;

  Widget buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search loads',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (!mounted || _isDisposed) return;
              setState(() => _searchQuery = value);
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (_statusFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text('Status: $_statusFilter'),
                      onSelected: (_) {
                        if (!mounted || _isDisposed) return;
                        setState(() => _statusFilter = null);
                      },
                      selected: true,
                    ),
                  ),
                if (_equipmentFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text('Equipment: $_equipmentFilter'),
                      onSelected: (_) {
                        if (!mounted || _isDisposed) return;
                        setState(() => _equipmentFilter = null);
                      },
                      selected: true,
                    ),
                  ),
                if (_loadTypeFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text('Load Type: $_loadTypeFilter'),
                      onSelected: (_) {
                        if (!mounted || _isDisposed) return;
                        setState(() => _loadTypeFilter = null);
                      },
                      selected: true,
                    ),
                  ),
                if (_originFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text('Origin: $_originFilter'),
                      onSelected: (_) {
                        if (!mounted || _isDisposed) return;
                        setState(() => _originFilter = null);
                      },
                      selected: true,
                    ),
                  ),
                if (_destinationFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text('Destination: $_destinationFilter'),
                      onSelected: (_) {
                        if (!mounted || _isDisposed) return;
                        setState(() => _destinationFilter = null);
                      },
                      selected: true,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoadCard(LoadPost load, LoadProvider loadProvider) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (widget.isAvailableLoadsScreen) {
      // For available loads screen: Show carrier load first, then matching broker loads below
      return LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Carrier Load Card
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.5,
                  minHeight: constraints.maxHeight * 0.3,
                ),
                child: Card(
                  margin: const EdgeInsets.all(6),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Carrier Load #${load.id}',
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
                              load.rate.isNotEmpty ? '\$${load.rate}' : 'N/A',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                            ),
                            Text(
                              '${load.matchingLoads?.length ?? 0} matches',
                              style: TextStyle(color: Colors.blue[600], fontSize: 12),
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
                            _buildLoadDetails(load),
                            const SizedBox(height: 16),
                            _buildActionButtons(load),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Matching Broker Loads Table
              if (load.matchingLoads?.isNotEmpty == true) ...[
                const Text(
                  'Matching Broker Loads',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (isMobile)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.4,
                      minHeight: constraints.maxHeight * 0.2,
                    ),
                    child: SingleChildScrollView(
                      child: _buildMatchingLoadsList(load.matchingLoads ?? [], loadProvider, load),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.4,
                      minHeight: constraints.maxHeight * 0.2,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _buildMatchingLoadsTable(load.matchingLoads ?? [], loadProvider, load),
                    ),
                  ),
              ] else
                const Text(
                  'No matching broker loads found',
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
      builder: (context) => AlertDialog(
        title: Text('Load #${load.id} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLoadDetails(load),
              const SizedBox(height: 16),
              Text(
                'Safety Rating:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Builder(
                builder: (context) {
                  final user = Provider.of<AuthProvider>(context, listen: false).user;
                  if (user == null || user.saferWebSnapshot == null) {
                    return const Text('N/A', style: TextStyle(fontSize: 14));
                  }
                  final snapshot = user.saferWebSnapshot!;
                  return Text(
                    'Status: ${snapshot.status}\n'
                    'Inspections: ${snapshot.inspectionSummary}\n'
                    'Crashes: ${snapshot.crashSummary}',
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(6),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
                    load.rate.isNotEmpty ? '\$${load.rate}' : 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                  ),
                  Text(
                    '${load.matchingLoads?.length ?? 0} matches',
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
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
                  _buildLoadDetails(load),
                  const SizedBox(height: 16),

                  _buildActionButtons(load),
                  const SizedBox(height: 16),

                  if (load.matchingLoads?.isNotEmpty == true) ...[
                    const Text(
                      'Matching Loads',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
              if (isMobile)
                _buildMatchingLoadsList(load.matchingLoads ?? [], loadProvider, load)
              else
                _buildMatchingLoadsTable(load.matchingLoads ?? [], loadProvider, load),
                  ] else
                    const Text(
                      'No matching loads found',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
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
              child: _buildDetailItem('Distance', load.pickupToDeliveryDistance ?? load.distance ?? 'Calculating...'),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
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
        ElevatedButton.icon(
          onPressed: () => _confirmDeleteLoad(load),
          icon: const Icon(Icons.delete),
          label: const Text('Delete Load'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _showEditLoadPreview(load),
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
        ElevatedButton.icon(
          onPressed: () => _createReturnLoadPosting(load),
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Return Load'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _createReturnLoadPosting(LoadPost load) async {
    if (_isDisposed || !mounted) return;
    
    // Store context reference before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final swappedLoad = load.copyWith(
        origin: load.destination,
        destination: load.origin,
        pickupLatitude: load.destinationLatitude,
        pickupLongitude: load.destinationLongitude,
        destinationLatitude: load.pickupLatitude,
        destinationLongitude: load.pickupLongitude,
        id: '', // New load, so clear id
        bids: [],
        matchingLoads: null,
        distance: null,
        destinationDifference: null,
      );
      
      final loadProvider = Provider.of<LoadProvider>(context, listen: false);
      await loadProvider.addLoad(swappedLoad);
      await loadProvider.fetchLoads();
      
      if (mounted && !_isDisposed) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Return load posted successfully')),
        );
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error creating return load: $e')),
        );
      }
    }
  }

  Widget _buildMatchingLoadsList(List<LoadPost> matches, LoadProvider loadProvider, LoadPost parentLoad) {
    return Column(
      children: matches.map((match) => Card(
        key: ValueKey(match.id),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          title: Text('Load #${match.id}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${match.origin} → ${match.destination}'),
              Text('Rate: ${match.rate.isNotEmpty ? '\$${match.rate}' : 'N/A'} | Date: ${match.formattedPickupDate}'),
              Text('Destination Difference: ${match.destinationDifference ?? 'Calculating...'}'),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(match.status),
              FutureBuilder<String?>(
                future: loadProvider.calculateDistanceBetweenPickups(parentLoad.origin, match.origin),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Calculating...',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.loadDetails,
              arguments: match,
            );
          },
        ),
      )).toList(),
    );
  }

  Widget _buildMatchingLoadsTable(List<LoadPost> matches, LoadProvider loadProvider, LoadPost parentLoad) {
    final sortedMatches = List<LoadPost>.from(matches);
    if (_sortColumnIndex != null) {
      sortedMatches.sort((a, b) {
        int comparison;
        switch (_sortColumnIndex) {
          case 0:
            comparison = a.id.compareTo(b.id);
            break;
          case 1:
            comparison = a.originParts[0].compareTo(b.originParts[0]);
            break;
          case 2:
            comparison = a.destinationParts[0].compareTo(b.destinationParts[0]);
            break;
          case 3:
            comparison = a.formattedPickupDate.compareTo(b.formattedPickupDate);
            break;
          case 4:
            comparison = a.formattedDeliveryDate.compareTo(b.formattedDeliveryDate);
            break;
          case 5:
            comparison = a.formattedRate.compareTo(b.formattedRate);
            break;
          case 6:
            comparison = (a.distance ?? '').compareTo(b.distance ?? '');
            break;
          case 7:
            comparison = (a.destinationDifference ?? '').compareTo(b.destinationDifference ?? '');
            break;
          case 8:
            comparison = (a.postedByName ?? '').compareTo(b.postedByName ?? '');
            break;
          default:
            comparison = 0;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 300,
        child: DataTable(
          columnSpacing: 1,
          horizontalMargin: 1,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 30,
                  child: const Text('Post ID', softWrap: true),
                ),
              ),
              onSort: (columnIndex, ascending) {
                _sort<String>((d) => d.id, columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 50,
                  child: const Text('Pickup', softWrap: true),
                ),
              ),
              onSort: (columnIndex, ascending) {
                _sort<String>((d) => d.originParts[0], columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 54,
                  child: const Text('Delivery', softWrap: true),
                ),
              ),
              onSort: (columnIndex, ascending) {
                _sort<String>((d) => d.destinationParts[0], columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 46,
                  child: const Text('Pickup Date', softWrap: true),
                ),
              ),
              onSort: (columnIndex, ascending) {
                _sort<String>((d) => d.formattedPickupDate, columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 48,
                  child: const Text('Delivery Date', softWrap: true),
                ),
              ),
              onSort: (columnIndex, ascending) {
                _sort<String>((d) => d.formattedDeliveryDate, columnIndex, ascending);
              },
            ),

            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 50,
                  child: const Text('Pickup Diff', softWrap: true),
                ),
              ),
              onSort: (columnIndex, ascending) {
                _sort<String>((d) => d.distance ?? '', columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 52,
                  child: const Text('Delivery Diff', softWrap: true),
                ),
              ),
              onSort: (columnIndex, ascending) {
                _sort<String>((d) => d.destinationDifference ?? '', columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 60,
                  child: const Text('Posted By', softWrap: true),
                ),
              ),
            ),
          DataColumn(
            label: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 100,
                child: const Text('Safer Web', softWrap: true),
              ),
            ),
          ),
          DataColumn(
            label: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 80,
                child: const Text('Actions', softWrap: true),
              ),
            ),
          ),
          ],
          rows: sortedMatches.map((match) {
            return DataRow(cells: [
              DataCell(Text(match.id)),
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 180),
                    child: Text(
                      '${match.originParts[0]}, ${match.originParts[1]}, ${match.originParts[2]}',
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 180),
                    child: Text(
                      '${match.destinationParts[0]}, ${match.destinationParts[1]}, ${match.destinationParts[2]}',
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
              DataCell(Text(match.formattedPickupDate)),
              DataCell(Text(match.formattedDeliveryDate)),
            // Removed Rate column cell as per user request
            // DataCell(Text(match.formattedRate)),
            DataCell(Text(match.distance ?? 'Calculating...')),
              DataCell(Text(match.destinationDifference ?? 'Calculating...')),
              DataCell(Text('${match.postedByName }(${match.postedBy})')),
              DataCell(
                FutureBuilder(
                  future: Provider.of<SaferWebProvider>(context, listen: false).fetchSnapshot(match.postedBy),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Icon(Icons.error, color: Colors.red);
                    }
                    return Icon(Icons.security, color: Colors.green);
                  },
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'View Details',
                      onPressed: () {
                        _showLoadDetailsWithSaferWeb(match);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.gavel),
                      tooltip: 'Place Bid',
                      onPressed: () => bidOnLoad(match),
                    ),
                    IconButton(
                      icon: const Icon(Icons.contact_phone),
                      tooltip: 'Contact',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final contactInfo = <Widget>[];
                            if (match.contactPerson != null && match.contactPerson!.isNotEmpty) {
                              contactInfo.add(Text('Contact Person: ${match.contactPerson}'));
                            }
                            if (match.contactPhone != null && match.contactPhone!.isNotEmpty) {
                              contactInfo.add(Text('Phone: ${match.contactPhone}'));
                            }
                            if (match.contactEmail != null && match.contactEmail!.isNotEmpty) {
                              contactInfo.add(Text('Email: ${match.contactEmail}'));
                            }
                            if (contactInfo.isEmpty) {
                              contactInfo.add(const Text('No contact information available.'));
                            }
                            return AlertDialog(
                              title: const Text('Contact Information'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: contactInfo,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat),
                      tooltip: 'Chat',
                      onPressed: () {
                        // Open chat tile with the user who posted the load
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          openChatTile(match.postedBy, match.postedByName ?? 'User');
                        });
                      },
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
  
  Future<void> bidOnLoad(LoadPost load) async {
    if (!mounted || _isDisposed) return;
    
    // Store context reference before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final bidAmount = await _showBidDialog(load);
      if (bidAmount != null && bidAmount.isNotEmpty && mounted && !_isDisposed) {
        final loadProvider = Provider.of<LoadProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        if (user == null || _isDisposed || !mounted) return;
        
        await loadProvider.addBid(
          load.id,
          LoadPostQuote(
            amount: double.tryParse(bidAmount) ?? 0,
            bidder: user.id,
          ),
        );
        
        if (!mounted || _isDisposed) return;
        await loadProvider.fetchLoads();
        
        if (mounted && !_isDisposed) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error placing bid: $e')),
        );
      }
    }
  }

  Future<String?> _showBidDialog(LoadPost load) async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Place Bid for Load #${load.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              Text('Current Rate: ${load.rate.isNotEmpty ? '\$${load.rate}' : 'N/A'}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your Bid (\$)',
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
            child: const Text('Submit Bid'),
          ),
        ],
      ),
    );
  }

  void _showEditLoadPreview(LoadPost load) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Load #${load.id}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Load Overview
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Load Overview',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        _buildPreviewRow('Load ID', load.id),
                        _buildPreviewRow('Status', load.status),
                        _buildPreviewRow('Load Type', load.loadType ?? 'Not specified'),
                        _buildPreviewRow('Rate', load.rate.isNotEmpty ? '\$${load.rate}' : 'Not specified'),
                        _buildPreviewRow('Weight', load.weight.isNotEmpty ? '${load.weight} lbs' : 'Not specified'),
                        _buildPreviewRow('Dimensions', load.dimensions.isNotEmpty ? load.dimensions : 'Not specified'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Origin Details
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Origin Details',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPreviewRow('Full Address', load.origin),
                        if (load.originCity?.isNotEmpty == true) _buildPreviewRow('City', load.originCity!),
                        if (load.originState?.isNotEmpty == true) _buildPreviewRow('State/Province', load.originState!),
                        if (load.originCountry?.isNotEmpty == true) _buildPreviewRow('Country', load.originCountry!),
                        if (load.originPostalCode?.isNotEmpty == true) _buildPreviewRow('Postal Code', load.originPostalCode!),
                        if (load.originDescription?.isNotEmpty == true) _buildPreviewRow('Notes', load.originDescription!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Destination Details
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flag, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Destination Details',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPreviewRow('Full Address', load.destination),
                        if (load.destinationCity?.isNotEmpty == true) _buildPreviewRow('City', load.destinationCity!),
                        if (load.destinationState?.isNotEmpty == true) _buildPreviewRow('State/Province', load.destinationState!),
                        if (load.destinationCountry?.isNotEmpty == true) _buildPreviewRow('Country', load.destinationCountry!),
                        if (load.destinationPostalCode?.isNotEmpty == true) _buildPreviewRow('Postal Code', load.destinationPostalCode!),
                        if (load.destinationDescription?.isNotEmpty == true) _buildPreviewRow('Notes', load.destinationDescription!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Schedule Details
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.schedule, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Schedule Details',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPreviewRow('Pickup Date', load.formattedPickupDate),
                        if (load.pickupTime?.isNotEmpty == true) _buildPreviewRow('Pickup Time', load.pickupTime!),
                        _buildPreviewRow('Delivery Date', load.formattedDeliveryDate),
                        if (load.deliveryTime?.isNotEmpty == true) _buildPreviewRow('Delivery Time', load.deliveryTime!),
                        _buildPreviewRow('Appointment Required', load.appointment == true ? 'Yes' : 'No'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Equipment & Requirements
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_shipping, color: Colors.purple, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Equipment & Requirements',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPreviewRow('Equipment', load.equipment.isNotEmpty ? load.equipment.join(', ') : 'Any'),
                        if (load.distance?.isNotEmpty == true) _buildPreviewRow('Distance', load.distance!),
                        if (load.pickupToDeliveryDistance?.isNotEmpty == true) _buildPreviewRow('Pickup to Delivery', load.pickupToDeliveryDistance!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Contact Information
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.contact_phone, color: Colors.teal, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Contact Information',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (load.contactEmail?.isNotEmpty == true) _buildPreviewRow('Email', load.contactEmail!),
                        if (load.contactPhone?.isNotEmpty == true) _buildPreviewRow('Phone', load.contactPhone!),
                        if (load.contactPerson?.isNotEmpty == true) _buildPreviewRow('Contact Person', load.contactPerson!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Additional Information
                if (load.description.isNotEmpty || load.bids.isNotEmpty)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info, color: Colors.indigo, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Additional Information',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (load.description.isNotEmpty) _buildPreviewRow('Description', load.description),
                          _buildPreviewRow('Number of Bids', '${load.bids.length}'),
                          _buildPreviewRow('Created', load.createdAt.toString().split('.')[0]),
                          _buildPreviewRow('Last Updated', load.updatedAt.toString().split('.')[0]),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                AppRoutes.postLoad,
                arguments: load,
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Proceed to Edit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadDetailsWithSaferWeb(LoadPost load) async {
    final _ = Provider.of<SaferWebProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Load #${load.id} Details'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Load Details Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_shipping, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Load Information',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildLoadDetails(load),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Safer Web Information Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.security, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Safer Web Information',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SaferWebInfoCard(
                          identifier: load.postedBy,
                          showFullDetails: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => LoadDetailsPopup(load: load),
              );
            },
            child: const Text('View Full Load Details'),
          ),
        ],
      ),
    );
  }

  Future<String?> fetchSaferWebInfo(String userId, SaferWebProvider saferWebProvider) async {
    try {
      // Try to fetch Safer Web information using the user ID as DOT/MC number
      // This assumes the user ID might be a DOT or MC number
      // You might need to adjust this logic based on how user IDs are structured
      await saferWebProvider.fetchSnapshot(userId);
      return userId;
    } catch (e) {
      // If direct fetch fails, you might want to look up the user's DOT/MC number
      // from the user database and then fetch Safer Web info
      debugPrint('Failed to fetch Safer Web info for user $userId: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadProvider = Provider.of<LoadProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view loads'));
    }

    // Use FutureBuilder to handle async fetching of user's own posts
    return FutureBuilder<List<LoadPost>>(
      future: _getUserOwnPosts(loadProvider, currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final ownPosts = widget.loads ?? snapshot.data ?? [];

        // Filter posts based on _searchQuery
        final filteredPosts = _searchQuery.isEmpty
            ? ownPosts
            : ownPosts.where((post) =>
                post.origin.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                post.destination.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                post.id.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                if (_isDisposed || !mounted) return;
                
                // Store context reference before async operations
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                try {
                  await loadProvider.fetchLoads();
                  if (mounted && !_isDisposed) {
                    setState(() {});
                  }
                } catch (e) {
                  // Handle refresh error silently if widget is disposed
                  if (mounted && !_isDisposed) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Error refreshing loads: $e')),
                    );
                  }
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: buildSearchAndFilters(),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.isAvailableLoadsScreen
                          ? (currentUser.isCarrier ? 'Carrier Postings' : 'Broker Postings')
                          : (currentUser.isBroker ? 'Broker Postings' : 'Carrier Postings'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (filteredPosts.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No posted loads found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start by posting your first load',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = filteredPosts[index];
                        final matches = loadProvider.findMatchingLoads(
                          post,
                          loadProvider.loads.where((p) => p.postedBy != currentUser.id && p.isBrokerPost != currentUser.isBroker).toList(),
                        );
                        return Card(
                          key: ValueKey(post.id),
                          margin: const EdgeInsets.all(6),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Load #${post.id}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        '${post.originParts[0]}, ${post.originParts[1]} → ${post.destinationParts[0]}, ${post.destinationParts[1]}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      post.rate.isNotEmpty ? '\$${post.rate}' : 'N/A',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                                    ),
                                    Text(
                                      '${matches.length} matches',
                                      style: TextStyle(color: Colors.blue[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  _buildInfoChip(Icons.calendar_today, post.formattedPickupDate),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(Icons.local_shipping, post.equipmentString.isEmpty ? 'Any' : post.equipmentString),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(Icons.info, post.status),
                                ],
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLoadDetails(post),
                                    const SizedBox(height: 16),
                                    _buildActionButtons(post),
                                    const SizedBox(height: 16),
                                    if (matches.isNotEmpty) ...[
                                      const Text(
                                        'Matching Loads',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildMatchingLoadsTable(matches, loadProvider, post),
                                    ] else
                                      const Text(
                                        'No matching loads found',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: filteredPosts.length,
                    ),
                  ),
                ],
              ),
            ),
            // Chat tile positioned on the right side
            if (chatUserId != null && chatUserName != null)
              Positioned(
                right: 16,
                top: 100,
                bottom: 16,
                child: SizedBox(
                  height: 400,
                  child: ChatTile(
                    userId: chatUserId!,
                    userName: chatUserName!,
                    onClose: closeChatTile,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<List<LoadPost>> _getUserOwnPosts(LoadProvider loadProvider, User user) {
    // getMyPostedLoads is synchronous and non-nullable, so no await or null check needed
    return Future.value(loadProvider.getMyPostedLoads(user));
  }

  Future<List<LoadPost>> getMatchingLoadsForUser(LoadProvider loadProvider, User user) {
    final ownPosts = loadProvider.getMyPostedLoads(user); // synchronous call
    final allPosts = loadProvider.loads; // Assuming this is non-nullable
    final List<LoadPost> matchingPosts = [];

    for (final post in ownPosts) {
      final matches = loadProvider.findMatchingLoads(
        post,
        allPosts.where((p) => p.postedBy != user.id).toList(),
      );
      matchingPosts.addAll(matches);
    }

    return Future.value(matchingPosts);
  }
}
