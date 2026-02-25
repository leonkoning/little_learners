import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_theme.dart';
import '../../shared/services/audio_service.dart';
import '../../shared/services/progress_service.dart';
import '../../shared/widgets/game_app_bar.dart';
import '../../shared/widgets/reward_overlay.dart';

class ColorSortScreen extends StatefulWidget {
  const ColorSortScreen({super.key});

  @override
  State<ColorSortScreen> createState() => _ColorSortScreenState();
}

class _ColorSortScreenState extends State<ColorSortScreen>
    with TickerProviderStateMixin {
  final _audio = AudioService();
  final _progress = ProgressService();
  final _random = Random();

  static const List<_BinData> _allBins = [
    _BinData('Red', Color(0xFFEF5350), '🍎', Colors.red),
    _BinData('Blue', Color(0xFF42A5F5), '🫐', Colors.blue),
    _BinData('Yellow', Color(0xFFFFCA28), '🌟', Colors.yellow),
    _BinData('Green', Color(0xFF66BB6A), '🍀', Colors.green),
  ];

  static const List<_CandyItem> _allCandies = [
    _CandyItem('🍎', Color(0xFFEF5350), 'Red'),
    _CandyItem('🍅', Color(0xFFEF5350), 'Red'),
    _CandyItem('❤️', Color(0xFFEF5350), 'Red'),
    _CandyItem('🫐', Color(0xFF42A5F5), 'Blue'),
    _CandyItem('💙', Color(0xFF42A5F5), 'Blue'),
    _CandyItem('🔵', Color(0xFF42A5F5), 'Blue'),
    _CandyItem('⭐', Color(0xFFFFCA28), 'Yellow'),
    _CandyItem('🌟', Color(0xFFFFCA28), 'Yellow'),
    _CandyItem('🍋', Color(0xFFFFCA28), 'Yellow'),
    _CandyItem('🍀', Color(0xFF66BB6A), 'Green'),
    _CandyItem('🥦', Color(0xFF66BB6A), 'Green'),
    _CandyItem('💚', Color(0xFF66BB6A), 'Green'),
  ];

  late List<_BinData> _activeBins;
  late List<_FallingCandy> _fallingCandies;
  int _score = 0;
  int _sorted = 0;
  final int _totalToSort = 8;
  bool _showReward = false;

  @override
  void initState() {
    super.initState();
    _setupRound();
    _audio.playMusic('audio/music/candy_theme.wav');
  }

  @override
  void dispose() {
    _audio.stopMusic();
    super.dispose();
  }

  void _setupRound() {
    final bins = List<_BinData>.from(_allBins)..shuffle(_random);
    _activeBins = bins.take(3).toList();

    final validCandies = _allCandies
        .where((c) => _activeBins.any((b) => b.colorName == c.colorName))
        .toList()
      ..shuffle(_random);

    _fallingCandies = validCandies
        .take(_totalToSort)
        .toList()
        .asMap()
        .entries
        .map((e) => _FallingCandy(
              id: e.key,
              candy: e.value,
              xPosition: 0.1 + _random.nextDouble() * 0.8,
              isSorted: false,
            ))
        .toList();

    setState(() {
      _sorted = 0;
    });
  }

  Future<void> _onDrop(_FallingCandy candy, _BinData bin) async {
    if (candy.isSorted) return;

    final isCorrect = candy.candy.colorName == bin.colorName;
    if (isCorrect) {
      await _audio.playCorrect();
      setState(() {
        candy.isSorted = true;
        _sorted++;
        _score++;
      });

      if (_sorted >= _totalToSort) {
        await _progress.addStars('color_sort', _score.clamp(1, 3));
        await _audio.playCelebration();
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() => _showReward = true);
      }
    } else {
      await _audio.playWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: 'Candy Kingdom',
        backgroundColor: AppTheme.candyPink,
        stars: _score,
      ),
      body: Stack(
        children: [
          // Candy background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFCE4EC),
                  Color(0xFFF8BBD0),
                  Color(0xFFF48FB1),
                ],
              ),
            ),
          ),

          // Decorative elements
          const Positioned(top: 10, left: 10, child: Text('🍭', style: TextStyle(fontSize: 48))),
          const Positioned(top: 10, right: 10, child: Text('🍬', style: TextStyle(fontSize: 48))),
          const Positioned(bottom: 130, left: 8, child: Text('🧁', style: TextStyle(fontSize: 50))),
          const Positioned(bottom: 130, right: 8, child: Text('🍩', style: TextStyle(fontSize: 50))),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sort the candies!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.candyDark,
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
                          '$_sorted / $_totalToSort',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 20,
                            color: AppTheme.candyDark,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),

                // Candy items area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: _fallingCandies.map((fc) {
                        return _DraggableCandyWidget(
                          fallingCandy: fc,
                          bins: _activeBins,
                          onDrop: _onDrop,
                          animationDelay: fc.id * 80,
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Sorting bins
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _activeBins.map((bin) {
                      return _SortingBin(
                        bin: bin,
                        onAccept: (candy) => _onDrop(candy, bin),
                        sortedCount: _fallingCandies
                            .where((fc) =>
                                fc.isSorted &&
                                fc.candy.colorName == bin.colorName)
                            .length,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          if (_showReward)
            RewardOverlay(
              starsEarned: _score.clamp(1, 3),
              onDismiss: () {
                setState(() {
                  _showReward = false;
                  _score = 0;
                  _setupRound();
                });
              },
            ),
        ],
      ),
    );
  }
}

class _DraggableCandyWidget extends StatelessWidget {
  final _FallingCandy fallingCandy;
  final List<_BinData> bins;
  final Future<void> Function(_FallingCandy, _BinData) onDrop;
  final int animationDelay;

  const _DraggableCandyWidget({
    required this.fallingCandy,
    required this.bins,
    required this.onDrop,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (fallingCandy.isSorted) {
      return const SizedBox(width: 72, height: 72);
    }

    return Draggable<_FallingCandy>(
      data: fallingCandy,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: fallingCandy.candy.color.withAlpha(200),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: fallingCandy.candy.color.withAlpha(120),
                blurRadius: 12,
              ),
            ],
          ),
          child: Center(
            child: Text(fallingCandy.candy.emoji,
                style: const TextStyle(fontSize: 36)),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _CandyCircle(candy: fallingCandy.candy),
      ),
      child: _CandyCircle(candy: fallingCandy.candy),
    )
        .animate(delay: animationDelay.ms)
        .fadeIn()
        .scale(curve: Curves.elasticOut);
  }
}

class _CandyCircle extends StatelessWidget {
  final _CandyItem candy;

  const _CandyCircle({required this.candy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: candy.color.withAlpha(60),
        shape: BoxShape.circle,
        border: Border.all(color: candy.color, width: 3),
        boxShadow: [
          BoxShadow(
            color: candy.color.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(candy.emoji, style: const TextStyle(fontSize: 34)),
      ),
    );
  }
}

class _SortingBin extends StatelessWidget {
  final _BinData bin;
  final void Function(_FallingCandy) onAccept;
  final int sortedCount;

  const _SortingBin({
    required this.bin,
    required this.onAccept,
    required this.sortedCount,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<_FallingCandy>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      onWillAcceptWithDetails: (_) => true,
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isHovering ? 96 : 86,
          height: isHovering ? 96 : 86,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bin.color.withAlpha(isHovering ? 220 : 160),
                bin.color,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bin.color.withAlpha(isHovering ? 160 : 80),
                blurRadius: isHovering ? 20 : 10,
                spreadRadius: isHovering ? 4 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(bin.emoji, style: const TextStyle(fontSize: 26)),
              Text(
                bin.colorName,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (sortedCount > 0)
                Text(
                  '×$sortedCount',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BinData {
  final String colorName;
  final Color color;
  final String emoji;
  final Color labelColor;

  const _BinData(this.colorName, this.color, this.emoji, this.labelColor);
}

class _CandyItem {
  final String emoji;
  final Color color;
  final String colorName;

  const _CandyItem(this.emoji, this.color, this.colorName);
}

class _FallingCandy {
  final int id;
  final _CandyItem candy;
  final double xPosition;
  bool isSorted;

  _FallingCandy({
    required this.id,
    required this.candy,
    required this.xPosition,
    required this.isSorted,
  });
}
