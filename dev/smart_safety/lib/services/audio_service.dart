import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  // Play emergency alarm
  Future<void> playEmergencyAlarm() async {
    try {
      _isPlaying = true;
      await _player.play(AssetSource('sounds/emergency_alarm.mp3'));
      await _player.setVolume(1.0);
      await _player.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('Error playing alarm: $e');
      _isPlaying = false;
    }
  }

  // Stop emergency alarm
  Future<void> stopEmergencyAlarm() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  }

  // Play notification sound
  Future<void> playNotificationSound() async {
    try {
      await _player.play(AssetSource('sounds/notification.mp3'));
      await _player.setVolume(0.5);
    } catch (e) {
      print('Error playing notification: $e');
    }
  }

  bool get isPlaying => _isPlaying;
}