import 'package:flutter_test/flutter_test.dart';
import 'package:moji_tracing/models/moji_character.dart';
import 'package:moji_tracing/models/parsed_glyph.dart';
import 'package:moji_tracing/services/stroke_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repo = StrokeRepository();

  for (final category in MojiCategory.values) {
    test('${category.name} の書き順データが正しく読み込める', () async {
      final chars = await repo.load(category);

      expect(chars, isNotEmpty, reason: '${category.name} が空');

      final keys = <String>{};
      for (final c in chars) {
        expect(c.strokePaths, isNotEmpty, reason: '${c.char} に画がない');
        expect(keys.contains(c.key), isFalse, reason: 'キー重複: ${c.key}');
        keys.add(c.key);

        // すべての画が ui.Path に解析でき、長さを持つこと。
        final glyph = ParsedGlyph.from(c);
        expect(glyph.strokes, isNotEmpty, reason: '${c.char} の解析結果が空');
        expect(glyph.totalLength, greaterThan(0));
      }
    });
  }

  test('基本のひらがなが含まれている', () async {
    final chars = await repo.load(MojiCategory.hiragana);
    final labels = chars.map((c) => c.char).toSet();
    expect(labels.contains('あ'), isTrue);
    expect(labels.contains('ん'), isTrue);
    expect(labels.contains('が'), isTrue); // だくてん
    expect(labels.contains('ぱ'), isTrue); // 半だくてん
    expect(labels.contains('きゃ'), isTrue); // 拗音
  });
}
