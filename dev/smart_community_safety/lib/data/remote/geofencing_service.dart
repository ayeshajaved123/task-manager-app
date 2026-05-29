import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';
import '../models/incident.dart';

class GeofencingService {
  GeofencingService(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;

  StreamSubscription<Position>? _positionSub;
  DateTime? _lastAlertAt;

  /// START geo-fencing
  Future<void> start({
    required List<Incident> Function() unsafeZonesProvider,
    double radiusMeters = 250,
    int cooldownSeconds = 120,
  }) async {
    // ✅ 1. Check if location services enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // ✅ 2. Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // ❌ If still denied → stop (no crash)
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    // ✅ 3. Start listening to user location
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // meters
      ),
    ).listen((pos) {
      _checkZones(
        pos.latitude,
        pos.longitude,
        unsafeZonesProvider(),
        radiusMeters,
        cooldownSeconds,
      );
    });
  }

  void _checkZones(
      double userLat,
      double userLng,
      List<Incident> zones,
      double radiusMeters,
      int cooldownSeconds,
      ) {
    final now = DateTime.now();

    if (_lastAlertAt != null &&
        now.difference(_lastAlertAt!).inSeconds < cooldownSeconds) {
      return;
    }

    final distance = const Distance();

    for (final z in zones) {
      final d = distance(
        LatLng(userLat, userLng),
        LatLng(z.lat, z.lng),
      );

      if (d <= radiusMeters) {
        _lastAlertAt = now;
        _notify(z);
        break;
      }
    }
  }

  Future<void> _notify(Incident z) async {
    const android = AndroidNotificationDetails(
      'geofence_alerts',
      'Unsafe Zone Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: android);

    await _notifications.show(
      0,
      '⚠ Unsafe Area Alert',
      'You entered a high-risk zone (${z.category})',
      details,
    );
  }

  void stop() {
    _positionSub?.cancel();
    _positionSub = null;
  }
}
