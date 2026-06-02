import 'package:flutter/material.dart';

import '../theme.dart';

/// 練習画面のツールバー。お手本・書き順のトグル、もう一度見せる（再生）、
/// クリア、ペン選択をワンタッチのボタンで並べる。
class PracticeToolbar extends StatelessWidget {
  const PracticeToolbar({
    super.key,
    required this.showGuide,
    required this.showOrder,
    required this.onToggleGuide,
    required this.onToggleOrder,
    required this.onReplayOrder,
    required this.onClear,
    required this.onPickPen,
    required this.penColor,
  });

  final bool showGuide;
  final bool showOrder;
  final VoidCallback onToggleGuide;
  final VoidCallback onToggleOrder;
  final VoidCallback onReplayOrder;
  final VoidCallback onClear;
  final VoidCallback onPickPen;
  final Color penColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _ToolButton(
          icon: Icons.text_fields,
          label: 'おてほん',
          active: showGuide,
          color: AppColors.green,
          onTap: onToggleGuide,
        ),
        _ToolButton(
          icon: Icons.format_list_numbered,
          label: 'かきじゅん',
          active: showOrder,
          color: AppColors.purple,
          onTap: onToggleOrder,
        ),
        _ToolButton(
          icon: Icons.play_circle_outline,
          label: 'もういちど みる',
          active: false,
          color: AppColors.orange,
          onTap: onReplayOrder,
        ),
        _ToolButton(
          icon: Icons.cleaning_services_outlined,
          label: 'けす',
          active: false,
          color: AppColors.pink,
          onTap: onClear,
        ),
        _ToolButton(
          icon: Icons.brush,
          label: 'ペン',
          active: false,
          color: penColor,
          onTap: onPickPen,
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: active ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : color,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
