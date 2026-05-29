import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/incident_provider.dart';
import '../../../data/models/incident.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<IncidentProvider>().startRealtime();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final _ = p.local; // ✅ FORCE rebuild when local cache updates
    final cs = Theme.of(context).colorScheme;

    // ✅ Use realtime if available, otherwise local Hive
    final List<Incident> feed =
    p.realtime.isNotEmpty ? p.realtime : p.local;

    final low = feed.where((e) => e.severity == 1).length;
    final med = feed.where((e) => e.severity == 2).length;
    final high = feed.where((e) => e.severity >= 3).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cs.primary.withOpacity(0.12),
                  ),
                  child: Icon(Icons.shield_rounded,
                      color: cs.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Smart Community Safety",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Total reports: ${feed.length}  •  Pending sync: ${p.pendingCount}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => p.sync(),
                  icon: const Icon(Icons.sync),
                  label: Text("${p.pendingCount}"),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text("Quick Actions",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.add_circle_outline,
                title: "Report",
                subtitle: "New incident",
                onTap: () => widget.onNavigate(1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.map_outlined,
                title: "Map",
                subtitle: "Unsafe zones",
                onTap: () => widget.onNavigate(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.notifications_outlined,
                title: "Alerts",
                subtitle: "Daily/Weekly",
                onTap: () => widget.onNavigate(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                context,
                icon: Icons.sos_rounded,
                title: "SOS",
                subtitle: "Emergency",
                onTap: () => widget.onNavigate(8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: _stat(context, "Low", low)),
            const SizedBox(width: 10),
            Expanded(child: _stat(context, "Medium", med)),
            const SizedBox(width: 10),
            Expanded(child: _stat(context, "High", high)),
          ],
        ),

        const SizedBox(height: 14),

        const Text("Recent Reports",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),

        // ✅ LOADING vs EMPTY STATE (ADDED)
        if (p.local.isEmpty && p.realtime.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (feed.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  const Text(
                    "No incidents found yet.",
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Go to Report Incident and submit one.\nIt will appear here immediately (offline or online).",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => widget.onNavigate(1),
                    child: const Text("Report Now"),
                  ),
                ],
              ),
            ),
          )
        else
          ...feed.take(10).map((i) => _tile(i)),
      ],
    );
  }

  Widget _tile(Incident i) {
    final dt = DateTime.fromMillisecondsSinceEpoch(i.createdAt);
    final when = DateFormat('dd MMM, hh:mm a').format(dt);
    final sev =
    i.severity >= 3 ? "High" : (i.severity == 2 ? "Medium" : "Low");

    return Card(
      child: ListTile(
        leading: Icon(i.severity >= 3
            ? Icons.warning_amber_rounded
            : Icons.report_outlined),
        title: Text(i.category,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(i.description,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(when,
                style:
                const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        trailing:
        Text(sev, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text("$value",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style:
                const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.primary.withOpacity(0.10),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                        const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
