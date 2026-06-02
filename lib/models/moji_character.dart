/// 練習できる文字のカテゴリ。
enum MojiCategory {
  hiragana(
    asset: 'assets/strokes/hiragana.json',
    title: 'ひらがな',
    emoji: '🌸',
  ),
  katakana(
    asset: 'assets/strokes/katakana.json',
    title: 'カタカナ',
    emoji: '🐱',
  ),
  alphabetUpper(
    asset: 'assets/strokes/alphabet_upper.json',
    title: 'ABC',
    emoji: '🐶',
  ),
  alphabetLower(
    asset: 'assets/strokes/alphabet_lower.json',
    title: 'abc',
    emoji: '⭐',
  );

  const MojiCategory({
    required this.asset,
    required this.title,
    required this.emoji,
  });

  /// JSON アセットのパス。
  final String asset;

  /// 画面に出すカテゴリ名。
  final String title;

  /// カードに添えるかわいい絵文字。
  final String emoji;
}

/// 1 文字ぶんの書き順データ。
class MojiCharacter {
  const MojiCharacter({
    required this.char,
    required this.label,
    required this.key,
    required this.category,
    required this.viewBox,
    required this.strokePaths,
  });

  /// 表示する文字（例: 'あ', 'きゃ', 'A'）。
  final String char;

  /// UI 表示用ラベル（通常 [char] と同じ）。
  final String label;

  /// 進捗保存に使う安定キー（例: 'U+3042', 'U+304D_U+3083'）。
  final String key;

  final MojiCategory category;

  /// 書き順データの座標系（正方形の一辺。KanjiVG は 109）。
  final double viewBox;

  /// 描き順どおりの SVG パス（d 属性）のリスト。
  final List<String> strokePaths;

  /// 画数。
  int get strokeCount => strokePaths.length;

  factory MojiCharacter.fromJson(
    Map<String, dynamic> json,
    MojiCategory category,
  ) {
    return MojiCharacter(
      char: json['char'] as String,
      label: (json['label'] ?? json['char']) as String,
      key: json['key'] as String,
      category: category,
      viewBox: (json['viewBox'] as num).toDouble(),
      strokePaths:
          (json['strokes'] as List).map((e) => e as String).toList(growable: false),
    );
  }
}
