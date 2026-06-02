import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/addition_service.dart';
import '../theme.dart';
import 'play_screen.dart';

/// レベルを えらんで はじめる トップ画面。
class HomeScreen extends StatelessWidget {
  final AdditionService service;

  const HomeScreen({super.key, required this.service});

  void _start(BuildContext context, Level level) {
    Navigator.push(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text('🍎➕🍊', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              const Text(
                'たしざん',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pink,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'すきな レベルを えらんでね',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.text),
              ),
              const SizedBox(height: 28),
              for (final level in Level.values)
                _LevelCard(
                  level: level,
                  onTap: () => _start(context, level),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Level level;
  final VoidCallback onTap;

  const _LevelCard({required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: level.color, width: 3),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: level.color.withOpacity(0.35),
                blurRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(level.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: level.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: AppColors.text,
                      ),
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
