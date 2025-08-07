import 'package:flutter/material.dart';
import '../models/lane_preference.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LanePreferenceSettingsScreen extends StatefulWidget {
  const LanePreferenceSettingsScreen({super.key});

  @override
  State<LanePreferenceSettingsScreen> createState() => _LanePreferenceSettingsScreenState();
}

class _LanePreferenceSettingsScreenState extends State<LanePreferenceSettingsScreen> {
  List<LanePreference> _lanePreferences = [];

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _lanePreferences = List.from(user.lanePreferences);
    }
  }

  void _addLanePreference() {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();
    if (origin.isEmpty || destination.isEmpty) return;

    setState(() {
      _lanePreferences.add(LanePreference(origin: origin, destination: destination));
      _originController.clear();
      _destinationController.clear();
    });
  }

  void _removeLanePreference(int index) {
    setState(() {
      _lanePreferences.removeAt(index);
    });
  }

  Future<void> _savePreferences() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final updatedUser = user.copyWith(lanePreferences: _lanePreferences);
    await authProvider.register(updatedUser); // Assuming register updates user in DB and state
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lane preferences saved.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lane Preference Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePreferences,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _originController,
              decoration: const InputDecoration(labelText: 'Origin'),
            ),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Destination'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addLanePreference,
              child: const Text('Add Lane Preference'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _lanePreferences.length,
                itemBuilder: (context, index) {
                  final lane = _lanePreferences[index];
                  return ListTile(
                    title: Text('${lane.origin} → ${lane.destination}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeLanePreference(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
