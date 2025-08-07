import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/load_post.dart';
import '../widgets/location.dart';
import '../providers/load_provider.dart';

class LoadDetailsPopup extends StatefulWidget {
  final LoadPost load;

  const LoadDetailsPopup({super.key, required this.load});

  @override
  State<LoadDetailsPopup> createState() => _LoadDetailsPopupState();
}

class _LoadDetailsPopupState extends State<LoadDetailsPopup> {
  @override
  Widget build(BuildContext context) {
    final load = widget.load;
    final _ = Provider.of<LoadProvider>(context, listen: false);
    

    // Construct Location objects for origin and destination if possible
    final originLocation = load.pickupLatitude != null && load.pickupLongitude != null
        ? Location(
            latitude: load.pickupLatitude!,
            longitude: load.pickupLongitude!,
            displayName: load.origin,
          )
        : null;

    final destinationLocation = load.destinationLatitude != null && load.destinationLongitude != null
        ? Location(
            latitude: load.destinationLatitude!,
            longitude: load.destinationLongitude!,
            displayName: load.destination,
          )
        : null;

    return AlertDialog(
      title: Text('Load #${load.id} Details'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLoadDetails(load),
              const SizedBox(height: 16),
              if (originLocation != null && destinationLocation != null)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Map View',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Origin: ${originLocation.displayName}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Destination: ${destinationLocation.displayName}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location data not available',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
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
      ],
    );
  }

  Widget _buildLoadDetails(LoadPost load) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Origin: ${load.origin}'),
        Text('Destination: ${load.destination}'),
        Text('Pickup Date: ${load.formattedPickupDate}'),
        Text('Delivery Date: ${load.formattedDeliveryDate}'),
        Text('Rate: \$${load.rate}'),
        Text('Load Type: ${load.loadType ?? 'N/A'}'),
        Text('Equipment: ${load.equipmentString.isEmpty ? 'Any' : load.equipmentString}'),
        if (load.description.isNotEmpty) Text('Description: ${load.description}'),
      ],
    );
  }
}
