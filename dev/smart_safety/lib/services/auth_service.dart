import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_community_safety/models/user_model.dart';
import 'package:smart_community_safety/services/hive_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Get current user from Hive (synchronous)
  UserModel? getCurrentUserFromHive() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    // Try to get from Hive
    UserModel? user = HiveService.userBox.get(firebaseUser.uid);
    if (user == null) {
      // Create temporary user
      user = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? 'No email',
        phone: firebaseUser.phoneNumber ?? '',
        cnic: '', // ✅ ADD THIS
        isVerified: firebaseUser.emailVerified,
        profilePicturePath: firebaseUser.photoURL,
      );
      HiveService.userBox.put(firebaseUser.uid, user);
    }
    return user;
  }

  // ✅ Sign up with email/password + save to Hive
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ✅ Provide empty string for cnic (required field)
      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone?.trim() ?? '',
        cnic: '', // ✅ ADD THIS LINE
        isVerified: false,
        profilePicturePath: null,
      );
      await HiveService.userBox.put(user.id!, user);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ✅ Sign in with email/password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ✅ Sign out + clear all Hive data
  Future<void> signOut() async {
    await _auth.signOut();
    await HiveService.incidentBox.clear();
    await HiveService.chatBox.clear();
    await HiveService.userBox.clear();
    await HiveService.contactBox.clear();
    await HiveService.settingsBox.clear();
  }
}