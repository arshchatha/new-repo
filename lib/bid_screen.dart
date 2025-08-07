import 'package:flutter/material.dart';
import 'package:lboard/providers/provider.dart';
import '../../models/load_post.dart';


class BidScreen extends StatelessWidget {
  const BidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final load = ModalRoute.of(context)!.settings.arguments as LoadPost;
    final amountController = TextEditingController();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Bid')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bidding on: ${load.title}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Your Quote (\$)')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final bid = LoadPostQuote(bidder: user.name, amount: double.parse(amountController.text));
                Provider.of<LoadProvider>(context, listen: false).addBid(load.id, bid);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Bid Submitted'),
                    content: Text('You bid \$${amountController.text} for "${load.title}".'),
                    actions: [
                      TextButton(onPressed: () {
                        Navigator.pop(context); // close dialog
                        Navigator.pop(context); // back to details
                      }, child: const Text('OK')),
                    ],
                  ),
                );
              },
              child: const Text('Submit Bid'),
            ),
          ],
        ),
      ),
    );
  }
}
