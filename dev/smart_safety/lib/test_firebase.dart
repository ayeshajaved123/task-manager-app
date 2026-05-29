import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('✅ Firebase connected successfully!');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 100, color: Colors.green),
                SizedBox(height: 20),
                Text('Firebase Connected!', style: TextStyle(fontSize: 24)),
                Text('All systems working', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  } catch (e) {
    print('❌ Firebase error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 100, color: Colors.red),
                SizedBox(height: 20),
                Text('Firebase Error:', style: TextStyle(fontSize: 24)),
                Text('$e', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}