import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_theme.dart';
import '../../shared/services/audio_service.dart';
import '../../shared/services/progress_service.dart';
import '../../shared/widgets/bounce_tap.dart';
import '../../shared/widgets/game_app_bar.dart';
import '../../shared/widgets/reward_overlay.dart';

class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key});

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  final _audio = AudioService();
  final _progress = ProgressService();
  final _random = Random();

  static const List<String> _oceanObjects = [
    '🐠', '🐟', '🦀', '⭐', '🦑', '🐙', '🦞', '🐡'
  ];

  int _targetCount = 1;
  late String _currentEmoji;
  late List<int> _numberOptions;
  int _score = 0;
  int _roundsPlayed = 0;
  bool _showReward = false;
  int? _selectedNumber;
  bool _answered = false;
  int _tappedCount = 0;
  final Set<int> _tappedObjects = {};

  @override
  void initState() {
    super.initState();
    _nextRound();
    _audio.playMusic('audio/music/ocean_theme.mp3');
  }

  @override
  void dispose() {
    _audio.stopMusic();
    super.dispose();
  }

  void _nextRound() {
    _targetCount = _random.nextInt(5) + 1; // 1-5
    _currentEmoji = _oceanObjects[_random.nextInt(_oceanObjects.length)];
    final wrong1 = (_targetCount + _random.nextInt(3) + 1).clamp(1, 8);
    final wrong2 = max(1, _targetCount - _random.nextInt(3) - 1);
    final options = {_targetCount, wrong1, wrong2}.toList();
    while (options.length < 3) {
      options.add(_random.nextInt(5) + 1);
    }
    options.shuffle(_random);

    setState(() {
      _numberOptions = options.take(3).toList();
      _selectedNumber = null;
      _answered = false;
      _tappedCount = 0;
      _tappedObjects.clear();
    });
  }

  void _onObjectTap(int index) {
    if (_answered || _tappedObjects.contains(index)) return;
    _audio.playTap();
    setState(() {
      _tappedObjects.add(index);
      _tappedCount++;
    });
  }

  Future<void> _onNumberTap(int number) async {
    if (_answered) return;
    setState(() {
      _selectedNumber = number;
      _answered = true;
    });

    if (number == _targetCount) {
      await _audio.playCorrect();
      setState(() => _score++);
      _roundsPlayed++;

      await Future.delayed(const Duration(milliseconds: 900));

      if (_roundsPlayed >= 5) {
        await _progress.addStars('counting', _score.clamp(1, 3));
        if (mounted) setState(() => _showReward = true);
      } else {
        _nextRound();
      }
    } else {
      await _audio.playWrong();
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _selectedNumber = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: 'Ocean Cove',
        backgroundColor: AppTheme.oceanTeal,
        stars: _score,
      ),
      body: Stack(
        children: [
          // Ocean background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F7FA),
                  Color(0xFFB2EBF2),
                  Color(0xFF80DEEA),
                ],
              ),
            ),
          ),

          // Decorative elements
          const Positioned(top: 20, left: 10, child: Text('🌊', style: TextStyle(fontSize: 40))),
          const Positioned(top: 20, right: 10, child: Text('🌊', style: TextStyle(fontSize: 40))),
          const Positioned(bottom: 60, left: 0, child: Text('🪸', style: TextStyle(fontSize: 60))),
          const Positioned(bottom: 60, right: 0, child: Text('🪸', style: TextStyle(fontSize: 60))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Instruction
                  const Text(
                    'How many can you count?',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.oceanDark,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 8),

                  // Tap hint
                  const Text(
                    'Tap each one to count!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 16),

                  // Tapped count display
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _tappedCount == 0 ? '...' : '$_tappedCount',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.oceanDark,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 20),

                  // Objects grid
                  Expanded(
                    child: _OceanObjectsGrid(
                      count: _targetCount,
                      emoji: _currentEmoji,
                      tappedObjects: _tappedObjects,
                      onTap: _onObjectTap,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Number choices
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _numberOptions.map((n) {
                      final isSelected = _selectedNumber == n;
                      final isCorrect = n == _targetCount;
                      Color color = Colors.white;
                      if (isSelected && _answered) {
                        color = isCorrect
                            ? AppTheme.correctGreen
                            : AppTheme.wrongRed;
                      }

                      return BounceTap(
                        onTap: () => _onNumberTap(n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppTheme.oceanTeal,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.oceanTeal.withAlpha(80),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$n',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: isSelected && _answered
                                    ? Colors.white
                                    : AppTheme.oceanDark,
                              ),
                            ),
                          ),
                        ),
                      ).animate(delay: (100 * _numberOptions.indexOf(n)).ms)
                          .fadeIn()
                          .slideY(begin: 0.3);
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _roundsPlayed
                              ? AppTheme.oceanTeal
                              : Colors.white.withAlpha(180),
                          border: Border.all(
                            color: AppTheme.oceanDark,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          if (_showReward)
            RewardOverlay(
              starsEarned: _score.clamp(1, 3),
              onDismiss: () {
                setState(() {
                  _showReward = false;
                  _score = 0;
                  _roundsPlayed = 0;
                });
                _nextRound();
              },
            ),
        ],
      ),
    );
  }
}

class _OceanObjectsGrid extends StatelessWidget {
  final int count;
  final String emoji;
  final Set<int> tappedObjects;
  final void Function(int) onTap;

  const _OceanObjectsGrid({
    required this.count,
    required this.emoji,
    required this.tappedObjects,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: List.generate(count, (i) {
        final isTapped = tappedObjects.contains(i);
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTapped
                  ? AppTheme.oceanTeal.withAlpha(80)
                  : Colors.white.withAlpha(180),
              shape: BoxShape.circle,
              border: Border.all(
                color: isTapped ? AppTheme.oceanTeal : Colors.transparent,
                width: 3,
              ),
            ),
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 44,
                shadows: isTapped
                    ? [const Shadow(color: Colors.white, blurRadius: 8)]
                    : null,
              ),
            ),
          )
              .animate(
                key: ValueKey('obj_${emoji}_$count'),
                delay: (i * 80).ms,
              )
              .fadeIn()
              .scale(curve: Curves.elasticOut),
        );
      }),
    );
  }
}
