import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_community_safety/models/incident_model.dart';
import 'package:smart_community_safety/screens/report_incident_screen.dart';
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/services/location_service.dart';
import 'package:smart_community_safety/services/unsafe_zone_service.dart'; // ✅ ADD THIS IMPORT
import 'package:smart_community_safety/utils/constants.dart';

class SafetyMapScreen extends StatefulWidget {
  final bool isEmbedded;

  const SafetyMapScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  State<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends State<SafetyMapScreen> {
  LatLng? _userLocation;
  List<IncidentModel> _incidents = [];
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadData();
    _checkUnsafeZones(); // ✅ CALL UNSAFE ZONE CHECK
  }


  Future<void> _loadData() async {
    _incidents = HiveService.incidentBox.values.toList();

    final locationService = LocationService();
    final location = await locationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _userLocation = location;
      });
      if (!widget.isEmbedded) {
        _mapController.move(location, 15.0);
      }
    }
  }

  // ✅ ADD UNSAFE ZONE CHECK METHOD
  Future<void> _checkUnsafeZones() async {
    // ✅ Only check if we have user location
    if (_userLocation == null) return;

    final unsafeZone = await UnsafeZoneService.checkUserProximity(_userLocation!);
    if (unsafeZone != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ You are in ${unsafeZone.name}!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showReportHereDialog(LatLng location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Incident Here?'),
        content: const Text('Do you want to report an incident at this location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportIncidentScreen(
                    initialLocation: location,
                  ),
                ),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidentMarkers = _incidents.map((incident) {
      return Marker(
        width: 40,
        height: 40,
        point: incident.location,
        child: GestureDetector(
          onTap: () {
            // TODO: Open detail
          },
          child: Icon(
            Icons.warning,
            color: AppConstants.getSeverityColor(incident.severity),
            size: 40,
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: widget.isEmbedded
          ? null
          : AppBar(
        title: const Text('Safety Map'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _userLocation ?? const LatLng(33.6844, 73.0479),
          initialZoom: _userLocation != null ? 15.0 : 10.0,
          maxZoom: 18.0,
          onTap: widget.isEmbedded
              ? null
              : (point, latLong) => _showReportHereDialog(latLong),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // ✅ Fixed extra spaces
            additionalOptions: {
              'Accept-Language': 'en',
            },
            userAgentPackageName: 'smart_community_safety',
          ),
          // ✅ HEATMAP LAYER
          // ✅ ADD THIS INSTEAD (inside FlutterMap children)
          if (_incidents.isNotEmpty)
            CircleLayer(
              circles: _incidents.map((incident) {
                return CircleMarker(
                  point: incident.location,
                  radius: 30.0, // Larger = more intense
                  color: AppConstants.getSeverityColor(incident.severity).withOpacity(0.3),
                  borderColor: Colors.transparent,
                  borderStrokeWidth: 0,
                );
              }).toList(),
            ),
          if (_userLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: _userLocation!,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ],
            ),
          MarkerLayer(markers: incidentMarkers),
        ],
      ),
      floatingActionButton: widget.isEmbedded
          ? null
          : FloatingActionButton(
        onPressed: _userLocation != null
            ? () => _showReportHereDialog(_userLocation!)
            : null,
        child: const Icon(Icons.add_alert),
        backgroundColor: Colors.red,
      ),
    );
  }
}