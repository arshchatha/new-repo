import 'package:flutter/material.dart';

class BiddingTab extends StatelessWidget {
  const BiddingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bids = [
      {'load': 'Toronto → Montreal', 'amount': 1200},
      {'load': 'Vancouver → Calgary', 'amount': 900},
    ];

    return ListView.builder(
      itemCount: bids.length,
      itemBuilder: (context, index) {
        final bid = bids[index];
        return Card(
          child: ListTile(
            title: Text(bid['load'] as String),
            trailing: Text('\$${bid['amount']}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Bid Details'),
                  content: Text('Amount: \$${bid['amount']}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
