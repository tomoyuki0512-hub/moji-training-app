/// たしざん 1問分の 出題内容。
class AdditionProblem {
  /// 左の オペランド（1〜9）。
  final int a;

  /// 右の オペランド（1〜9）。
  final int b;

  /// 表示順に ならんだ 選択肢。かならず [answer] を ふくむ。
  final List<int> options;

  const AdditionProblem({
    required this.a,
    required this.b,
    required this.options,
  });

  /// こたえ（a ＋ b）。
  int get answer => a + b;

  /// 指定した 値が こたえと 一致するか。
  bool isCorrect(int value) => value == answer;
}
