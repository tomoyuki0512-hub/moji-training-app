import 'package:flutter/material.dart';

import '../models/parsed_glyph.dart';
import 'tracing_painter.dart';

/// 正方形のなぞり練習キャンバス。
///
/// 描画入力は [Listener]（生のポインタ）で受ける。GestureDetector のパンと違い
/// 「少し動かさないと始まらない」しきい値が無いので、触れた瞬間から滑らかに
/// 描ける。指は1本だけ追跡し、手のひらなど2本目以降は無視する。
class TracingCanvas extends StatefulWidget {
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

  /// なぞり終わりを通知する。引数はキャンバスの一辺(px)で、完了判定に使う。
  final ValueChanged<double> onPanEnd;

  @override
  State<TracingCanvas> createState() => _TracingCanvasState();
}

class _TracingCanvasState extends State<TracingCanvas> {
  /// いま描いているポインタ。2本目以降（手のひら等）は無視する。
  int? _activePointer;
  double _side = 0;

  void _down(PointerDownEvent e) {
    if (_activePointer != null) return;
    _activePointer = e.pointer;
    widget.onPanStart(e.localPosition);
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _activePointer) return;
    widget.onPanUpdate(e.localPosition);
  }

  void _end(PointerEvent e) {
    if (e.pointer != _activePointer) return;
    _activePointer = null;
    widget.onPanEnd(_side);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _side = constraints.biggest.shortestSide;
        return Center(
          child: SizedBox(
            width: _side,
            height: _side,
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
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _down,
                  onPointerMove: _move,
                  onPointerUp: _end,
                  onPointerCancel: _end,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size.square(_side),
                      painter: TracingPainter(
                        glyph: widget.glyph,
                        showGuide: widget.showGuide,
                        showOrder: widget.showOrder,
                        progress: widget.animation,
                        inkStrokes: widget.inkStrokes,
                        penColor: widget.penColor,
                        penWidth: widget.penWidth,
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
