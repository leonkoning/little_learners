import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/letter_sound/letter_sound_screen.dart';
import '../features/letter_match/letter_match_screen.dart';
import '../features/counting/counting_screen.dart';
import '../features/color_sort/color_sort_screen.dart';
import '../features/memory_flip/memory_flip_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String letterSound = '/letter-sound';
  static const String letterMatch = '/letter-match';
  static const String counting = '/counting';
  static const String colorSort = '/color-sort';
  static const String memoryFlip = '/memory-flip';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: letterSound,
        name: 'letter-sound',
        pageBuilder: (context, state) => _buildPage(
          context,
          state,
          const LetterSoundScreen(),
        ),
      ),
      GoRoute(
        path: letterMatch,
        name: 'letter-match',
        pageBuilder: (context, state) => _buildPage(
          context,
          state,
          const LetterMatchScreen(),
        ),
      ),
      GoRoute(
        path: counting,
        name: 'counting',
        pageBuilder: (context, state) => _buildPage(
          context,
          state,
          const CountingScreen(),
        ),
      ),
      GoRoute(
        path: colorSort,
        name: 'color-sort',
        pageBuilder: (context, state) => _buildPage(
          context,
          state,
          const ColorSortScreen(),
        ),
      ),
      GoRoute(
        path: memoryFlip,
        name: 'memory-flip',
        pageBuilder: (context, state) => _buildPage(
          context,
          state,
          const MemoryFlipScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );

  static CustomTransitionPage<void> _buildPage(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0)
                .animate(CurveTween(curve: Curves.easeOutBack).animate(animation)),
            child: child,
          ),
        );
      },
    );
  }
}
