import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_community_safety/models/incident_model.dart';
import 'package:smart_community_safety/models/unsafe_zone_model.dart';
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/utils/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late List<IncidentModel> _incidents;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _incidents = HiveService.incidentBox.values.toList();
  }

  // ✅ CLUSTER INCIDENTS BY LOCATION (Simple proximity-based)
  List<Cluster> _clusterIncidents(List<IncidentModel> incidents) {
    final clusters = <Cluster>[];
    final processed = <IncidentModel>[];

    for (final incident in incidents) {
      if (processed.contains(incident)) continue;

      final clusterIncidents = <IncidentModel>[incident];
      processed.add(incident);

      // Find nearby incidents within 300 meters
      for (final other in incidents) {
        if (processed.contains(other)) continue;

        final distance = Geolocator.distanceBetween(
          incident.location.latitude,
          incident.location.longitude,
          other.location.latitude,
          other.location.longitude,
        );

        if (distance <= 300) {
          clusterIncidents.add(other);
          processed.add(other);
        }
      }

      // Calculate cluster center (average location)
      double totalLat = 0, totalLng = 0;
      int maxSeverity = 1;

      for (final inc in clusterIncidents) {
        totalLat += inc.location.latitude;
        totalLng += inc.location.longitude;
        if (inc.severity > maxSeverity) maxSeverity = inc.severity;
      }

      final center = LatLng(
        totalLat / clusterIncidents.length,
        totalLng / clusterIncidents.length,
      );

      clusters.add(Cluster(
        center: center,
        severity: maxSeverity,
        count: clusterIncidents.length,
      ));
    }
    return clusters;
  }

  // ✅ CREATE UNSAFE ZONES FROM HIGH-RISK AREAS
  Future<void> _createUnsafeZonesFromIncidents() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final highRiskIncidents = _incidents.where((i) => i.severity >= 2).toList();
      if (highRiskIncidents.isEmpty) {
        _showMessage('No high-severity incidents found.');
        return;
      }

      final clusters = _clusterIncidents(highRiskIncidents);
      int createdCount = 0;

      for (final cluster in clusters) {
        // Check if zone already exists near this cluster
        bool exists = false;
        for (final existing in HiveService.unsafeZoneBox.values) {
          final distance = Geolocator.distanceBetween(
            cluster.center.latitude,
            cluster.center.longitude,
            existing.center.latitude,
            existing.center.longitude,
          );
          if (distance <= 250) {
            exists = true;
            break;
          }
        }

        if (!exists) {
          final newZone = UnsafeZone(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'High Risk Area (${cluster.count} incidents)',
            center: cluster.center,
            radius: 250,
            severity: cluster.severity,
            createdAt: DateTime.now(),
          );
          await HiveService.unsafeZoneBox.put(newZone.id, newZone);
          createdCount++;
        }
      }

      _showMessage('Created $createdCount unsafe zone(s).');
    } catch (e) {
      _showMessage('Error creating zones: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ✅ CHART DATA METHODS
  List<BarChartGroupData> getBarGroups() {
    final data = <String, int>{};
    for (final cat in AppConstants.incidentCategories) {
      data[cat] = 0;
    }
    for (final incident in _incidents) {
      data[incident.category] = (data[incident.category] ?? 0) + 1;
    }

    return data.entries.map((entry) {
      final index = AppConstants.incidentCategories.indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            width: 20,
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> getPieSections() {
    final counts = [0, 0, 0];
    for (final incident in _incidents) {
      if (incident.severity >= 1 && incident.severity <= 3) {
        counts[incident.severity - 1]++;
      }
    }

    return [
      if (counts[0] > 0)
        PieChartSectionData(
          value: counts[0].toDouble(),
          color: const Color(0xFF26A69A),
          title: 'Low',
        ),
      if (counts[1] > 0)
        PieChartSectionData(
          value: counts[1].toDouble(),
          color: const Color(0xFFFF7043),
          title: 'Medium',
        ),
      if (counts[2] > 0)
        PieChartSectionData(
          value: counts[2].toDouble(),
          color: const Color(0xFFEF5350),
          title: 'High',
        ),
    ];
  }

  List<FlSpot> getLineSpots() {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - (6 - i));
      final count = _incidents.where((incident) =>
      incident.timestamp.year == date.year &&
          incident.timestamp.month == date.month &&
          incident.timestamp.day == date.day
      ).length;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Analytics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _incidents.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No data available.\nReport incidents to see analytics!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔥 UNSAFE ZONE MANAGEMENT
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danger Zone Management',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Automatically create unsafe zones from high-severity incident clusters.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _createUnsafeZonesFromIncidents,
                    icon: const Icon(Icons.gps_fixed),
                    label: Text(_isProcessing ? 'Processing...' : 'Create Unsafe Zones'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${HiveService.unsafeZoneBox.length} unsafe zone(s) currently active',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 📊 BAR CHART
          _buildChartCard(
            title: 'Incidents by Category',
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: getBarGroups(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < AppConstants.incidentCategories.length) {
                            final cat = AppConstants.incidentCategories[index];
                            return Text(
                              cat.length > 8 ? '${cat.substring(0, 8)}...' : cat,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  groupsSpace: 8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 🥧 PIE CHART
          _buildChartCard(
            title: 'Severity Distribution',
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: getPieSections(),
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 📈 LINE CHART
          _buildChartCard(
            title: 'Incidents This Week',
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: getLineSpots(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final now = DateTime.now();
                          final dayIndex = value.toInt();
                          if (dayIndex >= 0 && dayIndex < 7) {
                            final date = DateTime(now.year, now.month, now.day - (6 - dayIndex));
                            return Text('${date.day}/${date.month}');
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ✅ HELPER CLASS FOR CLUSTERING
class Cluster {
  final LatLng center;
  final int severity;
  final int count;

  Cluster({
    required this.center,
    required this.severity,
    required this.count,
  });
}