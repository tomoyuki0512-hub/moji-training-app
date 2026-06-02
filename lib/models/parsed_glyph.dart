import 'dart:ui' as ui;

import 'package:path_drawing/path_drawing.dart';

import 'moji_character.dart';

/// 1 画ぶんの解析済みデータ。
class ParsedStroke {
  ParsedStroke({
    required this.path,
    required this.metric,
    required this.start,
  });

  /// viewBox 座標系の [ui.Path]。
  final ui.Path path;

  /// アニメーション用の距離計測。
  final ui.PathMetric metric;

  /// 画の始点（番号を置く位置）。
  final ui.Offset start;

  double get length => metric.length;
}

/// 文字を描画・アニメーションできる形に解析したもの。
///
/// SVG パス文字列を [ui.Path] に変換し、画ごとの長さや始点を前計算する。
class ParsedGlyph {
  ParsedGlyph._({
    required this.character,
    required this.strokes,
    required this.totalLength,
  });

  final MojiCharacter character;
  final List<ParsedStroke> strokes;
  final double totalLength;

  double get viewBox => character.viewBox;

  factory ParsedGlyph.from(MojiCharacter character) {
    final strokes = <ParsedStroke>[];
    var total = 0.0;
    for (final d in character.strokePaths) {
      final path = parseSvgPathData(d);
      final metrics = path.computeMetrics().toList();
      if (metrics.isEmpty) {
        // 念のため: 長さが取れない画はスキップせず、点として扱う。
        continue;
      }
      final metric = metrics.first;
      final start = metric.getTangentForOffset(0)?.position ?? ui.Offset.zero;
      strokes.add(ParsedStroke(path: path, metric: metric, start: start));
      total += metric.length;
    }
    return ParsedGlyph._(
      character: character,
      strokes: strokes,
      totalLength: total == 0 ? 1 : total,
    );
  }
}
