import 'package:hive/hive.dart';

part 'incident.g.dart';

@HiveType(typeId: 1)
class Incident extends HiveObject {
  Incident({
    required this.id,
    required this.category,
    required this.description,
    required this.severity, // ✅ int
    required this.lat,
    required this.lng,
    required this.photoPaths,
    required this.createdAt, // ✅ int (msSinceEpoch)
    this.isSynced = false,
  });

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int severity;

  @HiveField(4)
  final double lat;

  @HiveField(5)
  final double lng;

  @HiveField(6)
  final List<String> photoPaths;

  @HiveField(7)
  final int createdAt;

  @HiveField(8)
  final bool isSynced;

  Incident copyWith({
    int? id,
    String? category,
    String? description,
    int? severity,
    double? lat,
    double? lng,
    List<String>? photoPaths,
    int? createdAt,
    bool? isSynced,
  }) {
    return Incident(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'description': description,
      'severity': severity,
      'lat': lat,
      'lng': lng,
      'photoPaths': photoPaths,
      'createdAt': createdAt,
      'isSynced': isSynced,
    };
  }

  /// ✅ Your codebase uses 1-arg fromFirestore(Map)
  /// We inject 'id' when reading from Firestore (see repository).
  factory Incident.fromFirestore(Map<String, dynamic> data) {
    return Incident(
      id: (data['id'] is int)
          ? data['id'] as int
          : int.tryParse('${data['id'] ?? 0}') ?? 0,
      category: '${data['category'] ?? ''}',
      description: '${data['description'] ?? ''}',
      severity: (data['severity'] is int)
          ? data['severity'] as int
          : int.tryParse('${data['severity'] ?? 1}') ?? 1,
      lat: (data['lat'] is num) ? (data['lat'] as num).toDouble() : 0.0,
      lng: (data['lng'] is num) ? (data['lng'] as num).toDouble() : 0.0,
      photoPaths: (data['photoPaths'] is List)
          ? (data['photoPaths'] as List).map((e) => e.toString()).toList()
          : <String>[],
      createdAt: (data['createdAt'] is int)
          ? data['createdAt'] as int
          : int.tryParse('${data['createdAt'] ?? 0}') ??
          DateTime.now().millisecondsSinceEpoch,
      isSynced: data['isSynced'] == true,
    );
  }
}
