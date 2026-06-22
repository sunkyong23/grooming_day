import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RainbowBgmService {
  static final AudioPlayer _player = AudioPlayer();

  static const String _initializedKey = 'rainbow_bgm_initialized';
  static const String _enabledKey = 'rainbow_bgm_enabled';

  static bool _isPlaying = false;

  static Future<bool> isInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initializedKey) ?? false;
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> saveSetting(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_initializedKey, true);
    await prefs.setBool(_enabledKey, enabled);
  }

  static Future<void> play() async {
    if (_isPlaying) return;

    await _player.setReleaseMode(ReleaseMode.loop);

    await _player.play(AssetSource('audio/rainbow_bgm.mp3'), volume: 0.4);

    _isPlaying = true;
  }

  static Future<void> stop() async {
    if (!_isPlaying) return;

    await _player.stop();
    _isPlaying = false;
  }
}
