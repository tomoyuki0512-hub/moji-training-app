import 'package:flutter/material.dart';

import '../theme.dart';

/// 選択肢ボタンの 見た目の 状態。
enum ChoiceState {
  /// ふつう（タップ できる）。
  normal,

  /// せいかい。
  correct,

  /// えらんで まちがえた（すこし めだたせて すぐ もとに もどす）。
  wrong,
}

/// こたえの 数を えらぶ、大きくて 丸い ボタン。
class ChoiceButton extends StatelessWidget {
  /// ボタンに 表示する 数。
  final int value;

  /// ふだんの 色（レベルや 並び順で 変える）。
  final Color color;

  /// 表示状態。
  final ChoiceState state;

  /// タップ時の コールバック。null なら 押せない。
  final VoidCallback? onPressed;

  const ChoiceButton({
    super.key,
    required this.value,
    required this.color,
    required this.state,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fill = switch (state) {
      ChoiceState.normal => color,
      ChoiceState.correct => AppColors.green,
      ChoiceState.wrong => Colors.grey.shade400,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 92,
          height: 92,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: fill.withOpacity(0.45),
                blurRadius: 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (state == ChoiceState.correct)
                const Positioned(
                  top: 4,
                  right: 6,
                  child: Text('⭐', style: TextStyle(fontSize: 20)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
