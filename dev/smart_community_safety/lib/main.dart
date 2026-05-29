import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/local/local_db.dart';
import 'data/remote/auth_service.dart';

import 'data/repositories/incident_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/chat_repository.dart';

import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/incident_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/chat_provider.dart';

import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/home/home_shell.dart';
import 'presentation/screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Hive
  await Hive.initFlutter();

  // Local DB
  final localDb = LocalDb();
  await localDb.openBoxes();

  // Services
  final authService = AuthService();

  // Firestore
  final firestore = FirebaseFirestore.instance;

  // Repositories
  final incidentRepository = IncidentRepository(
    firestore: firestore,
    localDb: localDb,
  );

  // ✅ ProfileRepository should NOT take localDb (fixes your error)
  final profileRepository = ProfileRepository(
    firestore: firestore,
  );

  final chatRepository = ChatRepository(
    firestore: firestore,
    localDb: localDb,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider<IncidentProvider>(
          create: (_) => IncidentProvider(incidentRepository),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(profileRepository)..load(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(chatRepository),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) {
            final p = SettingsProvider();
            p.load();
            return p;
          },
        ),
      ],
      child: const SmartCommunitySafetyApp(),
    ),
  );
}

class SmartCommunitySafetyApp extends StatelessWidget {
  const SmartCommunitySafetyApp({super.key});

  static const Color _navy = Color(0xFF0B1F3A);
  static const Color _teal = Color(0xFF00B3A6);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Community Safety',
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _navy,
          primary: _navy,
          secondary: _teal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: _navy,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _navy,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _teal, width: 1.6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _teal,
          primary: _teal,
          secondary: _navy,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF121B2E),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF121B2E),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _teal, width: 1.6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ),

      // ✅ Routes so login can navigate to home
      routes: {
        '/home': (_) => const HomeShell(),
        '/login': (_) => const LoginScreen(),
      },

      home: const SplashScreen(),
    );
  }
}
