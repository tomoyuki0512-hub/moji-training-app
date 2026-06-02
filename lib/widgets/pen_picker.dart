import 'package:flutter/material.dart';

import '../models/pen_settings.dart';
import '../theme.dart';

/// ペンの色と太さを選ぶボトムシートの中身。
class PenPicker extends StatelessWidget {
  const PenPicker({super.key, required this.pen, required this.onChanged});

  final PenSettings pen;
  final ValueChanged<PenSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ペンのいろ',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final color in PenSettings.palette)
                _Swatch(
                  color: color,
                  selected: color.toARGB32() == pen.color.toARGB32(),
                  onTap: () => onChanged(pen.copyWith(color: color)),
                ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('ふとさ',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text)),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final w in PenSettings.widths)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _WidthDot(
                    width: w,
                    color: pen.color,
                    selected: w == pen.width,
                    onTap: () => onChanged(pen.copyWith(width: w)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

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
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.text : Colors.transparent,
            width: 4,
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
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.text : Colors.black12,
            width: selected ? 4 : 2,
          ),
        ),
        child: Center(
          child: Container(
            width: width,
            height: width,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
