import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  bool _active = false;

  late final AnimationController _blink =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 450));

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completeSub;

  @override
  void initState() {
    super.initState();
    _blink.repeat(reverse: true);

    // Ensure looping (some devices ignore setReleaseMode)
    _completeSub = _player.onPlayerComplete.listen((_) async {
      if (_active) {
        await _player.play(AssetSource('sounds/siren.mp3'));
      }
    });
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
    _blink.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _active = true);

    // Loop siren
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/sos_alarm.mp3'));
  }

  Future<void> _stop() async {
    setState(() => _active = false);
    await _player.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOS Emergency')),
      body: AnimatedBuilder(
        animation: _blink,
        builder: (_, __) {
          final bg = _active ? (_blink.value > 0.5 ? Colors.red : Colors.black) : null;

          return Container(
            color: bg,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _active ? 'SOS ACTIVE' : 'Tap SOS to activate',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _active ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Big Circular SOS Button (RED)
                  GestureDetector(
                    onTap: _active ? _stop : _start,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: _active ? 40 : 18,
                            spreadRadius: _active ? 6 : 2,
                            color: Colors.red.withOpacity(0.55),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _active ? 'STOP' : 'SOS',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Text(
                    _active
                        ? 'Siren is looping + screen blinking.\nTap STOP to end.'
                        : 'This will play a siren and blink the screen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _active ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
