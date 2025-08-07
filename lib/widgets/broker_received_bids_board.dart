import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/load_post.dart';
import '../providers/load_provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';

class BrokerReceivedBidsBoard extends StatefulWidget {
  const BrokerReceivedBidsBoard({super.key});

  @override
  State<BrokerReceivedBidsBoard> createState() => _BrokerReceivedBidsBoardState();
}

class _BrokerReceivedBidsBoardState extends State<BrokerReceivedBidsBoard> {
  final NotificationService _notificationService = NotificationService();

  Future<void> _respondToBid(LoadPost load, LoadPostQuote bid, String action) async {
    final loadProvider = Provider.of<LoadProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;
    
    if (currentUser == null) return;

    if (action == 'reject') {
      await loadProvider.updateBidStatus(load.id, bid.bidder, 'rejected');
      
      // Send rejection notification to carrier
      _notificationService.notifyBidRejected(
        loadId: load.id,
        carrierId: bid.bidder,
        brokerName: currentUser.name.isNotEmpty ? currentUser.name : 'Broker',
        bidAmount: bid.amount,
        loadOrigin: load.originParts.isNotEmpty ? load.originParts[0] : load.origin,
        loadDestination: load.destinationParts.isNotEmpty ? load.destinationParts[0] : load.destination,
      );
      
    } else if (action == 'accept') {
      await loadProvider.updateBidStatus(load.id, bid.bidder, 'accepted');
      
      // Send approval notification to carrier
      _notificationService.notifyBidApproved(
        loadId: load.id,
        carrierId: bid.bidder,
        brokerName: currentUser.name.isNotEmpty ? currentUser.name : 'Broker',
        bidAmount: bid.amount,
        loadOrigin: load.originParts.isNotEmpty ? load.originParts[0] : load.origin,
        loadDestination: load.destinationParts.isNotEmpty ? load.destinationParts[0] : load.destination,
      );

      // Send carrier confirmation request notification
      _notificationService.notifyCarrierConfirmationRequest(
        loadId: load.id,
        carrierId: bid.bidder,
        brokerName: currentUser.name.isNotEmpty ? currentUser.name : 'Broker',
        bidAmount: bid.amount,
        loadOrigin: load.originParts.isNotEmpty ? load.originParts[0] : load.origin,
        loadDestination: load.destinationParts.isNotEmpty ? load.destinationParts[0] : load.destination,
      );
      
      // Send confirmation notification to broker
      _notificationService.notifyBrokerApprovalConfirmation(
        loadId: load.id,
        brokerId: currentUser.id,
        carrierName: bid.bidder, // In a real app, you'd get the carrier's name
        bidAmount: bid.amount,
        loadOrigin: load.originParts.isNotEmpty ? load.originParts[0] : load.origin,
        loadDestination: load.destinationParts.isNotEmpty ? load.destinationParts[0] : load.destination,
      );
      
      // Show immediate confirmation dialog to broker
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Bid Approved!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You have successfully approved the bid for Load #${load.id}'),
                const SizedBox(height: 8),
                Text('Carrier: ${bid.bidder}'),
                Text('Bid Amount: \$${bid.amount.toStringAsFixed(2)}'),
                Text('Route: ${load.originParts.isNotEmpty ? load.originParts[0] : load.origin} → ${load.destinationParts.isNotEmpty ? load.destinationParts[0] : load.destination}'),
                const SizedBox(height: 12),
                const Text(
                  'The carrier has been notified of the approval.',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
    } else if (action == 'raise') {
      final controller = TextEditingController(text: bid.counterBidAmount != null ? bid.counterBidAmount.toString() : (bid.amount + 10).toString());
      final newAmount = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Counter Bid for Load #${load.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Original Bid: \$${bid.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Counter Bid Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Submit Counter')),
          ],
        ),
      );
      if (newAmount != null && newAmount.isNotEmpty) {
        final amount = double.tryParse(newAmount);
        if (amount != null) {
          await loadProvider.updateBidStatus(load.id, bid.bidder, 'countered', counterBidAmount: amount);
          
          // Send counter bid notification to carrier
          _notificationService.notifyBidCountered(
            loadId: load.id,
            carrierId: bid.bidder,
            brokerName: currentUser.name.isNotEmpty ? currentUser.name : 'Broker',
            originalBidAmount: bid.amount,
            counterBidAmount: amount,
            loadOrigin: load.originParts.isNotEmpty ? load.originParts[0] : load.origin,
            loadDestination: load.destinationParts.isNotEmpty ? load.destinationParts[0] : load.destination,
          );
        }
      }
    }
    await loadProvider.fetchLoads();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loadProvider = Provider.of<LoadProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null || !user.isBroker) {
      return const Center(child: Text('Only brokers can view received bids.'));
    }

    final brokerLoads = loadProvider.brokerPosts.where((load) => load.postedBy == user.id && load.bids.isNotEmpty).toList();

    if (brokerLoads.isEmpty) {
      return const Center(child: Text('No bids received yet.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 8,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 40,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(label: Text('Load ID')),
                  DataColumn(label: Text('Origin')),
                  DataColumn(label: Text('Destination')),
                  DataColumn(label: Text('Rate')),
                  DataColumn(label: Text('Equipment')),
                  DataColumn(label: Text('Bidder')),
                  DataColumn(label: Text('Bid Amount')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Counter Bid')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: brokerLoads.expand((load) {
                  return load.bids.map((bid) {
                    return DataRow(
                      cells: [
                        DataCell(Text(load.id, style: TextStyle(fontSize: 12))),
                        DataCell(Text(load.origin, style: TextStyle(fontSize: 12))),
                        DataCell(Text(load.destination, style: TextStyle(fontSize: 12))),
                        DataCell(Text('\$${load.rate}', style: TextStyle(fontSize: 12))),
                        DataCell(Text(load.equipment.join(', '), style: TextStyle(fontSize: 12))),
                        DataCell(Text(bid.bidder, style: TextStyle(fontSize: 12))),
                        DataCell(Text('\$${bid.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 12))),
                        DataCell(Text(bid.bidStatus, style: TextStyle(fontSize: 12))),
                        DataCell(Text(bid.counterBidAmount != null ? '\$${bid.counterBidAmount!.toStringAsFixed(2)}' : '-', style: TextStyle(fontSize: 12))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (bid.bidStatus == 'pending' || bid.bidStatus == 'countered') ...[
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green, size: 18),
                                  tooltip: 'Accept',
                                  onPressed: () => _respondToBid(load, bid, 'accept'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                  tooltip: 'Reject',
                                  onPressed: () => _respondToBid(load, bid, 'reject'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_upward, color: Colors.orange, size: 18),
                                  tooltip: 'Counter',
                                  onPressed: () => _respondToBid(load, bid, 'raise'),
                                ),
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
          ),
        );
      },
    );
  }
}
