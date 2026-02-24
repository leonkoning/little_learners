import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/app_theme.dart';
import '../../../shared/widgets/bounce_tap.dart';
import '../home_screen.dart';

class WorldCard extends StatelessWidget {
  final WorldConfig world;
  final bool isUnlocked;
  final int stars;
  final VoidCallback onTap;
  final int animationDelay;

  const WorldCard({
    super.key,
    required this.world,
    required this.isUnlocked,
    required this.stars,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // World bubble
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isUnlocked
                      ? [world.color, world.darkColor]
                      : [Colors.grey.shade400, Colors.grey.shade600],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isUnlocked ? world.color : Colors.grey)
                        .withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        world.emoji,
                        style: const TextStyle(fontSize: 40),
                      )
                    : const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            ),

            const SizedBox(height: 6),

            // World name
            Text(
              world.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isUnlocked ? world.darkColor : Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Star count
            if (isUnlocked && stars > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  stars.clamp(0, 3),
                  (_) => const Icon(
                    Icons.star_rounded,
                    color: AppTheme.starGold,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: animationDelay.ms)
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.6, 0.6),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }
}
