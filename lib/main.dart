import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app_router.dart';
import 'app/app_theme.dart';
import 'shared/services/audio_service.dart';
import 'shared/services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation only (better for kids)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await AudioService().init();
  await ProgressService().init();

  runApp(
    const ProviderScope(
      child: LittleLearnersApp(),
    ),
  );
}

class LittleLearnersApp extends StatelessWidget {
  const LittleLearnersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Little Learners',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}
