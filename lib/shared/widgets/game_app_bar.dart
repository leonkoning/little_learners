import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_theme.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;
  final int stars;

  const GameAppBar({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.stars = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: foregroundColor,
            size: 32,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.starGold, size: 28),
              const SizedBox(width: 4),
              Text(
                '$stars',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}
