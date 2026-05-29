// lib/screens/settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_safety/screens/emergency_contacts_screen.dart';
import 'package:smart_community_safety/screens/login_screen.dart';
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/utils/theme_controller.dart';
import 'package:smart_community_safety/models/setting_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingTile(
              context: context,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              icon: themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              onTap: () {
                themeController.toggleTheme();
                // Save to Hive
                HiveService.settingsBox.put(
                  'app_settings',
                  SettingModel(
                    isDarkMode: themeController.isDarkMode,
                    notificationsEnabled: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context: context,
              title: 'Notifications',
              subtitle: 'Get alerts for nearby incidents',
              icon: Icons.notifications,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications enabled')),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context: context,
              title: 'Emergency Contacts',
              subtitle: 'Manage your emergency contacts',
              icon: Icons.contacts,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              context: context,
              title: 'Sign Out',
              subtitle: 'Log out of your account',
              icon: Icons.logout,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                await HiveService.userBox.clear();
                await HiveService.settingsBox.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Community Safety',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}