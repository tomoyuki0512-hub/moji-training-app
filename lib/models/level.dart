import 'package:flutter/material.dart';

import '../theme.dart';

/// たしざんの レベル。
///
/// 合計（こたえ）の とりうる はんい を [minSum]〜[maxSum] で あらわす。
/// オペランドは どちらも 1〜9 の 1けた。
enum Level {
  /// レベル1: 1けた ＋ 1けた で 10を こえない（こたえ 2〜10）。
  level1(
    label: 'レベル1',
    title: '10までの たしざん',
    description: '1けた ＋ 1けた で\n10より おおきく ならないよ',
    emoji: '🐣',
    color: AppColors.green,
    minSum: 2,
    maxSum: 10,
  ),

  /// レベル2: 1けた ＋ 1けた で 2けたに なる（こたえ 11〜18・くりあがり）。
  level2(
    label: 'レベル2',
    title: 'くりあがりの たしざん',
    description: '1けた ＋ 1けた で\n2けたに なるよ',
    emoji: '🐰',
    color: AppColors.purple,
    minSum: 11,
    maxSum: 18,
  );

  const Level({
    required this.label,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.minSum,
    required this.maxSum,
  });

  /// 「レベル1」などの みじかい名前。
  final String label;

  /// 内容の タイトル。
  final String title;

  /// 補足説明（子ども・保護者むけ）。
  final String description;

  /// レベルを あらわす マスコット絵文字。
  final String emoji;

  /// レベルの テーマカラー。
  final Color color;

  /// こたえ（合計）の 最小値。
  final int minSum;

  /// こたえ（合計）の 最大値。
  final int maxSum;
}
