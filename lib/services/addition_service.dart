import 'dart:math';

import '../models/addition_problem.dart';
import '../models/level.dart';

/// レベルに 応じて たしざんの 問題を 生成する サービス。
///
/// [Random] を 差し替えられるので、テストでは 決定的に 検証できる。
class AdditionService {
  AdditionService([Random? random]) : _random = random ?? Random();

  final Random _random;

  /// 1回（1ラウンド）で 出題する 問題数。子どもが あきないよう 少なめ。
  static const int problemsPerRound = 5;

  /// 各問題の 選択肢の数。4さいには 3つくらいが ちょうどよい。
  static const int optionCount = 3;

  /// オペランドの 最小・最大（どちらも 1けた）。
  static const int _minOperand = 1;
  static const int _maxOperand = 9;

  /// [level] の 問題を [problemsPerRound] 問 ぶん 生成する。
  List<AdditionProblem> generateRound(Level level) {
    return List.generate(problemsPerRound, (_) => generateProblem(level));
  }

  /// [level] の 問題を 1問 生成する。
  AdditionProblem generateProblem(Level level) {
    int a;
    int b;
    do {
      a = _randomOperand();
      b = _randomOperand();
    } while (a + b < level.minSum || a + b > level.maxSum);

    return AdditionProblem(
      a: a,
      b: b,
      options: _buildOptions(a + b),
    );
  }

  int _randomOperand() =>
      _minOperand + _random.nextInt(_maxOperand - _minOperand + 1);

  /// 正解を ふくむ、重複のない 選択肢を つくって シャッフルする。
  ///
  /// まちがいの 選択肢は こたえの ±1〜±3 の はんいで、1以上に なるよう えらぶ。
  List<int> _buildOptions(int answer) {
    final options = <int>{answer};
    while (options.length < optionCount) {
      final delta = 1 + _random.nextInt(3); // 1〜3
      final candidate = _random.nextBool() ? answer + delta : answer - delta;
      if (candidate >= 1) {
        options.add(candidate);
      }
    }
    return options.toList()..shuffle(_random);
  }
}
