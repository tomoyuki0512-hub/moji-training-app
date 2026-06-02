import 'dart:async';

import 'package:flutter/material.dart';

import '../models/addition_problem.dart';
import '../models/level.dart';
import '../services/addition_service.dart';
import '../theme.dart';
import '../widgets/choice_button.dart';
import '../widgets/counting_objects.dart';
import 'result_screen.dart';

/// たしざんを 1問ずつ 出題する 画面。
///
/// 子どもむけに「まちがえても 何度でも やりなおせる」設計。せいかいで 次へ
/// すすむ。くだものを かぞえる ビジュアルと、順番に かぞえる ヒントで サポート。
class PlayScreen extends StatefulWidget {
  final AdditionService service;
  final Level level;

  const PlayScreen({super.key, required this.service, required this.level});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final List<AdditionProblem> _problems;
  int _index = 0;
  int _score = 0; // 1回で せいかいできた 問題の数（ほし の数）。

  bool _solved = false; // この問題に せいかいして 次へ うつる とちゅうか。
  bool _wrongThisProblem = false; // この問題で 1回でも まちがえたか。
  int? _wrongValue; // ちょくぜん に えらんで まちがえた 数（一時的に 強調）。
  int _counted = 0; // ヒントで かぞえ終えた 個数（0 = ヒントなし）。

  Timer? _hintTimer;
  Timer? _wrongTimer;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _problems = widget.service.generateRound(widget.level);
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _wrongTimer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  AdditionProblem get _current => _problems[_index];

  void _onChoice(int value) {
    if (_solved) return;
    if (_current.isCorrect(value)) {
      _hintTimer?.cancel();
      _wrongTimer?.cancel();
      setState(() {
        _solved = true;
        _wrongValue = null;
        if (!_wrongThisProblem) _score++;
      });
      _advanceTimer = Timer(const Duration(milliseconds: 1400), _next);
    } else {
      _wrongTimer?.cancel();
      setState(() {
        _wrongThisProblem = true;
        _wrongValue = value;
      });
      // すこし めだたせてから もとに もどし、何度でも やりなおせるように する。
      _wrongTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _wrongValue = null);
      });
    }
  }

  void _onHint() {
    if (_hintTimer != null || _solved) return;
    setState(() => _counted = 0);
    _hintTimer = Timer.periodic(const Duration(milliseconds: 550), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _counted++);
      if (_counted >= _current.answer) {
        timer.cancel();
        _hintTimer = null;
      }
    });
  }

  void _next() {
    if (!mounted) return;
    if (_index + 1 >= _problems.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: _score,
            total: _problems.length,
            level: widget.level,
            service: widget.service,
          ),
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _solved = false;
      _wrongThisProblem = false;
      _wrongValue = null;
      _counted = 0;
    });
  }

  ChoiceState _stateFor(int value) {
    if (_solved && _current.isCorrect(value)) return ChoiceState.correct;
    if (value == _wrongValue) return ChoiceState.wrong;
    return ChoiceState.normal;
  }

  ({String emoji, String text}) get _feedback {
    if (_solved) return (emoji: '🎉', text: 'せいかい！');
    if (_wrongValue != null) return (emoji: '🙂', text: 'もういちど！');
    return (emoji: widget.level.emoji, text: 'こたえは どれかな？');
  }

  @override
  Widget build(BuildContext context) {
    final problem = _current;
    final rightSide = _solved
        ? '${problem.answer}'
        : (_counted > 0 ? '$_counted' : '?');
    final countedForView = _solved ? problem.answer : _counted;
    final feedback = _feedback;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: _ProgressDots(total: _problems.length, current: _index),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              // マスコット＆ひとこと。
              Text(feedback.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 4),
              Text(
                feedback.text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _solved ? AppColors.green : AppColors.text,
                ),
              ),
              const SizedBox(height: 16),

              // しき。
              Text(
                '${problem.a} ＋ ${problem.b} ＝ $rightSide',
                style: const TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 20),

              // かぞえる ビジュアル（いつでも 見える サポート）。
              CountingObjects(
                a: problem.a,
                b: problem.b,
                counted: countedForView,
              ),
              const SizedBox(height: 16),

              // ヒント：順番に かぞえる。
              _HintButton(
                enabled: !_solved && _hintTimer == null,
                onPressed: _onHint,
              ),
              const SizedBox(height: 24),

              // 選択肢。
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 0,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < problem.options.length; i++)
                    ChoiceButton(
                      value: problem.options[i],
                      color: AppColors.choices[i % AppColors.choices.length],
                      state: _stateFor(problem.options[i]),
                      onPressed:
                          _solved ? null : () => _onChoice(problem.options[i]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 「いま 何問目か」を まる で あらわす プログレス。
class _ProgressDots extends StatelessWidget {
  final int total;
  final int current;

  const _ProgressDots({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= current ? AppColors.pink : AppColors.pink
                    // ignore: deprecated_member_use
                    .withOpacity(0.25),
              ),
            ),
          ),
      ],
    );
  }
}

/// 「かぞえてみよう」ヒントボタン。
class _HintButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _HintButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.yellow, width: 3),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🔍', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'かぞえてみよう',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
