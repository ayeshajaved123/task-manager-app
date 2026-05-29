// lib/services/unsafe_zone_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart'; // ✅ REQUIRED IMPORT
import 'package:smart_community_safety/models/unsafe_zone_model.dart';
import 'package:smart_community_safety/services/hive_service.dart';

class UnsafeZoneService {
  static Future<void> createUnsafeZonesFromIncidents() async {
    final incidents = HiveService.incidentBox.values
        .where((i) => i.severity >= 2)
        .toList();

    for (final incident in incidents) {
      // ✅ Create unsafe zone from incident location
      final newZone = UnsafeZone(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${incident.category} Hotspot',
        center: incident.location, // ✅ This is safe - location is non-null in IncidentModel
        radius: 200,
        severity: incident.severity,
        createdAt: DateTime.now(),
      );
      await HiveService.unsafeZoneBox.put(newZone.id, newZone);
    }
  }

  static Future<UnsafeZone?> checkUserProximity(LatLng userLocation) async {
    final zones = HiveService.unsafeZoneBox.values.toList();

    for (final zone in zones) {
      // ✅ zone.center is non-null (defined in UnsafeZone model)
      final distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        zone.center.latitude, // ✅ Safe access
        zone.center.longitude,
      );

      if (distance <= zone.radius) {
        return zone;
      }
    }
    return null;
  }
}