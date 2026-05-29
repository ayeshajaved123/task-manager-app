import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../providers/incident_provider.dart';
import '../../../data/models/incident.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // ✅ Google-like street map (no key)
  static const String _esriUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final List<Incident> list = p.realtime.isNotEmpty ? p.realtime : p.local;

    final center = list.isNotEmpty
        ? LatLng(list.first.lat, list.first.lng)
        : const LatLng(33.6844, 73.0479);

    return Scaffold(
      appBar: AppBar(title: const Text("Safety Map")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: _esriUrl,
                userAgentPackageName: 'com.example.smart_community_safety',
              ),
              MarkerLayer(
                markers: list.map((e) {
                  final color = e.severity >= 3
                      ? Colors.red
                      : (e.severity == 2 ? Colors.orange : Colors.green);

                  return Marker(
                    point: LatLng(e.lat, e.lng),
                    width: 46,
                    height: 46,
                    child: GestureDetector(
                      onTap: () => _showIncident(context, e),
                      child: Icon(Icons.location_on, size: 44, color: color),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _legendDot(Colors.red, "High"),
                    const SizedBox(width: 12),
                    _legendDot(Colors.orange, "Medium"),
                    const SizedBox(width: 12),
                    _legendDot(Colors.green, "Low"),
                    const Spacer(),
                    Text("Pins: ${list.length}",
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String t) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }

  void _showIncident(BuildContext context, Incident inc) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inc.category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(inc.description),
            const SizedBox(height: 12),
            Row(
              children: [
                _pill("Severity: ${inc.severity}"),
                const SizedBox(width: 8),
                _pill("Lat: ${inc.lat.toStringAsFixed(4)}"),
                const SizedBox(width: 8),
                _pill("Lng: ${inc.lng.toStringAsFixed(4)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.06),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
