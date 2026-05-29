import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 30)
class ChatMessage extends HiveObject {
  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.isSynced = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String userName; // ✅ display name only

  @HiveField(3)
  final String text;

  @HiveField(4)
  final int createdAt;

  @HiveField(5)
  final bool isSynced;

  ChatMessage copyWith({
    String? id,
    String? userId,
    String? userName,
    String? text,
    int? createdAt,
    bool? isSynced,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'userName': userName,
    'text': text,
    'createdAt': createdAt,
  };

  factory ChatMessage.fromFirestore(String docId, Map<String, dynamic> data) {
    return ChatMessage(
      id: docId,
      userId: '${data['userId'] ?? ''}',
      userName: '${data['userName'] ?? 'Unknown'}',
      text: '${data['text'] ?? ''}',
      createdAt: (data['createdAt'] is int)
          ? data['createdAt'] as int
          : int.tryParse('${data['createdAt'] ?? 0}') ?? 0,
      isSynced: true,
    );
  }
}
