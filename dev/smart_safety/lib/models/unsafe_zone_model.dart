import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'unsafe_zone_model.g.dart';

@HiveType(typeId: 50)
class UnsafeZone {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final LatLng center;
  @HiveField(3) final double radius; // meters
  @HiveField(4) final int severity;
  @HiveField(5) final DateTime createdAt;

  UnsafeZone({
    required this.id,
    required this.name,
    required this.center,
    required this.radius,
    required this.severity,
    required this.createdAt,
  });
}