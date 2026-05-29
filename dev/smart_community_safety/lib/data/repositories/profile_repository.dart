import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepository {
  ProfileRepository({required FirebaseFirestore firestore
  })  : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<Map<String, dynamic>> loadProfile(String uid) async {
    final snap = await _doc(uid).get();
    return snap.data() ?? <String, dynamic>{};
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> requestVerification(String uid) async {
    await _doc(uid).set({
      'verificationRequested': true,
      'verificationRequestedAt': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> streamProfile(String uid) {
    return _doc(uid).snapshots().map((s) => s.data() ?? <String, dynamic>{});
  }
}
