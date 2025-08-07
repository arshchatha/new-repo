import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/enhanced_load_board.dart';
import '../providers/auth_provider.dart';
import '../models/load_post.dart';
import '../providers/load_provider.dart';

class PostedLoadsTab extends StatefulWidget {
  const PostedLoadsTab({super.key});

  @override
  State<PostedLoadsTab> createState() => _PostedLoadsTabState();
}

class _PostedLoadsTabState extends State<PostedLoadsTab> {
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
        future: loadProvider.getPostedLoadsForUser(currentUser),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final postedLoads = snapshot.data ?? [];

          if (postedLoads.isEmpty) {
            return const Center(child: Text('No posted loads found'));
          }

          return EnhancedLoadBoard(
            showPostedLoads: true,
            loads: postedLoads,
          );
        },
      ),
    );
  }
}
