// lib/models/setting_model.dart
import 'package:hive/hive.dart';

part 'setting_model.g.dart';

@HiveType(typeId: 40)
class SettingModel {
  @HiveField(0) bool isDarkMode;
  @HiveField(1) bool notificationsEnabled;

  SettingModel({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
  });
}