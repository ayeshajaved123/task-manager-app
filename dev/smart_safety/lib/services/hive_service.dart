// lib/services/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_community_safety/models/incident_model.dart';
import 'package:smart_community_safety/models/chat_message.dart';
import 'package:smart_community_safety/models/user_model.dart';
import 'package:smart_community_safety/models/contact_model.dart';
import 'package:smart_community_safety/models/setting_model.dart';
import 'package:smart_community_safety/models/unsafe_zone_model.dart';

class HiveService {
  static late Box<IncidentModel> incidentBox;
  static late Box<ChatMessage> chatBox;
  static late Box<UserModel> userBox;
  static late Box<ContactModel> contactBox;
  static late Box<SettingModel> settingsBox;
  static late Box<UnsafeZone> unsafeZoneBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // ✅ MUST REGISTER ALL ADAPTERS
    Hive.registerAdapter(IncidentModelAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ContactModelAdapter());
    Hive.registerAdapter(SettingModelAdapter());


    // Open boxes
    incidentBox = await Hive.openBox<IncidentModel>('incidents');
    chatBox = await Hive.openBox<ChatMessage>('chat');
    userBox = await Hive.openBox<UserModel>('user');
    contactBox = await Hive.openBox<ContactModel>('contacts');
    settingsBox = await Hive.openBox<SettingModel>('settings');
    unsafeZoneBox = await Hive.openBox<UnsafeZone>('unsafe_zones');
  }
}