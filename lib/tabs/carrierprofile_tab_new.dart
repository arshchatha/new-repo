import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/profile_edit_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class CarrierProfileTabNew extends StatefulWidget {
  const CarrierProfileTabNew({super.key});

  @override
  State<CarrierProfileTabNew> createState() => _CarrierProfileTabNewState();
}

class _CarrierProfileTabNewState extends State<CarrierProfileTabNew> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final themeProvider = context.watch<ThemeProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            '${user?.name ?? ''} - Carrier',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Navigate to change password
                },
                icon: const Icon(Icons.lock),
                label: const Text("Change Password"),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Contact Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          _infoRow("Phone", user?.phoneNumber ?? ''),
          _infoRow("Email", user?.email ?? ''),
          _infoRow("Address", user?.companyAddress ?? ''),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Company Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          _infoRow("Company", user?.companyName ?? ''),
          _infoRow("MC Number", user?.usDotMcNumber ?? ''),
          _infoRow("DOT Number", user?.usDotMcNumber ?? ''),
          _infoRow("Operating Since", "2015"),
          if ((user?.equipment != null) || (user?.lanePreferences.isNotEmpty ?? false)) ...[
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Equipment & Preferences",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            if (user?.equipment != null) _infoRow("Equipment Type", user?.equipment.toString() ?? ''),
            if (user?.lanePreferences.isNotEmpty ?? false)
              _infoRow("Lane Preferences", user!.lanePreferences.map((e) => '${e.origin} to ${e.destination}').join(', ')),
          ],
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Preferences",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Receive Load Alerts"),
            value: true,
            onChanged: (val) {
              // handle switch
            },
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            value: true,
            onChanged: (val) {
              // handle switch
            },
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) {
              themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          SwitchListTile(
            title: const Text("Enable Location Tracking"),
            value: false,
            onChanged: (val) {
              // handle switch
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
