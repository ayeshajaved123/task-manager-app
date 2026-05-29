import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';

import 'dashboard_screen.dart';
import '../report/report_screen.dart';
import '../map/map_screen.dart';
import '../alerts/alerts_screen.dart';
import '../analytics/analytics_screen.dart';
import '../chat/community_chat_screen.dart';
import '../contacts/emergency_contacts_screen.dart';
import '../profile/profile_screen.dart';
import '../sos/sos_screen.dart';
import '../settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _go(int i) {
    setState(() => _index = i);
    Navigator.of(context).maybePop(); // close drawer safely
  }

  @override
  void initState() {
    super.initState();

    // Start realtime stream after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().startRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final cs = Theme.of(context).colorScheme;

    final screens = <Widget>[
      DashboardScreen(onNavigate: _go), // 0
      const ReportScreen(),             // 1
      const MapScreen(),                // 2
      const AlertsScreen(),             // 3
      const AnalyticsScreen(),          // 4
      const ChatScreen(),               // 5
      const EmergencyContactsScreen(),  // 6
      const ProfileScreen(),            // 7
      const SosScreen(),                // 8
      const SettingsScreen(),           // 9
    ];

    final titles = <String>[
      "Dashboard",
      "Report Incident",
      "Safety Map",
      "Alerts",
      "Analytics",
      "Community Chat",
      "Emergency Contacts",
      "Profile",
      "SOS Emergency",
      "Settings",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          if (_index != 9)
            TextButton.icon(
              onPressed: () => incidents.sync(),
              icon: const Icon(Icons.sync),
              label: Text("${incidents.pendingCount}"),
            ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header (matches theme)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_rounded, color: Colors.white, size: 40),
                    const SizedBox(height: 10),
                    const Text(
                      "Smart Community Safety",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Report • Alerts • Map • SOS • Community",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "Pending sync: ${incidents.pendingCount}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    _item(Icons.dashboard_outlined, "Dashboard", 0),
                    _item(Icons.add_circle_outline, "Report Incident", 1),
                    _item(Icons.map_outlined, "Safety Map", 2),
                    _item(Icons.notifications_outlined, "Alerts", 3),
                    _item(Icons.bar_chart_rounded, "Analytics", 4),

                    const Divider(height: 22),

                    _item(Icons.chat_bubble_outline, "Community Chat", 5),
                    _item(Icons.call_outlined, "Emergency Contacts", 6),
                    _item(Icons.person_outline, "Profile & Verification", 7),
                    _item(Icons.sos_rounded, "SOS Emergency", 8),

                    const Divider(height: 22),

                    _item(Icons.settings_outlined, "Settings", 9),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: FilledButton.tonalIcon(
                  onPressed: () => incidents.sync(),
                  icon: const Icon(Icons.sync),
                  label: const Text("Sync now"),
                ),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: screens[_index],
      ),
    );
  }

  Widget _item(IconData icon, String title, int i) {
    final selected = _index == i;
    return ListTile(
      selected: selected,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      onTap: () => _go(i),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
