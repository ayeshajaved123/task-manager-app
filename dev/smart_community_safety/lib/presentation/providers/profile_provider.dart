import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repo);

  final ProfileRepository _repo;

  String name = '';
  String phone = '';
  String cnic = '';
  String photoPath = '';

  bool isVerified = false;
  bool verificationRequested = false;

  bool loading = false;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> load() async {
    final u = uid;
    if (u.isEmpty) return;

    loading = true;
    notifyListeners();

    final data = await _repo.loadProfile(u);

    name = (data['name'] ?? '').toString();
    phone = (data['phone'] ?? '').toString();
    cnic = (data['cnic'] ?? '').toString();
    photoPath = (data['photoPath'] ?? '').toString();

    isVerified = data['isVerified'] == true;
    verificationRequested = data['verificationRequested'] == true;

    loading = false;
    notifyListeners();
  }

  Future<void> save({
    required String name,
    required String phone,
    required String cnic,
    String? photoPath,
  }) async {
    final u = uid;
    if (u.isEmpty) return;

    loading = true;
    notifyListeners();

    await _repo.updateProfile(u, {
      'name': name,
      'phone': phone,
      'cnic': cnic,
      'photoPath': photoPath ?? this.photoPath,
      'isVerified': isVerified,
      'verificationRequested': verificationRequested,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });

    loading = false;
    await load();
  }

  Future<void> requestVerification() async {
    final u = uid;
    if (u.isEmpty) return;

    await _repo.requestVerification(u);
    await load();
  }
}
