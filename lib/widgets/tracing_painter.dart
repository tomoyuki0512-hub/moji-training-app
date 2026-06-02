import 'package:flutter/material.dart';

import '../models/parsed_glyph.dart';
import '../theme.dart';

/// なぞり練習キャンバスの描画。下から順に
/// 1) うすいガイド枠の十字線
/// 2) お手本（書き順と同じ画を薄い太線で表示, トグル可）
/// 3) 書き順アニメ（番号・部分表示・動く点, トグル可）— お手本の上をなぞる
/// 4) 子どもがなぞった線
/// を描く。お手本と書き順アニメは同じ画パスを同じ座標変換で描くので、
/// 書き順アニメは必ずお手本の上を正確になぞる。
class TracingPainter extends CustomPainter {
  TracingPainter({
    required this.glyph,
    required this.showGuide,
    required this.showOrder,
    required this.progress,
    required this.inkStrokes,
    required this.penColor,
    required this.penWidth,
  }) : super(repaint: progress);

  final ParsedGlyph glyph;
  final bool showGuide;
  final bool showOrder;

  /// 書き順アニメの進み具合（全画の長さに対する 0..1）。
  final Animation<double> progress;

  final List<List<Offset>> inkStrokes;
  final Color penColor;
  final double penWidth;

  static const double _padFactor = 0.10;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final origin = side * _padFactor;
    final content = side * (1 - 2 * _padFactor);
    final scale = content / glyph.viewBox;

    _paintGrid(canvas, side);
    if (showGuide) _paintGuide(canvas, origin, scale);
    if (showOrder) _paintStrokeOrder(canvas, origin, scale);
    _paintInk(canvas);
  }

  void _paintGrid(Canvas canvas, double side) {
    final paint = Paint()
      ..color = AppColors.text.withValues(alpha: 0.10)
      ..strokeWidth = 1.5;
    final mid = side / 2;
    _dashedLine(canvas, Offset(mid, side * 0.06), Offset(mid, side * 0.94), paint);
    _dashedLine(canvas, Offset(side * 0.06, mid), Offset(side * 0.94, mid), paint);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 7.0;
    const gap = 6.0;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var t = 0.0;
    while (t < total) {
      final start = a + dir * t;
      final end = a + dir * (t + dash).clamp(0.0, total).toDouble();
      canvas.drawLine(start, end, paint);
      t += dash + gap;
    }
  }

  /// お手本: 書き順と同じ画パスを、薄い太線で全画ぶん描く。
  /// 書き順アニメと同じ座標変換（origin/scale）を使うので完全に重なる。
  void _paintGuide(Canvas canvas, double origin, double scale) {
    canvas.save();
    canvas.translate(origin, origin);
    canvas.scale(scale);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 9
      ..color = AppColors.text.withValues(alpha: 0.18);
    for (final s in glyph.strokes) {
      canvas.drawPath(s.path, paint);
    }
    canvas.restore();
  }

  void _paintStrokeOrder(Canvas canvas, double origin, double scale) {
    canvas.save();
    canvas.translate(origin, origin);
    canvas.scale(scale);

    final donePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5
      ..color = AppColors.blue.withValues(alpha: 0.55);
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 6
      ..color = AppColors.blue;

    final target = progress.value * glyph.totalLength;
    var remaining = target;
    int activeIndex = -1;
    double activeLocal = 0;

    for (var i = 0; i < glyph.strokes.length; i++) {
      final s = glyph.strokes[i];
      if (remaining >= s.length) {
        canvas.drawPath(s.path, donePaint);
        remaining -= s.length;
      } else if (activeIndex == -1) {
        activeIndex = i;
        activeLocal = remaining.clamp(0.0, s.length).toDouble();
        final partial = s.metric.extractPath(0, activeLocal);
        canvas.drawPath(partial, activePaint);
        remaining = 0;
      }
    }

    // 動く点（今なぞっている画の先端）。
    if (activeIndex != -1) {
      final tan = glyph.strokes[activeIndex].metric.getTangentForOffset(activeLocal);
      if (tan != null) {
        canvas.drawCircle(tan.position, 5.5, Paint()..color = AppColors.orange);
      }
    }

    // 画番号: いま書いている画を最前面に、終わった画はうすく描いて、
    // 始点が重なっても今の番号が必ず見えるようにする。
    _paintNumbers(canvas, activeIndex);
    canvas.restore();
  }

  /// 画番号をアニメの進行に合わせて描く。
  /// - 終わった画: うすく（後ろ）
  /// - これから書く画: 通常（近い番号が上）
  /// - いま書いている画: オレンジで大きく最前面
  void _paintNumbers(Canvas canvas, int activeIndex) {
    final n = glyph.strokes.length;
    if (activeIndex == -1) {
      // すべて書き終わった状態: 全番号を表示（小さい番号が上）。
      for (var i = n - 1; i >= 0; i--) {
        _paintNumber(canvas, i + 1, glyph.strokes[i].start, AppColors.pink, 7);
      }
      return;
    }
    for (var i = 0; i < activeIndex; i++) {
      _paintNumber(canvas, i + 1, glyph.strokes[i].start,
          AppColors.pink.withValues(alpha: 0.30), 6);
    }
    for (var i = n - 1; i > activeIndex; i--) {
      _paintNumber(canvas, i + 1, glyph.strokes[i].start, AppColors.pink, 7);
    }
    _paintNumber(canvas, activeIndex + 1, glyph.strokes[activeIndex].start,
        AppColors.orange, 9);
  }

  void _paintNumber(Canvas canvas, int n, Offset at, Color color, double r) {
    // 白いふち: 番号が重なっても上の番号が読めるようにする。
    canvas.drawCircle(at, r + 1.6, Paint()..color = Colors.white);
    canvas.drawCircle(at, r, Paint()..color = color);
    final tp = TextPainter(
      text: TextSpan(
        text: '$n',
        style: TextStyle(
          color: Colors.white,
          fontSize: r * 1.25,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  void _paintInk(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = penWidth
      ..color = penColor;
    for (final stroke in inkStrokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, penWidth / 2, Paint()..color = penColor);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TracingPainter old) => true;
}
