import 'package:flutter/material.dart';

import '../models/moji_character.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';
import '../widgets/progress_badge.dart';
import 'practice_screen.dart';

/// あるカテゴリの文字を並べた一覧。タイルをタップすると練習画面へ。
/// 戻ってきたら進捗バッジを更新する。
class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({
    super.key,
    required this.category,
    required this.characters,
    required this.progress,
    required this.settings,
  });

  final MojiCategory category;
  final List<MojiCharacter> characters;
  final ProgressService progress;
  final SettingsService settings;

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  Future<void> _open(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticeScreen(
          characters: widget.characters,
          index: index,
          progress: widget.progress,
          settings: widget.settings,
        ),
      ),
    );
    if (mounted) setState(() {}); // 進捗バッジを更新
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Text(
          '${widget.category.emoji}  ${widget.category.title}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 110,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
          ),
          itemCount: widget.characters.length,
          itemBuilder: (context, i) {
            final c = widget.characters[i];
            final done = widget.progress.isCompleted(c.key);
            return _Tile(
              label: c.label,
              completed: done,
              onTap: () => _open(i),
            );
          },
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.completed,
    required this.onTap,
  });

  final String label;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: completed ? AppColors.pink : Colors.black12,
            width: completed ? 3 : 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 6,
              child: ProgressBadge(completed: completed),
            ),
          ],
        ),
      ),
    );
  }
}
