import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_theme.dart';
import '../../shared/services/audio_service.dart';
import '../../shared/services/progress_service.dart';
import '../../shared/widgets/bounce_tap.dart';
import '../../shared/widgets/game_app_bar.dart';
import '../../shared/widgets/reward_overlay.dart';

class LetterSoundScreen extends StatefulWidget {
  const LetterSoundScreen({super.key});

  @override
  State<LetterSoundScreen> createState() => _LetterSoundScreenState();
}

class _LetterSoundScreenState extends State<LetterSoundScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  final _progress = ProgressService();
  final _random = Random();

  static const List<_LetterData> _letters = [
    _LetterData('A', '🐊', 'Alligator'),
    _LetterData('B', '🐻', 'Bear'),
    _LetterData('C', '🐱', 'Cat'),
    _LetterData('D', '🐶', 'Dog'),
    _LetterData('E', '🐘', 'Elephant'),
    _LetterData('F', '🐸', 'Frog'),
    _LetterData('G', '🦒', 'Giraffe'),
    _LetterData('H', '🦛', 'Hippo'),
    _LetterData('I', '🦎', 'Iguana'),
    _LetterData('J', '🐆', 'Jaguar'),
    _LetterData('K', '🦘', 'Kangaroo'),
    _LetterData('L', '🦁', 'Lion'),
    _LetterData('M', '🐒', 'Monkey'),
    _LetterData('N', '🦏', 'Rhino'),
    _LetterData('O', '🦦', 'Otter'),
    _LetterData('P', '🦜', 'Parrot'),
  ];

  late _LetterData _target;
  late List<_LetterData> _options;
  int _score = 0;
  int _roundsPlayed = 0;
  bool _showReward = false;
  String? _selectedLetter;
  bool _answered = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _nextRound();
    _audio.playMusic('audio/music/jungle_theme.mp3');
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _audio.stopMusic();
    super.dispose();
  }

  void _nextRound() {
    final shuffled = List<_LetterData>.from(_letters)..shuffle(_random);
    _target = shuffled.first;
    final wrongOptions = shuffled.skip(1).take(3).toList();
    _options = [_target, ...wrongOptions]..shuffle(_random);

    setState(() {
      _selectedLetter = null;
      _answered = false;
    });

    // Auto-play letter sound after a brief delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _playLetterSound();
    });
  }

  void _playLetterSound() {
    _audio.playLetterSound(_target.letter);
  }

  Future<void> _onOptionTap(_LetterData option) async {
    if (_answered) return;
    setState(() {
      _selectedLetter = option.letter;
      _answered = true;
    });

    if (option.letter == _target.letter) {
      await _audio.playCorrect();
      setState(() => _score++);
      _roundsPlayed++;

      await Future.delayed(const Duration(milliseconds: 900));

      if (_roundsPlayed >= 5) {
        await _progress.addStars('letter_sound', _score.clamp(1, 3));
        if (mounted) setState(() => _showReward = true);
      } else {
        _nextRound();
      }
    } else {
      await _audio.playWrong();
      _shakeController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _selectedLetter = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: 'Jungle Jamboree',
        backgroundColor: AppTheme.jungleGreen,
        stars: _score,
      ),
      body: Stack(
        children: [
          // Jungle background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFC8E6C9),
                  Color(0xFFA5D6A7),
                ],
              ),
            ),
          ),

          // Decorative leaves
          const Positioned(top: 0, left: 0, child: Text('🌿', style: TextStyle(fontSize: 60))),
          const Positioned(top: 0, right: 0, child: Text('🍃', style: TextStyle(fontSize: 60))),
          const Positioned(bottom: 80, left: 0, child: Text('🌴', style: TextStyle(fontSize: 70))),
          const Positioned(bottom: 80, right: 0, child: Text('🌴', style: TextStyle(fontSize: 70))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Instruction with sound button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Tap the letter you hear!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.jungleDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      BounceTap(
                        onTap: _playLetterSound,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.jungleGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.jungleGreen.withAlpha(100),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 32),

                  // Target animal hint
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.jungleGreen.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _target.emoji,
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                  )
                      .animate(key: ValueKey(_target.letter))
                      .fadeIn()
                      .scale(curve: Curves.elasticOut),

                  const SizedBox(height: 12),

                  Text(
                    _target.animal,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      color: AppTheme.jungleDark,
                    ),
                  ).animate(key: ValueKey('${_target.letter}_name')).fadeIn(),

                  const SizedBox(height: 40),

                  // Letter options grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _options.map((option) {
                        return _LetterOptionCard(
                          letterData: option,
                          isSelected: _selectedLetter == option.letter,
                          isCorrect: option.letter == _target.letter,
                          answered: _answered,
                          shakeAnimation: option.letter == _selectedLetter &&
                                  option.letter != _target.letter
                              ? _shakeAnimation
                              : null,
                          onTap: () => _onOptionTap(option),
                        );
                      }).toList(),
                    ),
                  ),

                  // Round progress
                  const SizedBox(height: 12),
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
                              ? AppTheme.jungleGreen
                              : Colors.white.withAlpha(180),
                          border: Border.all(
                            color: AppTheme.jungleDark,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Reward overlay
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

class _LetterOptionCard extends StatelessWidget {
  final _LetterData letterData;
  final bool isSelected;
  final bool isCorrect;
  final bool answered;
  final Animation<double>? shakeAnimation;
  final VoidCallback onTap;

  const _LetterOptionCard({
    required this.letterData,
    required this.isSelected,
    required this.isCorrect,
    required this.answered,
    required this.onTap,
    this.shakeAnimation,
  });

  Color get _cardColor {
    if (!answered || !isSelected) return Colors.white;
    return isCorrect ? AppTheme.correctGreen : AppTheme.wrongRed;
  }

  @override
  Widget build(BuildContext context) {
    Widget card = BounceTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.jungleGreen.withAlpha(60),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isSelected && answered && isCorrect
                ? AppTheme.correctGreen
                : AppTheme.jungleGreen.withAlpha(80),
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              letterData.letter,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 72,
                fontWeight: FontWeight.w700,
                color: isSelected && answered
                    ? Colors.white
                    : AppTheme.jungleDark,
              ),
            ),
            if (isSelected && answered && isCorrect)
              const Text('✓', style: TextStyle(fontSize: 24, color: Colors.white)),
          ],
        ),
      ),
    );

    if (shakeAnimation != null) {
      return AnimatedBuilder(
        animation: shakeAnimation!,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            sin(shakeAnimation!.value * pi) * 8,
            0,
          ),
          child: child,
        ),
        child: card,
      );
    }

    return card;
  }
}

class _LetterData {
  final String letter;
  final String emoji;
  final String animal;

  const _LetterData(this.letter, this.emoji, this.animal);
}
