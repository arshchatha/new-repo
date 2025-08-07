import 'package:flutter/material.dart';
import '../widgets/enhanced_bids_board.dart';
import '../widgets/broker_received_bids_board.dart';
import '../providers/auth_provider.dart';

class BidsTab extends StatelessWidget {
  const BidsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context);
    final user = authProvider.user;

    if (user != null && user.isBroker) {
      return const BrokerReceivedBidsBoard();
    } else {
      return const EnhancedBidsBoard();
    }
  }
}
