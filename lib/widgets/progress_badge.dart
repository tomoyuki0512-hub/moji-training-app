import 'package:flutter/material.dart';

/// 一覧タイルの隅に出す、クリア済みを示す花丸バッジ。
class ProgressBadge extends StatelessWidget {
  const ProgressBadge({super.key, required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    if (!completed) return const SizedBox.shrink();
    return const Text('💮', style: TextStyle(fontSize: 18));
  }
}
