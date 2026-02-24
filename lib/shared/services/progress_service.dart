import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static const String _starsKey = 'total_stars';
  static const String _gameStarsPrefix = 'game_stars_';
  static const String _gameUnlockedPrefix = 'game_unlocked_';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Unlock first game by default
    await unlockGame('letter_sound');
  }

  int getTotalStars() => _prefs.getInt(_starsKey) ?? 0;

  int getGameStars(String gameId) =>
      _prefs.getInt('$_gameStarsPrefix$gameId') ?? 0;

  bool isGameUnlocked(String gameId) =>
      _prefs.getBool('$_gameUnlockedPrefix$gameId') ?? false;

  Future<void> addStars(String gameId, int stars) async {
    final current = getGameStars(gameId);
    final newStars = current + stars;
    await _prefs.setInt('$_gameStarsPrefix$gameId', newStars);

    final total = getTotalStars();
    await _prefs.setInt(_starsKey, total + stars);

    await _checkUnlocks();
  }

  Future<void> unlockGame(String gameId) async {
    await _prefs.setBool('$_gameUnlockedPrefix$gameId', true);
  }

  Future<void> _checkUnlocks() async {
    final total = getTotalStars();
    // Progressive unlocks based on total stars earned
    if (total >= 5) await unlockGame('counting');
    if (total >= 10) await unlockGame('letter_match');
    if (total >= 20) await unlockGame('memory_flip');
    if (total >= 30) await unlockGame('color_sort');
  }

  Future<void> resetProgress() async {
    await _prefs.clear();
    await unlockGame('letter_sound');
  }

  Map<String, dynamic> getSummary() {
    return {
      'totalStars': getTotalStars(),
      'letterSoundStars': getGameStars('letter_sound'),
      'countingStars': getGameStars('counting'),
      'letterMatchStars': getGameStars('letter_match'),
      'memoryFlipStars': getGameStars('memory_flip'),
      'colorSortStars': getGameStars('color_sort'),
    };
  }
}
