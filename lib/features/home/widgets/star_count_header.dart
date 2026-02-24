import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class StarCountHeader extends StatelessWidget {
  final int stars;

  const StarCountHeader({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppTheme.starGold, size: 26),
          const SizedBox(width: 4),
          Text(
            '$stars',
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C3D2E),
            ),
          ),
        ],
      ),
    );
  }
}
