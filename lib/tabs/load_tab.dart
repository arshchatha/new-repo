import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/enhanced_load_board.dart';
import '../providers/load_provider.dart';
import '../providers/auth_provider.dart';
import '../models/load_post.dart';

class LoadTab extends StatefulWidget {
  const LoadTab({super.key});

  @override
  State<LoadTab> createState() => _LoadTabState();
}

class _LoadTabState extends State<LoadTab> {
  @override
  void initState() {
    super.initState();
    final loadProvider = Provider.of<LoadProvider>(context, listen: false);
    loadProvider.fetchLoads();
  }

  @override
  Widget build(BuildContext context) {
    final loadProvider = Provider.of<LoadProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    return Scaffold(
      body: FutureBuilder<List<LoadPost>>(
        future: loadProvider.carrierPostsForUser(currentUser, applyFilters: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final carrierLoads = snapshot.data ?? [];

          if (carrierLoads.isEmpty) {
            return const Center(child: Text('No carrier loads found'));
          }

          return EnhancedLoadBoard(
            showPostedLoads: true,
            loads: carrierLoads,
            isAvailableLoadsScreen: true,
          );
        },
      ),
    );
  }
}
