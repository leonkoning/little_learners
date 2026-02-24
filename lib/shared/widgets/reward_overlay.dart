import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/app_theme.dart';

class RewardOverlay extends StatefulWidget {
  final int starsEarned;
  final VoidCallback onDismiss;

  const RewardOverlay({
    super.key,
    required this.starsEarned,
    required this.onDismiss,
  });

  @override
  State<RewardOverlay> createState() => _RewardOverlayState();
}

class _RewardOverlayState extends State<RewardOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onDismiss,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Amazing!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ).animate().scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.starsEarned,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: const Icon(
                          Icons.star_rounded,
                          color: AppTheme.starGold,
                          size: 60,
                        )
                            .animate(delay: (i * 150).ms)
                            .scale(
                              begin: const Offset(0, 0),
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            )
                            .then()
                            .shimmer(duration: 800.ms),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.starGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text(
                      'Keep Going!',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppTheme.starGold,
              AppTheme.correctGreen,
              AppTheme.spacePurple,
              AppTheme.candyPink,
              AppTheme.oceanTeal,
            ],
            numberOfParticles: 30,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }
}
