import 'package:hive/hive.dart';
import '../models/incident.dart';
import '../models/user_profile.dart';

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(IncidentAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserProfileAdapter());
}
