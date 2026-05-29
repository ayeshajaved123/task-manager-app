// lib/models/chat_message_model.dart
class ChatMessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'senderId': senderId,
    'senderName': senderName,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  static ChatMessageModel fromJson(Map<String, dynamic> json) => ChatMessageModel(
    id: json['id'],
    text: json['text'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
  );
}