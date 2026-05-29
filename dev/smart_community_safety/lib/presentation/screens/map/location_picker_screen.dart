import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initial;
  const LocationPickerScreen({super.key, required this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selected;

  // ✅ same tile as SafetyMap (Google-like, no key)
  static const String _esriUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _selected,
              initialZoom: 14,
              onTap: (_, latLng) => setState(() => _selected = latLng),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: _esriUrl,
                userAgentPackageName: 'com.example.smart_community_safety',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selected,
                    width: 46,
                    height: 46,
                    child: const Icon(Icons.location_on, size: 46, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _selected),
              child: const Text("Confirm Location"),
            ),
          )
        ],
      ),
    );
  }
}
