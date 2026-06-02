import 'package:flutter/material.dart';

import '../models/moji_character.dart';
import '../models/parsed_glyph.dart';
import '../models/pen_settings.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../theme.dart';
import '../widgets/hanamaru_overlay.dart';
import '../widgets/pen_picker.dart';
import '../widgets/practice_toolbar.dart';
import '../widgets/tracing_canvas.dart';

/// 1 文字をなぞって練習する画面。状態（お手本/書き順トグル・ペン・なぞり線・
/// 書き順アニメ）の中心。
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.characters,
    required this.index,
    required this.progress,
    required this.settings,
  });

  final List<MojiCharacter> characters;
  final int index;
  final ProgressService progress;
  final SettingsService settings;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orderCtrl =
      AnimationController(vsync: this);

  late int _index;
  late ParsedGlyph _glyph;
  late PenSettings _pen;

  bool _showGuide = true;
  bool _showOrder = true;
  bool _completed = false;
  final List<List<Offset>> _ink = [];

  /// お手本（書き順パス）上のサンプル点（viewBox 座標）。なぞりが覆った割合で
  /// 完了を判定するために使う。
  List<Offset> _guideSamples = const [];

  MojiCharacter get _char => widget.characters[_index];
  bool get _hasNext => _index < widget.characters.length - 1;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _pen = widget.settings.load();
    _loadChar();
  }

  @override
  void dispose() {
    _orderCtrl.dispose();
    super.dispose();
  }

  void _loadChar() {
    _glyph = ParsedGlyph.from(_char);
    _guideSamples = _sampleGuide(_glyph);
    _ink.clear();
    _completed = false;
    _orderCtrl.duration = Duration(
      // なぞるスピードは duration で決まる（長いほどゆっくり）。
      // 以前の半分の速さにするため係数と上下限を 2 倍にしている。
      milliseconds: (_glyph.totalLength * 10).clamp(2400, 10000).round(),
    );
    if (_showOrder) {
      _orderCtrl.forward(from: 0);
    } else {
      _orderCtrl.value = 1;
    }
  }

  void _onPanStart(Offset p) {
    if (_completed) return;
    setState(() => _ink.add([p]));
  }

  void _onPanUpdate(Offset p) {
    if (_completed || _ink.isEmpty) return;
    setState(() => _ink.last.add(p));
  }

  /// お手本パスに沿ってサンプル点を打つ（viewBox 座標, 約 3 単位間隔）。
  List<Offset> _sampleGuide(ParsedGlyph glyph) {
    const step = 3.0;
    final pts = <Offset>[];
    for (final s in glyph.strokes) {
      final len = s.metric.length;
      for (var d = 0.0; d <= len; d += step) {
        final t = s.metric.getTangentForOffset(d);
        if (t != null) pts.add(t.position);
      }
    }
    return pts;
  }

  void _onPanEnd(double canvasSide) {
    if (_completed || _guideSamples.isEmpty || canvasSide <= 0) return;
    // viewBox -> キャンバス座標への換算（お手本と同じ origin/scale）。
    final scale = canvasSide * 0.80 / _glyph.viewBox;
    final origin = canvasSide * 0.10;
    final radius = canvasSide * 0.085; // 線からの許容ずれ
    final r2 = radius * radius;

    var covered = 0;
    for (final g in _guideSamples) {
      final gx = g.dx * scale + origin;
      final gy = g.dy * scale + origin;
      var hit = false;
      for (final stroke in _ink) {
        for (final p in stroke) {
          final dx = p.dx - gx, dy = p.dy - gy;
          if (dx * dx + dy * dy <= r2) {
            hit = true;
            break;
          }
        }
        if (hit) break;
      }
      if (hit) covered++;
    }

    // 線の本数や長さではなく「お手本の上を実際にどれだけ覆えたか」で判定する。
    // 一部しか書いていなければ覆えないので、途中で誤クリアにならない。
    if (covered / _guideSamples.length >= 0.7) {
      _complete();
    }
  }

  Future<void> _complete() async {
    setState(() => _completed = true);
    await widget.progress.markCompleted(_char.key);
    if (mounted) setState(() {});
  }

  void _clear() {
    setState(() {
      _ink.clear();
      _completed = false;
    });
  }

  void _toggleGuide() => setState(() => _showGuide = !_showGuide);

  void _toggleOrder() {
    setState(() => _showOrder = !_showOrder);
    if (_showOrder) {
      _orderCtrl.forward(from: 0);
    } else {
      _orderCtrl.stop();
    }
  }

  void _replayOrder() {
    setState(() => _showOrder = true);
    _orderCtrl.forward(from: 0);
  }

  Future<void> _pickPen() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PenPicker(
        pen: _pen,
        onChanged: (p) {
          setState(() => _pen = p);
          widget.settings.save(p);
        },
      ),
    );
  }

  void _retry() {
    _clear();
    _replayOrder();
  }

  void _next() {
    if (!_hasNext) return;
    setState(() => _index++);
    _loadChar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _char.label,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            color: AppColors.text,
            tooltip: 'いちらん',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TracingCanvas(
                      glyph: _glyph,
                      showGuide: _showGuide,
                      showOrder: _showOrder,
                      animation: _orderCtrl,
                      inkStrokes: _ink,
                      penColor: _pen.color,
                      penWidth: _pen.width,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: PracticeToolbar(
                    showGuide: _showGuide,
                    showOrder: _showOrder,
                    onToggleGuide: _toggleGuide,
                    onToggleOrder: _toggleOrder,
                    onReplayOrder: _replayOrder,
                    onClear: _clear,
                    onPickPen: _pickPen,
                    penColor: _pen.color,
                  ),
                ),
              ],
            ),
            if (_completed)
              HanamaruOverlay(
                stars: widget.progress.starCount(_char.key),
                hasNext: _hasNext,
                onRetry: _retry,
                onNext: _next,
                onList: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}
