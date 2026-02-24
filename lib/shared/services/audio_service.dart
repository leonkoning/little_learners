import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> init() async {
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _voicePlayer.setReleaseMode(ReleaseMode.stop);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playMusic(String assetPath) async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(assetPath));
      await _musicPlayer.setVolume(0.3);
    } catch (e) {
      debugPrint('AudioService: music error $e');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> playSfx(String assetPath) async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioService: sfx error $e');
    }
  }

  Future<void> playVoice(String assetPath) async {
    try {
      await _voicePlayer.stop();
      await _voicePlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioService: voice error $e');
    }
  }

  Future<void> playCorrect() async => playSfx('audio/sfx/correct.mp3');
  Future<void> playWrong() async => playSfx('audio/sfx/wrong.mp3');
  Future<void> playCelebration() async => playSfx('audio/sfx/celebration.mp3');
  Future<void> playTap() async => playSfx('audio/sfx/tap.mp3');

  Future<void> playLetterSound(String letter) async {
    await playVoice('audio/letters/${letter.toLowerCase()}.mp3');
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      _musicPlayer.stop();
    }
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
    _voicePlayer.dispose();
  }
}
