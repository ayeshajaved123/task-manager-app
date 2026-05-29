import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/incident_provider.dart';
import '../../../data/models/incident.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final cs = Theme.of(context).colorScheme;

    final List<Incident> list =
    p.realtime.isNotEmpty ? p.realtime : p.local;

    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final start7Days = now.subtract(const Duration(days: 6));
    final start7DaysMs = DateTime(start7Days.year, start7Days.month, start7Days.day).millisecondsSinceEpoch;

    final today = list.where((e) => e.createdAt >= startToday).toList();
    final week = list.where((e) => e.createdAt >= start7DaysMs).toList();

    final todayHigh = today.where((e) => e.severity >= 3).length;
    final weekHigh = week.where((e) => e.severity >= 3).length;

    final peakHour = _computePeakHour(week);
    final areaStatus = _areaStatus(week);

    final weeklyCounts = _weeklyCounts(week);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alerts"),
        actions: [
          TextButton.icon(
            onPressed: () => p.sync(),
            icon: const Icon(Icons.sync),
            label: Text("${p.pendingCount}"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        children: [
          // Top summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: cs.primary.withOpacity(0.12),
                    ),
                    child: Icon(Icons.notifications_outlined, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Community Alerts",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text("Daily + weekly safety summary",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Daily summary + weekly status
          Row(
            children: [
              Expanded(
                child: _miniCard(
                  context,
                  title: "Today",
                  value: "${today.length} incidents",
                  subtitle: "High: $todayHigh",
                  icon: Icons.today_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniCard(
                  context,
                  title: "Past 7 days",
                  value: "${week.length} incidents",
                  subtitle: "High: $weekHigh",
                  icon: Icons.calendar_month_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Area status + peak hour
          Row(
            children: [
              Expanded(
                child: _statusCard(
                  context,
                  title: "Area Status",
                  status: areaStatus,
                  icon: Icons.shield_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniCard(
                  context,
                  title: "Peak Hour",
                  value: peakHour,
                  subtitle: "Based on 7-day data",
                  icon: Icons.access_time_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Weekly chart
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Summary (Last 7 Days)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: week.isEmpty
                        ? const Center(
                      child: Text("No incidents in past 7 days.",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    )
                        : BarChart(_weeklyBarChart(weeklyCounts)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tip: Severity 3+ incidents are considered unsafe zones.",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // New incidents list
          const Text(
            "New Incidents",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          if (list.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  "No incidents yet. Report one from Report screen.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            ...list.take(12).map((i) => _incidentTile(context, i)),
        ],
      ),
    );
  }

  Widget _incidentTile(BuildContext context, Incident i) {
    final dt = DateTime.fromMillisecondsSinceEpoch(i.createdAt);
    final time = DateFormat('dd MMM, hh:mm a').format(dt);
    final danger = i.severity >= 3;

    return Card(
      child: ListTile(
        leading: Icon(
          danger ? Icons.warning_amber_rounded : Icons.report_outlined,
        ),
        title: Text(i.category, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              i.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: danger
                ? Colors.red.withOpacity(0.12)
                : Colors.green.withOpacity(0.12),
          ),
          child: Text(
            danger ? "High" : (i.severity == 2 ? "Medium" : "Low"),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _miniCard(
      BuildContext context, {
        required String title,
        required String value,
        required String subtitle,
        required IconData icon,
      }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cs.secondary.withOpacity(0.12),
              ),
              child: Icon(icon, color: cs.secondary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(
      BuildContext context, {
        required String title,
        required String status,
        required IconData icon,
      }) {
    final cs = Theme.of(context).colorScheme;
    final isDanger = status == "Unsafe";

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: (isDanger ? Colors.red : cs.secondary).withOpacity(0.12),
              ),
              child: Icon(icon, color: isDanger ? Colors.red : cs.secondary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: isDanger ? Colors.red : cs.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text("Based on past 7 days",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _areaStatus(List<Incident> week) {
    final high = week.where((e) => e.severity >= 3).length;
    if (high >= 6) return "Unsafe";
    if (high >= 3) return "Caution";
    return "Safe";
  }

  String _computePeakHour(List<Incident> week) {
    if (week.isEmpty) return "—";
    final buckets = List<int>.filled(24, 0);
    for (final i in week) {
      final dt = DateTime.fromMillisecondsSinceEpoch(i.createdAt);
      buckets[dt.hour]++;
    }
    int bestHour = 0;
    int bestCount = buckets[0];
    for (int h = 1; h < 24; h++) {
      if (buckets[h] > bestCount) {
        bestCount = buckets[h];
        bestHour = h;
      }
    }
    final start = bestHour.toString().padLeft(2, '0');
    final end = ((bestHour + 1) % 24).toString().padLeft(2, '0');
    return "$start:00 - $end:00";
  }

  List<int> _weeklyCounts(List<Incident> week) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final counts = List<int>.filled(7, 0);

    for (final i in week) {
      final dt = DateTime.fromMillisecondsSinceEpoch(i.createdAt);
      final day = DateTime(dt.year, dt.month, dt.day);
      for (int idx = 0; idx < 7; idx++) {
        if (day == days[idx]) {
          counts[idx]++;
          break;
        }
      }
    }
    return counts;
  }

  BarChartData _weeklyBarChart(List<int> counts) {
    final maxY = (counts.reduce((a, b) => a > b ? a : b)).toDouble() + 1;

    return BarChartData(
      maxY: maxY,
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 34,
            getTitlesWidget: (v, meta) {
              final i = v.toInt();
              if (i < 0 || i > 6) return const SizedBox.shrink();
              final now = DateTime.now().subtract(Duration(days: 6 - i));
              final label = DateFormat('EEE').format(now); // Mon/Tue/...
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
              );
            },
          ),
        ),
      ),
      barGroups: List.generate(7, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: counts[i].toDouble(),
              width: 16,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        );
      }),
    );
  }
}
