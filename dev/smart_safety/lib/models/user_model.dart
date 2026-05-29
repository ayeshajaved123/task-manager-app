// lib/models/user_model.dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 10)
class UserModel {
  @HiveField(0) final String id;
  @HiveField(1) final String name;
  @HiveField(2) final String email;
  @HiveField(3) final String phone;
  @HiveField(4) final String cnic;
  @HiveField(5) final bool isVerified;
  @HiveField(6) final String? profilePicturePath; // ✅ Local path (not URL)

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.isVerified,
    this.profilePicturePath, // ✅ Can be null
  });
}