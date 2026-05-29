import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_community_safety/screens/splash_screen.dart';
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/utils/theme.dart';
import 'package:smart_community_safety/utils/theme_controller.dart';
import 'package:smart_community_safety/services/unsafe_zone_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const SmartCommunitySafetyApp(),
    ),
  );
}

class SmartCommunitySafetyApp extends StatelessWidget {
  const SmartCommunitySafetyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Community Safety',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Provider.of<ThemeController>(context).isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        // Optional: handle route names if needed
        return null;
      },
    );
  }
}