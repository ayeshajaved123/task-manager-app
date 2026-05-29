// lib/models/contact_model.dart
import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 30)
class ContactModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final bool isEmergency;

  ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.isEmergency = false,
  });
}