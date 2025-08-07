import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/load_post.dart';
import '../providers/load_provider.dart';
import '../providers/auth_provider.dart';

class LoadBoardWidget extends StatefulWidget {
  final bool isPostedLoads;
  final bool showMatchingLoads;

  const LoadBoardWidget({
    super.key,
    this.isPostedLoads = false,
    this.showMatchingLoads = false,
  });

  @override
  State<LoadBoardWidget> createState() => _LoadBoardWidgetState();
}

class _LoadBoardWidgetState extends State<LoadBoardWidget> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String _searchQuery = '';
  String? _statusFilter;
  String? _equipmentFilter;
  String? _loadTypeFilter;
  String? _originFilter;
  String? _destinationFilter;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final loadProvider = Provider.of<LoadProvider>(context, listen: false);
    loadProvider.fetchLoads();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (_statusFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text('Status: $_statusFilter'),
                onSelected: (_) => setState(() => _statusFilter = null),
                selected: true,
              ),
            ),
          if (_equipmentFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text('Equipment: $_equipmentFilter'),
                onSelected: (_) => setState(() => _equipmentFilter = null),
                selected: true,
              ),
            ),
          if (_loadTypeFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text('Load Type: $_loadTypeFilter'),
                onSelected: (_) => setState(() => _loadTypeFilter = null),
                selected: true,
              ),
            ),
          if (_originFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text('Origin: $_originFilter'),
                onSelected: (_) => setState(() => _originFilter = null),
                selected: true,
              ),
            ),
          if (_destinationFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text('Destination: $_destinationFilter'),
                onSelected: (_) => setState(() => _destinationFilter = null),
                selected: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search loads',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildColumnHeader(String title, {VoidCallback? onFilterPressed}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        if (onFilterPressed != null)
          IconButton(
            icon: const Icon(Icons.filter_list, size: 16),
            onPressed: onFilterPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  void _showFilterDialog(String title, String? currentValue, void Function(String?) onSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter by $title'),
        content: TextField(
          decoration: InputDecoration(
            labelText: 'Enter $title',
            border: const OutlineInputBorder(),
          ),
          controller: TextEditingController(text: currentValue),
          onSubmitted: (value) {
            onSelected(value.isEmpty ? null : value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSelected(null);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  List<LoadPost> _filterAndSortLoads(List<LoadPost> loads) {
    return loads.where((load) {
      return load.matchesSearch(_searchQuery) &&
             load.matchesFilters(
               statusFilter: _statusFilter,
               equipmentFilter: _equipmentFilter,
               loadTypeFilter: _loadTypeFilter,
               originFilter: _originFilter,
               destinationFilter: _destinationFilter,
             );
    }).toList();
  }

  Widget _buildLoadTable(List<LoadPost> loads, {bool showMatching = false}) {
    final filteredLoads = _filterAndSortLoads(loads);
    
    return PaginatedDataTable(
      header: Text(showMatching ? 'Matching Loads' : 'Posted Loads'),
      rowsPerPage: _rowsPerPage,
      onRowsPerPageChanged: (value) => setState(() => _rowsPerPage = value ?? 10),
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        DataColumn(
          label: _buildColumnHeader('ID'),
          onSort: (columnIndex, ascending) {
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
              filteredLoads.sort((a, b) => ascending
                  ? a.id.compareTo(b.id)
                  : b.id.compareTo(a.id));
            });
          },
        ),
        DataColumn(
          label: _buildColumnHeader(
            'Origin',
            onFilterPressed: () => _showFilterDialog(
              'Origin',
              _originFilter,
              (value) => setState(() => _originFilter = value),
            ),
          ),
        ),
        DataColumn(
          label: _buildColumnHeader(
            'Destination',
            onFilterPressed: () => _showFilterDialog(
              'Destination',
              _destinationFilter,
              (value) => setState(() => _destinationFilter = value),
            ),
          ),
        ),
        DataColumn(label: const Text('Pickup Date')),
        DataColumn(label: const Text('Delivery Date')),
        DataColumn(
          label: _buildColumnHeader(
            'Load Type',
            onFilterPressed: () => _showFilterDialog(
              'Load Type',
              _loadTypeFilter,
              (value) => setState(() => _loadTypeFilter = value),
            ),
          ),
        ),
        DataColumn(label: const Text('Distance')),
        if (!showMatching) DataColumn(label: const Text('Matching Loads')),
        if (showMatching) DataColumn(label: const Text('Destination Difference')),
        DataColumn(label: const Text('Rate')),
        DataColumn(
          label: _buildColumnHeader(
            'Equipment',
            onFilterPressed: () => _showFilterDialog(
              'Equipment',
              _equipmentFilter,
              (value) => setState(() => _equipmentFilter = value),
            ),
          ),
        ),
        DataColumn(
          label: _buildColumnHeader(
            'Status',
            onFilterPressed: () => _showFilterDialog(
              'Status',
              _statusFilter,
              (value) => setState(() => _statusFilter = value),
            ),
          ),
        ),
        DataColumn(
          label: _buildColumnHeader(
            'Equipment',
            onFilterPressed: () => _showFilterDialog(
              'Equipment',
              _equipmentFilter,
              (value) => setState(() => _equipmentFilter = value),
            ),
          ),
        ),
        const DataColumn(label: Text('Actions')),
      ],
      source: LoadBoardDataSource(
        context: context,
        loads: filteredLoads,
        showMatching: showMatching,
        onViewDetails: (load) {
          Navigator.pushNamed(
            context,
            '/load_details',
            arguments: load,
          );
        },
        onEdit: (load) {
          Navigator.pushNamed(
            context,
            '/post_load',
            arguments: load,
          );
        },
        onDelete: (load) {
          // Handle delete
        },
        onBid: (load) {
          // Handle bid
        },
      ),
    );
  }

  void createReturnLoadPosting(LoadPost load) {
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
    Navigator.pushNamed(context, '/post_load', arguments: swappedLoad);
  }

  @override
  Widget build(BuildContext context) {
    final loadProvider = Provider.of<LoadProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobileView = MediaQuery.of(context).size.width < 600;

    if (authProvider.user == null) {
      return const Center(child: Text('User not logged in.'));
    }

    if (widget.isPostedLoads) {
      return FutureBuilder<List<LoadPost>>(
        future: loadProvider.brokerPostsForUser(authProvider.user!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final loads = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: () async {
              await loadProvider.fetchLoads();
              setState(() {});
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildFilterChips(),
                  if (isMobileView)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: loads.length,
                      itemBuilder: (context, index) {
                        final load = loads[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ExpansionTile(
                            title: Text('Load #${load.id}'),
                            subtitle: Text('${load.origin} → ${load.destination}'),
                            children: [
                              ListTile(
                                title: Text('Pickup: ${load.formattedPickupDate}'),
                                subtitle: Text('Delivery: ${load.formattedDeliveryDate}'),
                              ),
                              ListTile(
                                title: Text('Rate: ${load.formattedRate}'),
                                subtitle: Text('Equipment: ${load.equipmentString}'),
                              ),
                              ListTile(
                                title: Text('Status: ${load.status}'),
                                subtitle: Text('Distance: ${load.distance ?? "Calculating..."}'),
                              ),
                              OverflowBar(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Handle view details
                                    },
                                    child: const Text('View Details'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle bid
                                    },
                                    child: const Text('Place Bid'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    _buildLoadTable(loads),
                ],
              ),
            ),
          );
        },
      );
    } else if (widget.showMatchingLoads) {
      return FutureBuilder<List<LoadPost>>(
        future: loadProvider.matchingCarrierPostsForUser(authProvider.user!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final loads = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: () async {
              await loadProvider.fetchLoads();
              setState(() {});
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildFilterChips(),
                  if (isMobileView)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: loads.length,
                      itemBuilder: (context, index) {
                        final load = loads[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ExpansionTile(
                            title: Text('Load #${load.id}'),
                            subtitle: Text('${load.origin} → ${load.destination}'),
                            children: [
                              ListTile(
                                title: Text('Pickup: ${load.formattedPickupDate}'),
                                subtitle: Text('Delivery: ${load.formattedDeliveryDate}'),
                              ),
                              ListTile(
                                title: Text('Rate: ${load.formattedRate}'),
                                subtitle: Text('Equipment: ${load.equipmentString}'),
                              ),
                              ListTile(
                                title: Text('Status: ${load.status}'),
                                subtitle: Text('Distance: ${load.distance ?? "Calculating..."}'),
                              ),
                              OverflowBar(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Handle view details
                                    },
                                    child: const Text('View Details'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle bid
                                    },
                                    child: const Text('Place Bid'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    _buildLoadTable(loads, showMatching: true),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return FutureBuilder<List<LoadPost>>(
        future: loadProvider.carrierPostsForUser(authProvider.user!, applyFilters: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final loads = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: () async {
              await loadProvider.fetchLoads();
              setState(() {});
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildFilterChips(),
                  if (isMobileView)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: loads.length,
                      itemBuilder: (context, index) {
                        final load = loads[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ExpansionTile(
                            title: Text('Load #${load.id}'),
                            subtitle: Text('${load.origin} → ${load.destination}'),
                            children: [
                              ListTile(
                                title: Text('Pickup: ${load.formattedPickupDate}'),
                                subtitle: Text('Delivery: ${load.formattedDeliveryDate}'),
                              ),
                              ListTile(
                                title: Text('Rate: ${load.formattedRate}'),
                                subtitle: Text('Equipment: ${load.equipmentString}'),
                              ),
                              ListTile(
                                title: Text('Status: ${load.status}'),
                                subtitle: Text('Distance: ${load.distance ?? "Calculating..."}'),
                              ),
                              OverflowBar(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Handle view details
                                    },
                                    child: const Text('View Details'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Handle bid
                                    },
                                    child: const Text('Place Bid'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    _buildLoadTable(loads),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

class LoadBoardDataSource extends DataTableSource {
  final BuildContext context;
  final List<LoadPost> loads;
  final bool showMatching;
  final Function(LoadPost) onViewDetails;
  final Function(LoadPost) onEdit;
  final Function(LoadPost) onDelete;
  final Function(LoadPost) onBid;

  LoadBoardDataSource({
    required this.context,
    required this.loads,
    this.showMatching = false,
    required this.onViewDetails,
    required this.onEdit,
    required this.onDelete,
    required this.onBid,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= loads.length) return null;
    final load = loads[index];

      return DataRow(
      cells: [
        DataCell(Text(load.id)),
        DataCell(Text(load.origin)),
        DataCell(Text(load.destination)),
        DataCell(Text(load.formattedPickupDate)),
        DataCell(Text(load.formattedDeliveryDate)),
        DataCell(Text(load.loadType ?? 'N/A')),
        DataCell(Text(load.pickupToDeliveryDistance ?? load.distance ?? 'Calculating...')),
        if (!showMatching)
          DataCell(Text('${load.matchingLoads?.length ?? 0} matches')),
        if (showMatching)
          DataCell(Text(load.destinationDifference ?? 'Calculating...')),
        DataCell(Text(load.formattedRate)),
        DataCell(Text(load.equipmentString)),
        DataCell(Text(load.status)),
        DataCell(Text(load.equipmentString)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'View Details',
              onPressed: () => onViewDetails(load),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Load',
              onPressed: () => onEdit(load),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Load',
              onPressed: () => onDelete(load),
            ),
            IconButton(
              icon: const Icon(Icons.gavel),
              tooltip: 'Place Bid',
              onPressed: () => onBid(load),
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => loads.length;

  @override
  int get selectedRowCount => 0;
}
