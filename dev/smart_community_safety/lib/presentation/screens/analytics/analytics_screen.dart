import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/incident_provider.dart';
import '../../../data/models/incident.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final List<Incident> data =
    p.realtime.isNotEmpty ? p.realtime : p.local;

    final total = data.length;
    final low = data.where((e) => e.severity == 1).length;
    final med = data.where((e) => e.severity == 2).length;
    final high = data.where((e) => e.severity >= 3).length;

    final byCat = <String, int>{};
    for (final i in data) {
      final k = i.category.trim().isEmpty ? "Other" : i.category.trim();
      byCat[k] = (byCat[k] ?? 0) + 1;
    }

    final cats = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = cats.take(6).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          _titleCard(context, total),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _stat(context, "Low", low, Icons.check_circle_outline)),
              const SizedBox(width: 10),
              Expanded(child: _stat(context, "Medium", med, Icons.report_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _stat(context, "High", high, Icons.warning_amber_rounded)),
            ],
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 240,
                child: total == 0
                    ? const Center(child: Text("No incidents yet"))
                    : BarChart(_severityChart(low: low, med: med, high: high)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 300,
                child: total == 0
                    ? const Center(child: Text("No category data yet"))
                    : BarChart(_categoryChart(top)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── HEADER ─────────────

  Widget _titleCard(BuildContext context, int total) {
    final cs = Theme.of(context).colorScheme;
    return Card(
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
              child: Icon(Icons.bar_chart_rounded, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Analytics",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                Text("Total reports: $total",
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ───────────── STATS ─────────────

  Widget _stat(BuildContext context, String label, int value, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: cs.secondary.withOpacity(0.12),
              ),
              child: Icon(icon, size: 18, color: cs.secondary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text("$value",
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── SEVERITY CHART ─────────────

  BarChartData _severityChart({
    required int low,
    required int med,
    required int high,
  }) {
    final maxY =
        [low, med, high].reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return BarChartData(
      maxY: maxY,
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                v.toInt() == 0
                    ? "Low"
                    : v.toInt() == 1
                    ? "Medium"
                    : "High",
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
      barGroups: [
        BarChartGroupData(x: 0, barRods: [
          BarChartRodData(toY: low.toDouble(), color: Colors.green, width: 20)
        ]),
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(toY: med.toDouble(), color: Colors.orange, width: 20)
        ]),
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(toY: high.toDouble(), color: Colors.red, width: 20)
        ]),
      ],
    );
  }

  // ───────────── CATEGORY CHART ─────────────

  BarChartData _categoryChart(List<MapEntry<String, int>> top) {
    final maxY =
        top.map((e) => e.value).fold<int>(0, (m, v) => v > m ? v : m) + 1;

    return BarChartData(
      maxY: maxY.toDouble(),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= top.length) return const SizedBox.shrink();
              final label = top[i].key;
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  label.length > 8 ? "${label.substring(0, 8)}…" : label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: List.generate(top.length, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: top[i].value.toDouble(),
              color: Colors.blueAccent,
              width: 18,
            )
          ],
        );
      }),
    );
  }
}
