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

  // 1 本ぶんの線の長さ（px）。
  double _strokeLength(List<Offset> s) {
    var len = 0.0;
    for (var i = 1; i < s.length; i++) {
      len += (s[i] - s[i - 1]).distance;
    }
    return len;
  }

  void _onPanEnd(double canvasSide) {
    if (_completed) return;
    // お手本（書き順パス）の画面上の長さ。お手本は viewBox を
    // side*(1-2*0.10) に収めて描いているので、その比率で換算する。
    final guideLenPx =
        _glyph.totalLength * (canvasSide * 0.80) / _glyph.viewBox;
    if (guideLenPx <= 0) return;
    // 短いタッチ（手のひら・置き指・点）は無視して、なぞった合計長を測る。
    var inkLen = 0.0;
    for (final s in _ink) {
      final l = _strokeLength(s);
      if (l > canvasSide * 0.03) inkLen += l;
    }
    // 線の本数ではなく「お手本の 6 割くらいなぞれたか」で判定する。
    // これで iPad の細かいタッチで途中クリアにならない。
    if (inkLen >= guideLenPx * 0.6) {
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
