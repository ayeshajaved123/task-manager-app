import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/chat_message.dart';
import '../../data/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._repo);

  final ChatRepository _repo;

  StreamSubscription<List<ChatMessage>>? _sub;

  List<ChatMessage> _realtime = [];
  List<ChatMessage> get realtime => _realtime;

  List<ChatMessage> get local => _repo.localMessages();

  void start() {
    _sub?.cancel();
    _sub = _repo.streamMessages().listen((list) {
      _realtime = list;
      notifyListeners();
    });
  }

  Future<void> send({
    required String userId,
    required String userName,
    required String text,
  }) async {
    final t = text.trim();
    if (t.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v4();

    final msg = ChatMessage(
      id: id,
      userId: userId,
      userName: userName, // ✅ NAME ONLY
      text: t,
      createdAt: now,
      isSynced: false,
    );

    await _repo.sendMessage(msg);

    // update UI immediately
    _realtime = [msg, ..._realtime];
    notifyListeners();
  }

  Future<void> sync() async {
    await _repo.syncPending();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
