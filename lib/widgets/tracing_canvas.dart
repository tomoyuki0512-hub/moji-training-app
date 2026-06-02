import 'package:flutter/material.dart';

import '../models/parsed_glyph.dart';
import 'tracing_painter.dart';

/// 正方形のなぞり練習キャンバス。指のドラッグを記録し、[onPanStart] などで
/// 親（PracticeScreen）に通知する。描画は [TracingPainter] が行う。
class TracingCanvas extends StatelessWidget {
  const TracingCanvas({
    super.key,
    required this.glyph,
    required this.showGuide,
    required this.showOrder,
    required this.animation,
    required this.inkStrokes,
    required this.penColor,
    required this.penWidth,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final ParsedGlyph glyph;
  final bool showGuide;
  final bool showOrder;
  final Animation<double> animation;
  final List<List<Offset>> inkStrokes;
  final Color penColor;
  final double penWidth;
  final ValueChanged<Offset> onPanStart;
  final ValueChanged<Offset> onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: GestureDetector(
                  onPanStart: (d) => onPanStart(d.localPosition),
                  onPanUpdate: (d) => onPanUpdate(d.localPosition),
                  onPanEnd: (_) => onPanEnd(),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size.square(side),
                      painter: TracingPainter(
                        glyph: glyph,
                        showGuide: showGuide,
                        showOrder: showOrder,
                        progress: animation,
                        inkStrokes: inkStrokes,
                        penColor: penColor,
                        penWidth: penWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
