import 'package:flutter/material.dart';

import '../models/moji_character.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../services/stroke_repository.dart';
import '../theme.dart';
import 'character_list_screen.dart';

/// ホーム画面。練習するカテゴリ（ひらがな / カタカナ / ABC / abc）を選ぶ。
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({
    super.key,
    required this.repository,
    required this.progress,
    required this.settings,
  });

  final StrokeRepository repository;
  final ProgressService progress;
  final SettingsService settings;

  static const _colors = {
    MojiCategory.hiragana: AppColors.pink,
    MojiCategory.katakana: AppColors.blue,
    MojiCategory.alphabetUpper: AppColors.green,
    MojiCategory.alphabetLower: AppColors.orange,
  };

  Future<void> _open(BuildContext context, MojiCategory category) async {
    final characters = await repository.load(category);
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterListScreen(
          category: category,
          characters: characters,
          progress: progress,
          settings: settings,
        ),
      ),
    );
  }

  void _showCredits(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'なぞりがき',
      applicationVersion: '1.0.0',
      children: [
        const SizedBox(height: 8),
        const Text(
          'ひらがな・カタカナの書き順データは KanjiVG '
          '(© Ulrich Apel) を利用しています。\n'
          'CC BY-SA 3.0 ／ https://kanjivg.tagaini.net/',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'なぞりがき ✏️',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: AppColors.text),
                    tooltip: 'クレジット',
                    onPressed: () => _showCredits(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'すきな もじを えらんでね',
                style: TextStyle(fontSize: 16, color: AppColors.text),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    for (final category in MojiCategory.values)
                      _CategoryCard(
                        category: category,
                        color: _colors[category]!,
                        onTap: () => _open(context, category),
                      ),
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.color,
    required this.onTap,
  });

  final MojiCategory category;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 10),
            Text(
              category.title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
