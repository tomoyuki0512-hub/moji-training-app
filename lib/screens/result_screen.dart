import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/addition_service.dart';
import '../theme.dart';
import 'play_screen.dart';

/// 1ラウンド おわった あとの けっか画面。ほし の数で がんばりを ほめる。
class ResultScreen extends StatelessWidget {
  /// 1回で せいかいできた 問題の数（＝ ほし の数）。
  final int score;

  /// 出題数。
  final int total;

  final Level level;
  final AdditionService service;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.level,
    required this.service,
  });

  String get _message {
    if (score == total) return 'ぜんぶ せいかい！\nすごいね！';
    if (score >= total - 1) return 'よく できました！';
    if (score >= total ~/ 2) return 'がんばったね！';
    return 'もう いっかい やってみよう！';
  }

  String get _emoji {
    if (score == total) return '🏆';
    if (score >= total ~/ 2) return '🌟';
    return '🐣';
  }

  void _retry(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PlayScreen(service: service, level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_emoji, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 88)),
              const SizedBox(height: 12),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.3,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pink,
                ),
              ),
              const SizedBox(height: 24),

              // ほし の ならび。
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: [
                  for (var i = 0; i < total; i++)
                    Text(
                      i < score ? '⭐' : '☆',
                      style: const TextStyle(fontSize: 36),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$total もん中 $score もん せいかい',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.text),
              ),
              const SizedBox(height: 40),

              _BigButton(
                label: 'もういちど',
                emoji: '🔁',
                color: AppColors.green,
                onTap: () => _retry(context),
              ),
              const SizedBox(height: 14),
              _BigButton(
                label: 'おうちへ',
                emoji: '🏠',
                color: AppColors.blue,
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _BigButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.4),
              blurRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
