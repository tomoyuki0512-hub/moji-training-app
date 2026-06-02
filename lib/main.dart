import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/category_screen.dart';
import 'services/progress_service.dart';
import 'services/settings_service.dart';
import 'services/stroke_repository.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final progress = ProgressService(prefs)..load();
  final settings = SettingsService(prefs);
  final repository = StrokeRepository();
  runApp(MojiApp(
    repository: repository,
    progress: progress,
    settings: settings,
  ));
}

class MojiApp extends StatelessWidget {
  const MojiApp({
    super.key,
    required this.repository,
    required this.progress,
    required this.settings,
  });

  final StrokeRepository repository;
  final ProgressService progress;
  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'なぞりがき',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: CategoryScreen(
        repository: repository,
        progress: progress,
        settings: settings,
      ),
    );
  }
}
