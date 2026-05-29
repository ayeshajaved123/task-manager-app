// lib/services/chat_service.dart
import 'package:uuid/uuid.dart';
import 'package:smart_community_safety/models/chat_message.dart';
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/services/auth_service.dart';

class ChatService {
  final String _tempSenderId = 'temp_local';

  // Send a message (saves to Hive immediately)
  Future<void> sendMessage({
    required String text,
    String? senderName,
  }) async {
    final authUser = await AuthService().getCurrentUserFromHive();
    final name = senderName ?? authUser?.name ?? 'Anonymous';

    final message = ChatMessage(
      id: const Uuid().v4(),
      senderId: authUser?.id ?? _tempSenderId,
      senderName: name,
      text: text,
      timestamp: DateTime.now(),
      // ❌ REMOVED: isLocalOnly: true — not part of model & deprecated in Hive
    );

    // ✅ Save to Hive (local only — no isLocalOnly needed)
    await HiveService.chatBox.put(message.id, message);
  }

  // Get all messages (local + synced)
  List<ChatMessage> getLocalMessages() {
    return HiveService.chatBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}