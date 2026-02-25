import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _ttsReady = false;

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> init() async {
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);

    // Configure TTS for a child-friendly voice
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42); // Slower = clearer for toddlers
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.15); // Slightly higher = friendlier tone
      _ttsReady = true;
    } catch (e) {
      debugPrint('AudioService: TTS init error $e');
    }
  }

  // ── Music ─────────────────────────────────────────────────────────────────

  Future<void> playMusic(String assetPath) async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(assetPath));
      await _musicPlayer.setVolume(0.3);
    } catch (e) {
      // Music file missing — silently skip, app still works
      debugPrint('AudioService: music not found ($assetPath)');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  // ── SFX ───────────────────────────────────────────────────────────────────

  Future<void> playSfx(String assetPath) async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioService: sfx not found ($assetPath)');
    }
  }

  // ── Convenience SFX with TTS praise fallback ──────────────────────────────

  Future<void> playCorrect() async {
    await playSfx('audio/sfx/correct.wav');
    await _speak(_correctPhrases[_praiseIndex++ % _correctPhrases.length]);
  }

  Future<void> playWrong() async {
    await playSfx('audio/sfx/wrong.wav');
  }

  Future<void> playCelebration() async {
    await playSfx('audio/sfx/celebration.wav');
    await _speak('Amazing job!');
  }

  Future<void> playTap() async {
    await playSfx('audio/sfx/tap.wav');
  }

  // ── TTS — core educational narration ──────────────────────────────────────

  /// Speaks the phonetic sound of a letter, e.g. "Buh" for B
  Future<void> playLetterSound(String letter) async {
    const phonetics = {
      'A': 'Ay!',  'B': 'Buh!',  'C': 'Kuh!',  'D': 'Duh!',
      'E': 'Eh!',  'F': 'Fuh!',  'G': 'Guh!',  'H': 'Huh!',
      'I': 'Ih!',  'J': 'Juh!',  'K': 'Kuh!',  'L': 'Luh!',
      'M': 'Muh!', 'N': 'Nuh!',  'O': 'Oh!',   'P': 'Puh!',
      'Q': 'Kwuh!','R': 'Ruh!',  'S': 'Sss!',  'T': 'Tuh!',
      'U': 'Uh!',  'V': 'Vuh!',  'W': 'Wuh!',  'X': 'Eks!',
      'Y': 'Yuh!', 'Z': 'Zzz!',
    };
    final text = phonetics[letter.toUpperCase()] ?? letter;
    await _speak(text);
  }

  /// Speaks a number clearly, e.g. "Three!"
  Future<void> speakNumber(int number) async {
    const words = [
      '', 'One!', 'Two!', 'Three!', 'Four!', 'Five!',
      'Six!', 'Seven!', 'Eight!', 'Nine!', 'Ten!',
    ];
    if (number >= 1 && number <= 10) {
      await _speak(words[number]);
    }
  }

  /// Speaks any arbitrary string — for instructions, hints, or custom phrases
  Future<void> speak(String text) async => _speak(text);

  // ── Toggles ───────────────────────────────────────────────────────────────

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) _musicPlayer.stop();
  }

  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
    _tts.stop();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  int _praiseIndex = 0;
  static const List<String> _correctPhrases = [
    'Great job!', 'Wonderful!', 'You got it!', 'Excellent!',
    'Well done!', 'Amazing!', 'Super star!', 'Brilliant!',
  ];

  Future<void> _speak(String text) async {
    if (!_ttsReady) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('AudioService: TTS speak error $e');
    }
  }
}
