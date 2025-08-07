import 'package:flutter/material.dart';
import '../widgets/safer_web_info_card.dart';

class SaferWebDetailsScreen extends StatelessWidget {
  final String identifier;
  final String title;

  const SaferWebDetailsScreen({
    super.key,
    required this.identifier,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SaferWebInfoCard(
          identifier: identifier,
          showFullDetails: true,
        ),
      ),
    );
  }
}
