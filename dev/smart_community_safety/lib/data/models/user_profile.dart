import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.cnic,
    required this.isVerified,
    required this.verificationRequested,
    required this.trustScore,
    required this.createdAt,
    required this.updatedAt,
    this.homeLat,
    this.homeLng,
    this.needsSync = false,
  });

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String cnic;

  @HiveField(5)
  final bool isVerified;

  @HiveField(6)
  final bool verificationRequested;

  @HiveField(7)
  final int trustScore;

  @HiveField(8)
  final int createdAt;

  @HiveField(9)
  final int updatedAt;

  @HiveField(10)
  final double? homeLat;

  @HiveField(11)
  final double? homeLng;

  @HiveField(12)
  final bool needsSync;

  UserProfile copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    String? cnic,
    bool? isVerified,
    bool? verificationRequested,
    int? trustScore,
    int? createdAt,
    int? updatedAt,
    double? homeLat,
    double? homeLng,
    bool? needsSync,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      isVerified: isVerified ?? this.isVerified,
      verificationRequested: verificationRequested ?? this.verificationRequested,
      trustScore: trustScore ?? this.trustScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      homeLat: homeLat ?? this.homeLat,
      homeLng: homeLng ?? this.homeLng,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'email': email,
    'fullName': fullName,
    'phone': phone,
    'cnic': cnic,
    'isVerified': isVerified,
    'verificationRequested': verificationRequested,
    'trustScore': trustScore,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'homeLat': homeLat,
    'homeLng': homeLng,
  };

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    int _int(dynamic v, int fallback) =>
        (v is int) ? v : (int.tryParse('$v') ?? fallback);

    double? _dbl(dynamic v) =>
        (v is num) ? v.toDouble() : (double.tryParse('$v'));

    final now = DateTime.now().millisecondsSinceEpoch;

    return UserProfile(
      uid: '${data['uid'] ?? ''}',
      email: '${data['email'] ?? ''}',
      fullName: '${data['fullName'] ?? ''}',
      phone: '${data['phone'] ?? ''}',
      cnic: '${data['cnic'] ?? ''}',
      isVerified: data['isVerified'] == true,
      verificationRequested: data['verificationRequested'] == true,
      trustScore: _int(data['trustScore'], 60),
      createdAt: _int(data['createdAt'], now),
      updatedAt: _int(data['updatedAt'], now),
      homeLat: _dbl(data['homeLat']),
      homeLng: _dbl(data['homeLng']),
      needsSync: false,
    );
  }
}
