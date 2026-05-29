import 'package:cloud_firestore/cloud_firestore.dart';
import '../local/local_db.dart';
import '../models/chat_message.dart';

class ChatRepository {
  ChatRepository({
    required FirebaseFirestore firestore,
    required LocalDb localDb,
  })  : _firestore = firestore,
        _db = localDb;

  final FirebaseFirestore _firestore;
  final LocalDb _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('community_chat');

  Stream<List<ChatMessage>> streamMessages() {
    return _col.orderBy('createdAt', descending: true).snapshots().map((snap) {
      final list = <ChatMessage>[];
      for (final doc in snap.docs) {
        final msg = ChatMessage.fromFirestore(doc.id, doc.data());
        list.add(msg);

        // cache locally best-effort
        try {
          _db.chatMessages.put(msg.id, msg);
        } catch (_) {}
      }
      return list;
    });
  }

  List<ChatMessage> localMessages() {
    final vals = _db.chatMessages.values.toList();
    vals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return vals;
  }

  Future<void> sendMessage(ChatMessage msg) async {
    // save local first
    await _db.chatMessages.put(msg.id, msg.copyWith(isSynced: false));

    try {
      await _col.doc(msg.id).set(msg.toFirestore());
      await _db.chatMessages.put(msg.id, msg.copyWith(isSynced: true));
    } catch (_) {
      // offline/unavailable: keep local
    }
  }

  Future<void> syncPending() async {
    final pending = _db.chatMessages.values.where((e) => e.isSynced == false).toList();
    for (final m in pending) {
      try {
        await _col.doc(m.id).set(m.toFirestore());
        await _db.chatMessages.put(m.id, m.copyWith(isSynced: true));
      } catch (_) {}
    }
  }
}
