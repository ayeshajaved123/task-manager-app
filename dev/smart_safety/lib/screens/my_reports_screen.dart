import 'package:flutter/material.dart';
import 'package:smart_community_safety/models/incident_model.dart';
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/utils/helpers.dart';
import 'package:smart_community_safety/widgets/incident_card.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late List<IncidentModel> _myReports;

  @override
  void initState() {
    super.initState();
    _loadMyReports();
  }

  void _loadMyReports() {
    // In a real app: filter by current user ID
    // For now: show all (since we only have one user in demo)
    _myReports = HiveService.incidentBox.values
        .where((incident) => incident.reporterId == 'current_user_id' || true) // Simplified
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _myReports.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No reports yet.\nReport an incident to get started!',
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
          : ListView.builder(
        itemCount: _myReports.length,
        itemBuilder: (context, index) {
          final report = _myReports[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Helpers.getSeverityColor(report.severity).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning,
                  color: Helpers.getSeverityColor(report.severity),
                  size: 20,
                ),
              ),
              title: Text(report.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.category),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatTimestamp(report.timestamp),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        report.isSynced ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: report.isSynced ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.isSynced ? 'Synced' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: report.isSynced ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to IncidentDetailScreen (future)
                Helpers.showSnackbar(context, 'Report details coming soon');
              },
            ),
          );
        },
      ),
    );
  }
}