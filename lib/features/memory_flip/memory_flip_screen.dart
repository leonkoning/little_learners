import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_theme.dart';
import '../../shared/services/audio_service.dart';
import '../../shared/services/progress_service.dart';
import '../../shared/widgets/game_app_bar.dart';
import '../../shared/widgets/reward_overlay.dart';

class MemoryFlipScreen extends StatefulWidget {
  const MemoryFlipScreen({super.key});

  @override
  State<MemoryFlipScreen> createState() => _MemoryFlipScreenState();
}

class _MemoryFlipScreenState extends State<MemoryFlipScreen> {
  final _audio = AudioService();
  final _progress = ProgressService();

  static const List<String> _allEmojis = [
    '🦋', '🐛', '🐝', '🐸', '🐞', '🦎',
    '🌸', '🌼', '🌺', '🍄', '🌿', '🌻',
  ];

  late List<_CardData> _cards;
  int? _firstFlippedIndex;
  bool _isChecking = false;
  int _matchedPairs = 0;
  int _moves = 0;
  int _score = 0;
  bool _showReward = false;
  int _totalPairs = 3;

  @override
  void initState() {
    super.initState();
    _setupGame();
    _audio.playMusic('audio/music/garden_theme.mp3');
  }

  @override
  void dispose() {
    _audio.stopMusic();
    super.dispose();
  }

  void _setupGame() {
    final emojis = List<String>.from(_allEmojis)..shuffle();
    final selected = emojis.take(_totalPairs).toList();
    final pairs = [...selected, ...selected]..shuffle(Random());

    _cards = pairs
        .asMap()
        .entries
        .map((e) => _CardData(id: e.key, emoji: e.value))
        .toList();

    _firstFlippedIndex = null;
    _isChecking = false;
    _matchedPairs = 0;
    _moves = 0;
  }

  Future<void> _onCardTap(int index) async {
    if (_isChecking) return;
    final card = _cards[index];
    if (card.isFlipped || card.isMatched) return;

    _audio.playTap();
    setState(() => card.isFlipped = true);

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _isChecking = true;
      _moves++;

      final first = _cards[_firstFlippedIndex!];
      final second = card;

      await Future.delayed(const Duration(milliseconds: 700));

      if (first.emoji == second.emoji) {
        await _audio.playCorrect();
        setState(() {
          first.isMatched = true;
          second.isMatched = true;
          _matchedPairs++;
        });

        if (_matchedPairs == _totalPairs) {
          final stars = _moves <= _totalPairs + 1
              ? 3
              : _moves <= _totalPairs + 3
                  ? 2
                  : 1;
          setState(() => _score = stars);
          await _progress.addStars('memory_flip', stars);
          await _audio.playCelebration();
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) setState(() => _showReward = true);
        }
      } else {
        await _audio.playWrong();
        setState(() {
          first.isFlipped = false;
          second.isFlipped = false;
        });
      }

      _firstFlippedIndex = null;
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: 'Enchanted Garden',
        backgroundColor: AppTheme.gardenPurple,
        stars: _score,
      ),
      body: Stack(
        children: [
          // Garden background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF3E5F5),
                  Color(0xFFE1BEE7),
                  Color(0xFFCE93D8),
                ],
              ),
            ),
          ),

          // Decorative flowers
          const Positioned(top: 10, left: 10, child: Text('🌸', style: TextStyle(fontSize: 50))),
          const Positioned(top: 10, right: 10, child: Text('🌺', style: TextStyle(fontSize: 50))),
          const Positioned(bottom: 70, left: 10, child: Text('🌻', style: TextStyle(fontSize: 50))),
          const Positioned(bottom: 70, right: 10, child: Text('🌼', style: TextStyle(fontSize: 50))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Title & stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Find the pairs!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gardenDark,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(200),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '🌿 $_matchedPairs / $_totalPairs',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 20,
                            color: AppTheme.gardenDark,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Card grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: _cards.asMap().entries.map((entry) {
                        return _FlipCard(
                          card: entry.value,
                          onTap: () => _onCardTap(entry.key),
                          animationDelay: entry.key * 60,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Difficulty selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pairs: ',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          color: AppTheme.gardenDark,
                        ),
                      ),
                      ...[ 3, 4, 6].map((n) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _totalPairs = n;
                            _setupGame();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _totalPairs == n
                                ? AppTheme.gardenPurple
                                : Colors.white.withAlpha(200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$n',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _totalPairs == n
                                  ? Colors.white
                                  : AppTheme.gardenDark,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          if (_showReward)
            RewardOverlay(
              starsEarned: _score,
              onDismiss: () {
                setState(() {
                  _showReward = false;
                  _score = 0;
                  _setupGame();
                });
              },
            ),
        ],
      ),
    );
  }
}

class _CardData {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  _CardData({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _FlipCard extends StatefulWidget {
  final _CardData card;
  final VoidCallback onTap;
  final int animationDelay;

  const _FlipCard({
    required this.card,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _frontRotation = Tween<double>(begin: 0, end: pi / 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _backRotation = Tween<double>(begin: -pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(_FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isShowingFront = _controller.value < 0.5;
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(isShowingFront
                  ? _frontRotation.value
                  : _backRotation.value),
            alignment: Alignment.center,
            child: isShowingFront ? _buildBack() : _buildFront(),
          );
        },
      ),
    )
        .animate(delay: widget.animationDelay.ms)
        .fadeIn()
        .scale(curve: Curves.elasticOut);
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.gardenPurple, AppTheme.gardenDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gardenPurple.withAlpha(100),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text('🌸', style: TextStyle(fontSize: 36)),
      ),
    );
  }

  Widget _buildFront() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.card.isMatched
            ? AppTheme.correctGreen
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.card.isMatched
              ? AppTheme.correctGreen
              : AppTheme.gardenPurple,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.card.isMatched
                    ? AppTheme.correctGreen
                    : AppTheme.gardenPurple)
                .withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.card.emoji,
          style: const TextStyle(fontSize: 44),
        ),
      ),
    );
  }
}
