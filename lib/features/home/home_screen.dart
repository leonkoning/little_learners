import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_router.dart';
import '../../app/app_theme.dart';
import '../../shared/services/audio_service.dart';
import '../../shared/services/progress_service.dart';
import '../../shared/widgets/bounce_tap.dart';
import 'widgets/world_card.dart';
import 'widgets/star_count_header.dart';
import 'widgets/settings_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _progressService = ProgressService();
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioService.playMusic('audio/music/home_theme.mp3');
  }

  @override
  void dispose() {
    _audioService.stopMusic();
    super.dispose();
  }

  final List<WorldConfig> _worlds = const [
    WorldConfig(
      id: 'letter_sound',
      title: 'Jungle Jamboree',
      subtitle: 'Letter Sounds',
      emoji: '🌿',
      color: AppTheme.jungleGreen,
      darkColor: AppTheme.jungleDark,
      route: AppRouter.letterSound,
      position: Offset(0.15, 0.12),
    ),
    WorldConfig(
      id: 'letter_match',
      title: 'Starship ABC',
      subtitle: 'Letter Match',
      emoji: '🚀',
      color: AppTheme.spacePurple,
      darkColor: AppTheme.spaceDark,
      route: AppRouter.letterMatch,
      position: Offset(0.72, 0.22),
    ),
    WorldConfig(
      id: 'counting',
      title: 'Ocean Cove',
      subtitle: 'Counting',
      emoji: '🐠',
      color: AppTheme.oceanTeal,
      darkColor: AppTheme.oceanDark,
      route: AppRouter.counting,
      position: Offset(0.42, 0.42),
    ),
    WorldConfig(
      id: 'color_sort',
      title: 'Candy Kingdom',
      subtitle: 'Sort & Match',
      emoji: '🍭',
      color: AppTheme.candyPink,
      darkColor: AppTheme.candyDark,
      route: AppRouter.colorSort,
      position: Offset(0.12, 0.65),
    ),
    WorldConfig(
      id: 'memory_flip',
      title: 'Enchanted Garden',
      subtitle: 'Memory Game',
      emoji: '🌸',
      color: AppTheme.gardenPurple,
      darkColor: AppTheme.gardenDark,
      route: AppRouter.memoryFlip,
      position: Offset(0.68, 0.68),
    ),
  ];

  void _onWorldTap(WorldConfig world) {
    if (!_progressService.isGameUnlocked(world.id)) {
      _showLockedDialog(world);
      return;
    }
    _audioService.playTap();
    context.push(world.route);
  }

  void _showLockedDialog(WorldConfig world) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          '🔒 Locked!',
          style: TextStyle(fontFamily: 'Fredoka', fontSize: 28),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Earn more ⭐ stars to unlock ${world.title}!',
          style: const TextStyle(fontFamily: 'Fredoka', fontSize: 20),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK!',
              style: TextStyle(fontFamily: 'Fredoka', fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF9C4), Color(0xFFE8F5E9), Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Little Learners',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5C3D2E),
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                        const Text(
                          'Choose your adventure!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                            color: Color(0xFF8D6E63),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                      ],
                    ),
                    Row(
                      children: [
                        StarCountHeader(
                          stars: _progressService.getTotalStars(),
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(width: 8),
                        BounceTap(
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => const SettingsDialog(),
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Color(0xFF8D6E63),
                              size: 28,
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ],
                ),
              ),

              // Adventure Map
              Expanded(
                child: Stack(
                  children: [
                    // Map background path
                    CustomPaint(
                      size: Size(size.width, double.infinity),
                      painter: _MapPathPainter(_worlds, size),
                    ),

                    // World cards positioned on map
                    ..._worlds.asMap().entries.map((entry) {
                      final i = entry.key;
                      final world = entry.value;
                      final x = world.position.dx * size.width - 70;
                      final mapHeight = size.height - 200;
                      final y = world.position.dy * mapHeight;

                      return Positioned(
                        left: x,
                        top: y,
                        child: WorldCard(
                          world: world,
                          isUnlocked: _progressService.isGameUnlocked(world.id),
                          stars: _progressService.getGameStars(world.id),
                          onTap: () => _onWorldTap(world),
                          animationDelay: i * 120,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPathPainter extends CustomPainter {
  final List<WorldConfig> worlds;
  final Size screenSize;

  _MapPathPainter(this.worlds, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD7CCC8).withAlpha(180)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (worlds.length < 2) return;

    final path = Path();
    final mapHeight = screenSize.height - 200;

    final startX = worlds[0].position.dx * screenSize.width;
    final startY = worlds[0].position.dy * mapHeight + 35;
    path.moveTo(startX, startY);

    for (int i = 1; i < worlds.length; i++) {
      final x = worlds[i].position.dx * screenSize.width;
      final y = worlds[i].position.dy * mapHeight + 35;
      final prevX = worlds[i - 1].position.dx * screenSize.width;
      final prevY = worlds[i - 1].position.dy * mapHeight + 35;
      final cpX = (prevX + x) / 2;
      final cpY = (prevY + y) / 2 - 30;
      path.quadraticBezierTo(cpX, cpY, x, y);
    }

    // Draw dashed effect
    final dashPaint = Paint()
      ..color = const Color(0xFFBCAAA4).withAlpha(160)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
    canvas.drawPath(path, dashPaint);
  }

  @override
  bool shouldRepaint(_MapPathPainter oldDelegate) => false;
}

class WorldConfig {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color darkColor;
  final String route;
  final Offset position;

  const WorldConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.darkColor,
    required this.route,
    required this.position,
  });
}
