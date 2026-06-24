import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityBgmService {
  static final AudioPlayer _player = AudioPlayer();

  static const String _enabledKey = 'community_bgm_enabled';

  static bool _isPlaying = false;

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> saveSetting(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  static Future<void> playIfEnabled() async {
    final enabled = await isEnabled();

    if (!enabled) {
      await stop();
      return;
    }

    await play();
  }

  static Future<void> play() async {
    if (_isPlaying) return;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('audio/community_bgm.mp3'), volume: 0.35);

    _isPlaying = true;
  }

  static Future<void> stop() async {
    if (!_isPlaying) return;

    await _player.stop();
    _isPlaying = false;
  }
}
