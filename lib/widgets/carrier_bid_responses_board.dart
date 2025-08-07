import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/load_post.dart';
import '../providers/load_provider.dart';
import '../providers/auth_provider.dart';

class CarrierBidResponsesBoard extends StatefulWidget {
  const CarrierBidResponsesBoard({super.key});

  @override
  State<CarrierBidResponsesBoard> createState() => _CarrierBidResponsesBoardState();
}

class _CarrierBidResponsesBoardState extends State<CarrierBidResponsesBoard> {
  Future<void> _respondToBrokerBid(LoadPost load, LoadPostQuote bid, String action) async {
    final loadProvider = Provider.of<LoadProvider>(context, listen: false);
    if (action == 'accept') {
      await loadProvider.updateBidStatus(load.id, bid.bidder, 'accepted');
    } else if (action == 'reject') {
      await loadProvider.updateBidStatus(load.id, bid.bidder, 'rejected');
    }
    await loadProvider.fetchLoads();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmLoad(LoadPost load) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Load'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to confirm this load?'),
            const SizedBox(height: 16),
            Text('Load ID: ${load.id}'),
            Text('Route: ${load.origin} → ${load.destination}'),
            Text('Rate: \$${load.rate}'),
            const SizedBox(height: 16),
            const Text(
              'By confirming, you agree to transport this load according to the specified terms.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Load'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final loadProvider = Provider.of<LoadProvider>(context, listen: false);
      try {
        await loadProvider.confirmLoad(load.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Load ${load.id} confirmed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error confirming load: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _declineLoad(LoadPost load) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Decline Load'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to decline this load?'),
            const SizedBox(height: 16),
            Text('Load ID: ${load.id}'),
            Text('Route: ${load.origin} → ${load.destination}'),
            Text('Rate: \$${load.rate}'),
            const SizedBox(height: 16),
            const Text(
              'The broker will be notified and can choose another carrier.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline Load'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final loadProvider = Provider.of<LoadProvider>(context, listen: false);
      try {
        await loadProvider.declineLoad(load.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Load ${load.id} declined.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error declining load: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleBid(LoadPost load) async {
    final controller = TextEditingController();

    final bidAmount = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Place Bid for Load #${load.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Rate: \$${load.rate}'),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(dialogContext, controller.text);
                }
              },
              child: const Text('Submit Bid'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (bidAmount != null && bidAmount.isNotEmpty && mounted) {
      final loadProvider = Provider.of<LoadProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user == null) return;
      await loadProvider.addBid(
        load.id,
        LoadPostQuote(
          amount: double.tryParse(bidAmount) ?? 0,
          bidder: user.id,
        ),
      );
      await loadProvider.fetchLoads();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadProvider = Provider.of<LoadProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: Text('Please log in to view your bids.'));
    }

    return FutureBuilder<List<LoadPost>>(
      future: loadProvider.getCarrierBidsWithBrokerResponses(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final loads = snapshot.data ?? [];

        if (loads.isEmpty) {
          return const Center(child: Text('You have not placed any bids yet.'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Load ID')),
                DataColumn(label: Text('Origin')),
                DataColumn(label: Text('Destination')),
                DataColumn(label: Text('Rate')),
                DataColumn(label: Text('Equipment')),
                DataColumn(label: Text('Bid Amount')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Counter Bid')),
                DataColumn(label: Text('Actions')),
              ],
              rows: loads.expand((load) {
                return load.bids.where((bid) => bid.bidder == user.id).map((bid) {
                  return DataRow(
                    cells: [
                      DataCell(Text(load.id)),
                      DataCell(Text(load.origin)),
                      DataCell(Text(load.destination)),
                      DataCell(Text('\$${load.rate}')),
                      DataCell(Text(load.equipment.join(', '))),
                      DataCell(Text('\$${bid.amount.toStringAsFixed(2)}')),
                      DataCell(Text(bid.bidStatus)), // This shows broker's response status to the carrier's bid
                      DataCell(Text(bid.counterBidAmount != null ? '\$${bid.counterBidAmount!.toStringAsFixed(2)}' : '-')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Show confirmation buttons if load is awaiting carrier confirmation
                            if (load.status == 'awaiting_carrier_confirmation' && 
                                load.selectedBidId == user.id && 
                                bid.bidStatus == 'accepted') ...[
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                tooltip: 'Confirm Load',
                                onPressed: () => _confirmLoad(load),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                tooltip: 'Decline Load',
                                onPressed: () => _declineLoad(load),
                              ),
                            ] else ...[
                              IconButton(
                                icon: const Icon(Icons.gavel, color: Colors.blue, size: 20),
                                tooltip: 'Place New Bid',
                                onPressed: () => _handleBid(load),
                              ),
                              if (bid.bidStatus == 'pending' || bid.bidStatus == 'countered') ...[
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                  tooltip: 'Reject',
                                  onPressed: () => _respondToBrokerBid(load, bid, 'reject'),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                });
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
