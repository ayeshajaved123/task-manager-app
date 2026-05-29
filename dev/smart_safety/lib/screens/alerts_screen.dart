import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_community_safety/models/incident_model.dart';
import 'package:smart_community_safety/screens/incident_detail_screen.dart'; // ✅ ADDED IMPORT
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/services/firestore_service.dart';
import 'package:smart_community_safety/utils/helpers.dart';
import 'package:smart_community_safety/widgets/incident_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late List<IncidentModel> _allAlerts;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    _allAlerts = HiveService.incidentBox.values
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {});
  }

  Map<DateTime, List<IncidentModel>> _groupByDay(List<IncidentModel> incidents) {
    final map = <DateTime, List<IncidentModel>>{};
    for (var incident in incidents) {
      final day = DateTime(incident.timestamp.year, incident.timestamp.month, incident.timestamp.day);
      map.putIfAbsent(day, () => []).add(incident);
    }
    return map;
  }

  String _getPeakHour(List<IncidentModel> incidents) {
    final hourCount = <int, int>{};
    for (var incident in incidents) {
      final hour = incident.timestamp.hour;
      hourCount[hour] = (hourCount[hour] ?? 0) + 1;
    }
    if (hourCount.isEmpty) return 'N/A';
    final peakHour = hourCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return DateFormat('h a').format(DateTime(2023, 1, 1, peakHour));
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day + 1);

    final todayAlerts = _allAlerts.where((i) => i.timestamp.isAfter(todayStart) && i.timestamp.isBefore(todayEnd)).toList();
    final weeklyAlerts = _allAlerts.where((i) => i.timestamp.isAfter(DateTime(today.year, today.month, today.day - 7))).toList();
    final groupedWeekly = _groupByDay(weeklyAlerts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Alerts'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _allAlerts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No alerts yet.\nYou’ll be notified when incidents are reported!',
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
          : RefreshIndicator(
        onRefresh: () async {
          _loadAlerts();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (todayAlerts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real-Time Alerts',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...todayAlerts.take(3).map((alert) {
                    return IncidentCard(
                      incident: alert,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => IncidentDetailScreen(incident: alert),
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today’s Summary',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('${todayAlerts.length} incident${todayAlerts.length == 1 ? '' : 's'} reported today'),
                    const SizedBox(height: 8),
                    Text('Peak activity: ${_getPeakHour(todayAlerts)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('${weeklyAlerts.length} incident${weeklyAlerts.length == 1 ? '' : 's'} in the past 7 days'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final day = DateTime(today.year, today.month, today.day - (6 - index));
                          final dayAlerts = groupedWeekly[DateTime(day.year, day.month, day.day)] ?? [];
                          return Column(
                            children: [
                              Container(
                                width: 30,
                                height: dayAlerts.length * 10 + 10,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${day.day}/${day.month}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All Alerts',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._allAlerts.map((alert) {
              return IncidentCard(
                incident: alert,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => IncidentDetailScreen(incident: alert),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}