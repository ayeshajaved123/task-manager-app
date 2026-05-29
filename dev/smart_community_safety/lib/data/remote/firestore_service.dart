import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get incidents => _db.collection('incidents');
  CollectionReference<Map<String, dynamic>> get profiles => _db.collection('profiles');
}
