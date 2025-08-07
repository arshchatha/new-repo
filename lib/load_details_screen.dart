import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/load_post.dart';
import '../../core/config/app_routes.dart';
import '../../providers/load_provider.dart';

class LoadDetailsScreen extends StatefulWidget {
  const LoadDetailsScreen({super.key});

  @override
  State<LoadDetailsScreen> createState() => _LoadDetailsScreenState();
}

class _LoadDetailsScreenState extends State<LoadDetailsScreen> {
  String? _distanceKey;

  @override
  Widget build(BuildContext context) {
    final load = ModalRoute.of(context)!.settings.arguments as LoadPost;

    return Scaffold(
      appBar: AppBar(title: const Text('Load Details')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Text('Title: ${load.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('From: ${load.origin}'),
                      Text('To: ${load.destination}'),
                      const SizedBox(height: 8),
                      _buildDistanceWidget(load),
                      const SizedBox(height: 16),
                      Text('Posted By: ${load.postedBy}'),
                      Text('Type: ${load.isBrokerPost ? 'Broker Load' : 'Carrier Request'}'),
                      Text('Load Type: ${load.loadType ?? 'Not specified'}'),
                      Text('Pickup Date: ${load.pickupDate.isNotEmpty ? load.pickupDate.substring(0, 10) : 'Not specified'}'),
                      Text('Rate: \$${load.rate}'),
                      const SizedBox(height: 30),
                      const Text('Received Bids:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (load.bids.isEmpty)
                        const Text('No bids yet.')
                    else
                      ...load.bids.map((bid) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(bid.bidder),
                              subtitle: Text('\$${bid.amount.toStringAsFixed(2)}'),
                              trailing: load.rate.isNotEmpty && double.tryParse(load.rate.replaceAll(',', '')) != null
                                  ? Text(
                                      bid.amount > double.parse(load.rate.replaceAll(',', '')) 
                                          ? '+\$${(bid.amount - double.parse(load.rate.replaceAll(',', ''))).toStringAsFixed(2)}'
                                          : '-\$${(double.parse(load.rate.replaceAll(',', '')) - bid.amount).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: bid.amount > double.parse(load.rate.replaceAll(',', '')) 
                                            ? Colors.green 
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          )),
                    ],
                  ),
                ),
                if (!load.isBrokerPost) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.bid, arguments: load);
                    },
                    child: const Text('Quote / Bid'),
                  ),
                ],
              ],
            ),
          ),
          // Removed TawkToChatButton as per user request
          // const Positioned(
          //   bottom: 20,
          //   right: 20,
          //   child: TawkToChatButton(),
          // ),
        ],
      ),
    );
  }

  Widget _buildDistanceWidget(LoadPost load) {
    // First try to get the pickup-to-delivery distance directly
    final directDistance = load.pickupToDeliveryDistance;
    
    if (directDistance != null) {
      return Row(
        children: [
          const Icon(Icons.route, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            'Distance: $directDistance',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _refreshDistance(),
            child: const Icon(
              Icons.refresh,
              color: Colors.blue,
              size: 16,
            ),
          ),
        ],
      );
    }
    
    // Fallback to API-based calculation if coordinates are not available
    return FutureBuilder<String?>(
      key: ValueKey(_distanceKey ?? load.id),
      future: Provider.of<LoadProvider>(context, listen: false).calculateDistance(load),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              const Text(
                'Distance: Calculating...',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Distance: Error calculating',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _refreshDistance(),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
            ],
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          
          // Handle different error states
          if (data.contains('Location not found')) {
            return Row(
              children: [
                const Icon(Icons.location_off, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Distance: Location not found',
                  style: TextStyle(color: Colors.orange),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _refreshDistance(),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
              ],
            );
          }
          
          if (data.contains('Error calculating') || data.contains('Calculation failed')) {
            return Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Distance: $data',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _refreshDistance(),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
              ],
            );
          }

          // Format the distance display
          final regex = RegExp(r'(\d+(\.\d+)?)');
          final match = regex.firstMatch(data);
          
          Widget distanceWidget;
          if (match != null) {
            final value = double.tryParse(match.group(1)!);
            if (value != null) {
              final formatted = value.toStringAsFixed(1);
              final unit = data.replaceAll(regex, '').trim();
              distanceWidget = Text(
                'Distance: $formatted $unit',
                style: TextStyle(
                  color: data.contains('(est.)') ? Colors.orange : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              );
            } else {
              distanceWidget = Text(
                'Distance: $data',
                style: TextStyle(
                  color: data.contains('(est.)') ? Colors.orange : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              );
            }
          } else {
            distanceWidget = Text(
              'Distance: $data',
              style: TextStyle(
                color: data.contains('(est.)') ? Colors.orange : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            );
          }

          return Row(
            children: [
              if (data.contains('(est.)')) ...[
                const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
              ],
              distanceWidget,
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _refreshDistance(),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Distance: N/A',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _refreshDistance(),
              child: const Icon(
                Icons.refresh,
                color: Colors.blue,
                size: 16,
              ),
            ),
          ],
        );
      },
    );
  }

  void _refreshDistance() {
    setState(() {
      _distanceKey = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }
}
