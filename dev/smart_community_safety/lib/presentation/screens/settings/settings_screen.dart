import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../providers/settings_provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ read provider safely; if not found, show fallback UI
    IncidentProvider? incidentProvider;
    try {
      incidentProvider = context.watch<IncidentProvider>();
    } catch (_) {
      incidentProvider = null;
    }

    AuthProvider? authProvider;
    try {
      authProvider = context.read<AuthProvider>();
    } catch (_) {
      authProvider = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Pending Reports'),
              subtitle: Text(
                incidentProvider == null
                    ? 'Incident provider not available in this route.'
                    : 'Pending: ${incidentProvider.pendingCount}',
              ),

              onTap: incidentProvider == null
                  ? null
                  : () async {
                await context.read<IncidentProvider>().sync();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync started')),
                );
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              value: context.watch<SettingsProvider>().isDark,
              onChanged: (v) => context.read<SettingsProvider>().setDark(v),
            ),
          ),

          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: authProvider == null
                  ? null
                  : () async {
                await context.read<AuthProvider>().logout();

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Back'),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
