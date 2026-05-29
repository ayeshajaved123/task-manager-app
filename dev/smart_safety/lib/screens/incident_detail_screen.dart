import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_community_safety/models/incident_model.dart';
import 'package:smart_community_safety/utils/constants.dart'; // ✅ ADDED
import 'package:smart_community_safety/utils/helpers.dart';

class IncidentDetailScreen extends StatelessWidget {
  final IncidentModel incident;

  const IncidentDetailScreen({Key? key, required this.incident}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final severityLabel = AppConstants.severityLabels[incident.severity] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(incident.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Severity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Helpers.getSeverityColor(incident.severity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$severityLabel • ${incident.category}',
              style: TextStyle(
                color: Helpers.getSeverityColor(incident.severity),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            incident.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          // Photos
          if (incident.photoPaths.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: incident.photoPaths.map((path) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          // Location
          const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            '${incident.location.latitude.toStringAsFixed(4)}, ${incident.location.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          // Mini Map
          SizedBox(
            height: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: incident.location,
                initialZoom: 15.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'smart_community_safety',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: incident.location,
                      child: Icon(
                        Icons.location_on,
                        color: Helpers.getSeverityColor(incident.severity),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Timestamp
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(Helpers.formatTimestamp(incident.timestamp)),
            ],
          ),
          const SizedBox(height: 16),
          // Sync Status
          Row(
            children: [
              Icon(
                incident.isSynced ? Icons.cloud_done : Icons.cloud_off,
                size: 16,
                color: incident.isSynced ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                incident.isSynced ? 'Synced to cloud' : 'Saved offline',
                style: TextStyle(
                  color: incident.isSynced ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}