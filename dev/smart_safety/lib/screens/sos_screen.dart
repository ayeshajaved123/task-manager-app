import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:smart_community_safety/utils/constants.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({Key? key}) : super(key: key);

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late Timer _countdownTimer;
  late Timer _blinkTimer;
  int _countdown = 5;
  bool _isBlinking = false;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _startSosSequence();
  }

  Future<void> _startSosSequence() async {
    // Start alarm sound with looping
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // ✅ Correct for v6.1.0
      await _audioPlayer.play(AssetSource('sounds/emergency_alarm.mp3'));
    } catch (e) {
      // Silent fail
    }

    // Start blinking
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isCancelled) {
        setState(() {
          _isBlinking = !_isBlinking;
        });
      }
    });

    // Start countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0 && !_isCancelled) {
        setState(() {
          _countdown--;
        });
      }
      if (_countdown == 0) {
        _triggerEmergencyActions();
        timer.cancel();
      }
    });
  }

  void _triggerEmergencyActions() {
    if (_isCancelled) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS sent! Emergency contacts notified.'),
        backgroundColor: Colors.red,
      ),
    );

    // Stop alarm after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      _stopAlarm();
    });
  }

  void _cancelSos() {
    if (_isCancelled) return;
    setState(() {
      _isCancelled = true;
    });
    _stopAlarm();
    _countdownTimer.cancel();
    _blinkTimer.cancel();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _stopAlarm() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _blinkTimer.cancel();
    _stopAlarm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isBlinking ? Colors.white : Colors.red;
    final textColor = _isBlinking ? Colors.red : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: bgColor,
        statusBarIconBrightness: _isBlinking ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bgColor,
        systemNavigationBarIconBrightness: _isBlinking ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EMERGENCY SOS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Sending SOS in:',
                style: TextStyle(
                  fontSize: 24,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$_countdown',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _cancelSos,
                icon: const Icon(Icons.check, size: 24),
                label: const Text('I\'m Safe', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}