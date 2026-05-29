import 'package:hive/hive.dart';
import '../models/incident.dart';
import '../models/chat_message.dart';

class LocalDb {
  late Box<Incident> incidents;
  late Box<ChatMessage> chatMessages;

  Future<void> openBoxes() async {
    incidents = await Hive.openBox<Incident>('incidents_box');
    chatMessages = await Hive.openBox<ChatMessage>('chat_box');
  }
}
