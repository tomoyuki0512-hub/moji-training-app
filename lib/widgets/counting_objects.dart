import 'package:flutter/material.dart';

import '../theme.dart';

/// かぞえて こたえを みつける ための、目に見える サポート。
///
/// 左の数だけ 🍎、右の数だけ 🍊 を ならべる。[counted] は ヒントで
/// 「いま いくつまで かぞえたか」を あらわし、その数だけ 手前の くだものに
/// 黄色い わっか を つけて 強調する（0 のときは 強調しない）。
class CountingObjects extends StatelessWidget {
  /// 左の オペランド（🍎 の数）。
  final int a;

  /// 右の オペランド（🍊 の数）。
  final int b;

  /// ヒントで かぞえ終えた 個数（0〜a+b）。
  final int counted;

  const CountingObjects({
    super.key,
    required this.a,
    required this.b,
    this.counted = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        _group(start: 0, count: a, bgColor: AppColors.pink, emoji: '🍎'),
        const Text(
          '＋',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        _group(start: a, count: b, bgColor: AppColors.orange, emoji: '🍊'),
      ],
    );
  }

  Widget _group({
    required int start,
    required int count,
    required Color bgColor,
    required String emoji,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: bgColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            _Fruit(
              emoji: emoji,
              highlighted: counted > 0 && (start + i) < counted,
              dimmed: counted > 0 && (start + i) >= counted,
            ),
        ],
      ),
    );
  }
}

class _Fruit extends StatelessWidget {
  final String emoji;
  final bool highlighted;
  final bool dimmed;

  const _Fruit({
    required this.emoji,
    required this.highlighted,
    required this.dimmed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: highlighted ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedOpacity(
        opacity: dimmed ? 0.35 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: highlighted ? AppColors.yellow : Colors.transparent,
            border: highlighted
                ? Border.all(color: AppColors.orange, width: 2)
                : null,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
