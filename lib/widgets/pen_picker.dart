import 'package:flutter/material.dart';

import '../models/pen_settings.dart';
import '../theme.dart';

/// ペンの色と太さを選ぶボトムシートの中身。
///
/// シート自身が選択状態を持ち、タップで即座に見た目を更新しつつ
/// [onChanged] で親へ伝える（タップしても変化が見えない問題を防ぐ）。
class PenPicker extends StatefulWidget {
  const PenPicker({super.key, required this.pen, required this.onChanged});

  final PenSettings pen;
  final ValueChanged<PenSettings> onChanged;

  @override
  State<PenPicker> createState() => _PenPickerState();
}

class _PenPickerState extends State<PenPicker> {
  late PenSettings _pen = widget.pen;

  void _update(PenSettings p) {
    setState(() => _pen = p);
    widget.onChanged(p);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ペンのいろ',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final color in PenSettings.palette)
                _Swatch(
                  color: color,
                  selected: color.toARGB32() == _pen.color.toARGB32(),
                  onTap: () => _update(_pen.copyWith(color: color)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('ふとさ',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final w in PenSettings.widths)
                _WidthDot(
                  width: w,
                  color: _pen.color,
                  selected: w == _pen.width,
                  onTap: () => _update(_pen.copyWith(width: w)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// タップ範囲を広げた色スウォッチ（見た目の円より大きい当たり判定）。
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.text : Colors.black12,
                width: selected ? 5 : 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WidthDot extends StatelessWidget {
  const _WidthDot({
    required this.width,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 76,
        height: 72,
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.text : Colors.black12,
                width: selected ? 5 : 2,
              ),
            ),
            child: Center(
              child: Container(
                width: width,
                height: width,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
