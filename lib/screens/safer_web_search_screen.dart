import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/safer_web_provider.dart';
import '../widgets/safer_web_info_card.dart';
import 'safer_web_details_screen.dart';

class SaferWebSearchScreen extends StatefulWidget {
  const SaferWebSearchScreen({super.key});

  @override
  State<SaferWebSearchScreen> createState() => _SaferWebSearchScreenState();
}

class _SaferWebSearchScreenState extends State<SaferWebSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _searchHistory = [];
  final List<String> _currentResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final provider = Provider.of<SaferWebProvider>(context, listen: false);
    
    if (!provider.isValidIdentifier(query)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid identifier format. Use USDOT numbers or MC/MX/FF numbers.'),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final snapshot = await provider.fetchSnapshot(query);
      
      setState(() {
        if (snapshot != null) {
          if (!_searchHistory.contains(query)) {
            _searchHistory.insert(0, query);
            if (_searchHistory.length > 10) {
              _searchHistory.removeLast();
            }
          }
          if (!_currentResults.contains(query)) {
            _currentResults.insert(0, query);
          }
        }
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildSearchBar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Carrier/Broker Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Enter USDOT, MC, MX, or FF number',
                      hintText: 'e.g., 123456 or MC123456',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSearching ? null : _performSearch,
                  child: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Supported formats:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFormatChip('USDOT: 123456'),
                _buildFormatChip('MC: MC123456'),
                _buildFormatChip('MX: MX123456'),
                _buildFormatChip('FF: FF123456'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatChip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.blue.shade50,
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _searchHistory.map((identifier) {
                final provider = Provider.of<SaferWebProvider>(context);
                final type = provider.getIdentifierType(identifier);
                return ActionChip(
                  label: Text('$identifier ($type)'),
                  onPressed: () {
                    _searchController.text = identifier;
                    _performSearch();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_currentResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Search for USDOT, MC, MX, or FF numbers to view carrier and broker information',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _currentResults.length,
      itemBuilder: (context, index) {
        final identifier = _currentResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SaferWebDetailsScreen(
                  identifier: identifier,
                  title: 'Details - $identifier',
                ),
              ),
            );
          },
          child: SaferWebInfoCard(
            identifier: identifier,
            onRefresh: () {
              // Refresh the specific item
              final provider = Provider.of<SaferWebProvider>(context, listen: false);
              provider.clearCache(identifier);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SaferWeb Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Search'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You can search using:'),
                      SizedBox(height: 8),
                      Text('• USDOT numbers (numeric only): 123456'),
                      Text('• MC numbers: MC123456'),
                      Text('• MX numbers: MX123456'),
                      Text('• FF numbers: FF123456'),
                      SizedBox(height: 16),
                      Text('The system will automatically detect the type and fetch the appropriate data.'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildSearchHistory(),
            const SizedBox(height: 16),
            _buildResults(),
          ],
        ),
      ),
    );
  }
}
