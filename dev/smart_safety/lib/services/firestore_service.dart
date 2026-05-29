// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_community_safety/models/chat_message.dart';
import 'package:smart_community_safety/models/incident_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ INCIDENT: Sync metadata (no photos)
  Future<void> syncIncidentToFirestore(IncidentModel incident) async {
    await _firestore.collection('incidents').doc(incident.id).set(
      incident.toFirestoreMap(),
    );
  }

  // ✅ CHAT: Listen to messages
  Stream<List<ChatMessage>> listenToChat() {
    return _firestore
        .collection('chat')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessage.fromJson(doc.data()))
        .toList());
  }

  // ✅ CHAT: Send message
  Future<void> sendMessage(ChatMessage message) async {
    await _firestore.collection('chat').add(message.toJson());
  }
}