import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'incident_model.g.dart';

@HiveType(typeId: 20)
class IncidentModel {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final String description;
  @HiveField(3) final String category;
  @HiveField(4) final int severity;
  @HiveField(5) final double latitude;
  @HiveField(6) final double longitude;
  @HiveField(7) final List<String> photoPaths;
  @HiveField(8) final String reporterId;
  @HiveField(9) final DateTime timestamp;
  @HiveField(10) final bool isAnonymous;
  @HiveField(11) final bool isSynced;

  LatLng get location => LatLng(latitude, longitude);

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.photoPaths,
    required this.reporterId,
    required this.timestamp,
    required this.isAnonymous,
    this.isSynced = false,
  });

  // ✅ ADD THIS METHOD
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'severity': severity,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      'reporterId': reporterId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isAnonymous': isAnonymous,
      'isSynced': true,
    };
  }
}