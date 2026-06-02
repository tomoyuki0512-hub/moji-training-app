import 'package:flutter/material.dart';

import '../theme.dart';

/// なぞる線のペン設定（色と太さ）。
@immutable
class PenSettings {
  const PenSettings({required this.color, required this.width});

  final Color color;
  final double width;

  /// 選べるペンの色。
  static const List<Color> palette = <Color>[
    AppColors.text,
    AppColors.pink,
    AppColors.blue,
    AppColors.green,
    AppColors.orange,
    AppColors.purple,
  ];

  /// 選べる太さ（細・中・太）。
  static const List<double> widths = <double>[10, 16, 24];

  static const PenSettings initial = PenSettings(color: AppColors.blue, width: 16);

  PenSettings copyWith({Color? color, double? width}) {
    return PenSettings(color: color ?? this.color, width: width ?? this.width);
  }
}
