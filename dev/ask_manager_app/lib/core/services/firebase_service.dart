import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static Future<void> initialize() async {
    // 🔹 Bonus: Uncomment & configure when ready
    // await Firebase.initializeApp();
    print('Firebase core ready (placeholder for bonus setup)');
  }

  static Future<bool> loginWithEmail(String email, String password) async {
    try {
      // 🔹 Bonus: Replace with real Firebase Auth when configured
      // await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: email, password: password,
      // );
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
      return true;
    } catch (e) {
      print('Firebase login error: $e');
      return false;
    }
  }
}