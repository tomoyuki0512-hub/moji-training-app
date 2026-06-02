import 'package:flutter/material.dart';

/// アプリ全体で使う、やわらかくて かわいい 配色。
class AppColors {
  AppColors._();

  /// 背景のクリーム色。
  static const cream = Color(0xFFFFF7E8);

  /// メインのピンク。
  static const pink = Color(0xFFFF8FAB);

  /// そら色。
  static const blue = Color(0xFF67C7F2);

  /// わかば色。
  static const green = Color(0xFF8BD17C);

  /// みかん色。
  static const orange = Color(0xFFFFB454);

  /// すみれ色。
  static const purple = Color(0xFFB89BFF);

  /// たまご色（アクセント）。
  static const yellow = Color(0xFFFFD95A);

  /// 文字色（こげ茶でやさしい印象に）。
  static const text = Color(0xFF6B5444);

  /// 選択肢ボタンに順番に割り当てる色。
  static const choices = <Color>[pink, blue, green, orange];
}

/// アプリのテーマ。丸くて大きい、子ども向けの見た目にする。
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.pink,
        primary: AppColors.pink,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
  }
}
