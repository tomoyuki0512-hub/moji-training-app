import 'package:flutter/material.dart';

import '../theme.dart';

/// 文字を書けたときの「はなまる」お祝い演出。
///
/// 半透明の背景に大きな 💮 とスター、メッセージを出し、
/// 「もういちど / つぎ / いちらん」のボタンを見せる。
class HanamaruOverlay extends StatefulWidget {
  const HanamaruOverlay({
    super.key,
    required this.stars,
    required this.onRetry,
    required this.onNext,
    required this.onList,
    required this.hasNext,
  });

  /// この文字でもらった花丸の数（スター表示に使う）。
  final int stars;
  final VoidCallback onRetry;
  final VoidCallback onNext;
  final VoidCallback onList;
  final bool hasNext;

  @override
  State<HanamaruOverlay> createState() => _HanamaruOverlayState();
}

class _HanamaruOverlayState extends State<HanamaruOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _pop = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.elasticOut,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shownStars = widget.stars.clamp(1, 3);
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: ScaleTransition(
          scale: _pop,
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💮', style: TextStyle(fontSize: 88)),
                const SizedBox(height: 8),
                const Text(
                  'はなまる！',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pink,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Text(
                      i < shownStars ? '⭐' : '☆',
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _Btn(
                      label: 'もういちど',
                      color: AppColors.green,
                      onTap: widget.onRetry,
                    ),
                    if (widget.hasNext)
                      _Btn(
                        label: 'つぎ',
                        color: AppColors.orange,
                        onTap: widget.onNext,
                      ),
                    _Btn(
                      label: 'いちらん',
                      color: AppColors.blue,
                      onTap: widget.onList,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
