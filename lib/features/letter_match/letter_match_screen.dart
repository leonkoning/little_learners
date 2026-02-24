import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_theme.dart';
import '../../shared/services/audio_service.dart';
import '../../shared/services/progress_service.dart';
import '../../shared/widgets/bounce_tap.dart';
import '../../shared/widgets/game_app_bar.dart';
import '../../shared/widgets/reward_overlay.dart';

class LetterMatchScreen extends StatefulWidget {
  const LetterMatchScreen({super.key});

  @override
  State<LetterMatchScreen> createState() => _LetterMatchScreenState();
}

class _LetterMatchScreenState extends State<LetterMatchScreen> {
  final _audio = AudioService();
  final _progress = ProgressService();
  final _random = Random();

  static const List<String> _letters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  late String _targetUpper;
  late List<String> _lowerOptions;
  int _score = 0;
  int _roundsPlayed = 0;
  bool _showReward = false;
  String? _selectedLower;
  bool _answered = false;
  bool _isCorrectDrop = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
    _audio.playMusic('audio/music/space_theme.mp3');
  }

  @override
  void dispose() {
    _audio.stopMusic();
    super.dispose();
  }

  void _nextRound() {
    final shuffled = List<String>.from(_letters)..shuffle(_random);
    _targetUpper = shuffled.first;
    final wrong = shuffled.skip(1).take(3).toList();
    _lowerOptions = [_targetUpper.toLowerCase(), ...wrong.map((l) => l.toLowerCase())]
      ..shuffle(_random);

    setState(() {
      _selectedLower = null;
      _answered = false;
      _isCorrectDrop = false;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _audio.playLetterSound(_targetUpper);
    });
  }

  Future<void> _onMatch(String lower) async {
    if (_answered) return;
    setState(() {
      _selectedLower = lower;
      _answered = true;
    });

    final isCorrect = lower == _targetUpper.toLowerCase();
    if (isCorrect) {
      _isCorrectDrop = true;
      await _audio.playCorrect();
      setState(() => _score++);
      _roundsPlayed++;

      await Future.delayed(const Duration(milliseconds: 900));

      if (_roundsPlayed >= 5) {
        await _progress.addStars('letter_match', _score.clamp(1, 3));
        if (mounted) setState(() => _showReward = true);
      } else {
        _nextRound();
      }
    } else {
      await _audio.playWrong();
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() {
        _selectedLower = null;
        _answered = false;
        _isCorrectDrop = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: 'Starship ABC',
        backgroundColor: AppTheme.spacePurple,
        stars: _score,
      ),
      body: Stack(
        children: [
          // Space background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0533),
                  Color(0xFF311B92),
                  Color(0xFF4A148C),
                ],
              ),
            ),
          ),

          // Stars decoration
          ..._buildStarDecorations(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Match the letters!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 8),
                  const Text(
                    'Drag the small letter to the planet!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      color: AppTheme.spaceLight,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  // Target planet (uppercase)
                  DragTarget<String>(
                    onAcceptWithDetails: (details) => _onMatch(details.data),
                    onWillAcceptWithDetails: (_) => !_answered,
                    builder: (context, candidateData, rejectedData) {
                      final isHovering = candidateData.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: _isCorrectDrop && _answered
                                ? [AppTheme.correctGreen, AppTheme.jungleDark]
                                : isHovering
                                    ? [AppTheme.spaceLight, AppTheme.spacePurple]
                                    : [
                                        const Color(0xFFCE93D8),
                                        AppTheme.spacePurple
                                      ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isHovering
                                      ? AppTheme.spaceLight
                                      : AppTheme.spacePurple)
                                  .withAlpha(120),
                              blurRadius: isHovering ? 30 : 20,
                              spreadRadius: isHovering ? 5 : 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _targetUpper,
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 88,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      .animate(key: ValueKey(_targetUpper))
                      .fadeIn()
                      .scale(curve: Curves.elasticOut),

                  const SizedBox(height: 48),

                  // Sound button
                  BounceTap(
                    onTap: () => _audio.playLetterSound(_targetUpper),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up_rounded,
                              color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Hear it!',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const Spacer(),

                  // Lowercase rockets
                  const Text(
                    'Rockets',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      color: AppTheme.spaceLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _lowerOptions.map((lower) {
                      final isSelected = _selectedLower == lower;
                      final isCorrect = lower == _targetUpper.toLowerCase();

                      return Draggable<String>(
                        data: lower,
                        feedback: Material(
                          color: Colors.transparent,
                          child: _RocketCard(
                            letter: lower,
                            color: AppTheme.starGold,
                            scale: 1.2,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _RocketCard(letter: lower),
                        ),
                        child: BounceTap(
                          onTap: () => _onMatch(lower),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: _RocketCard(
                              letter: lower,
                              color: isSelected && _answered
                                  ? (isCorrect
                                      ? AppTheme.correctGreen
                                      : AppTheme.wrongRed)
                                  : null,
                            ),
                          ),
                        ),
                      )
                          .animate(
                              delay: (_lowerOptions.indexOf(lower) * 100).ms)
                          .fadeIn()
                          .slideY(begin: 0.3);
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Progress
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
                              ? AppTheme.starGold
                              : Colors.white.withAlpha(60),
                          border: Border.all(
                              color: Colors.white54, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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

  List<Widget> _buildStarDecorations() {
    final stars = <Widget>[];
    final positions = [
      const Offset(20, 80), const Offset(80, 140), const Offset(300, 60),
      const Offset(340, 180), const Offset(50, 300), const Offset(320, 350),
      const Offset(160, 500), const Offset(260, 480), const Offset(30, 550),
    ];
    for (final pos in positions) {
      stars.add(Positioned(
        left: pos.dx,
        top: pos.dy,
        child: const Text('⭐', style: TextStyle(fontSize: 16))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1200.ms)
            .then()
            .fadeOut(duration: 1200.ms),
      ));
    }
    return stars;
  }
}

class _RocketCard extends StatelessWidget {
  final String letter;
  final Color? color;
  final double scale;

  const _RocketCard({
    required this.letter,
    this.color,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 76,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: color != null
                ? [color!.withAlpha(200), color!]
                : [const Color(0xFFCE93D8), AppTheme.spacePurple],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (color ?? AppTheme.spacePurple).withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              letter,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
