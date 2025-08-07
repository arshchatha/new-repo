import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_routes.dart';
import 'package:lboard/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile Settings'),
              onTap: () {
                // Navigate to profile settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('SaferWeb Search'),
              subtitle: const Text('Search carrier and broker information'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.saferWebSearch);
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: const Text('Choose app theme'),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Default'),
                  ),
                ],
                onChanged: (ThemeMode? mode) {
                  if (mode != null) {
                    themeProvider.setThemeMode(mode);
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              onTap: () {
                // Navigate to notification settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Security Settings'),
              onTap: () {
                // Navigate to security settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                // Navigate to help and support
              },
            ),
          ],
        ),
      ),
    );
  }
}
