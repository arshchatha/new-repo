import 'package:flutter/material.dart';
import '../widgets/enhanced_load_board.dart';
import '../widgets/carrier_bid_responses_board.dart';
import '../providers/auth_provider.dart';

class BiddingTab extends StatelessWidget {
  const BiddingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context);
    final user = authProvider.user;

    if (user != null && !user.isBroker) {
      // Carrier user: show loads carrier has bid on with broker responses
      return const CarrierBidResponsesBoard();
    } else {
      // Broker or other users: show enhanced load board
      return const EnhancedLoadBoard(
        showPostedLoads: false, // Show carrier posts for bidding
      );
    }
  }
}
