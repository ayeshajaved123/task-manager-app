import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_community_safety/screens/login_screen.dart';
import 'package:smart_community_safety/screens/dashboard_screen.dart';
import 'package:smart_community_safety/services/auth_service.dart';
import 'package:smart_community_safety/utils/helpers.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    Timer(const Duration(seconds: 3), _checkAuth);
  }

  Future<void> _checkAuth() async {
    final user = await AuthService().getCurrentUserFromHive();
    final nextScreen = user != null ? const DashboardScreen() : const LoginScreen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      Helpers.slideRightRoute(builder: (_) => nextScreen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Built-in Flutter icon: security_update_good (represents safety)
              const Icon(
                Icons.security_update_good,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Smart Community Safety',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}