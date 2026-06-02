import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moji_tracing/main.dart';
import 'package:moji_tracing/models/moji_character.dart';
import 'package:moji_tracing/screens/character_list_screen.dart';
import 'package:moji_tracing/services/progress_service.dart';
import 'package:moji_tracing/services/settings_service.dart';
import 'package:moji_tracing/services/stroke_repository.dart';
import 'package:moji_tracing/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 注: ウィジェットテストの isolate で重いウィジェットツリーを import した状態だと
// rootBundle のアセット読込が固まるテスト環境特有の現象があるため、画面テストでは
// アセットを読まず、手で組み立てた文字データを使う（実アプリの読込には影響しない）。
List<MojiCharacter> _sampleChars() => const [
      MojiCharacter(
        char: 'あ',
        label: 'あ',
        key: 'U+3042',
        category: MojiCategory.hiragana,
        viewBox: 109,
        strokePaths: ['M20,20 L80,80', 'M80,20 L20,80'],
      ),
      MojiCharacter(
        char: 'い',
        label: 'い',
        key: 'U+3044',
        category: MojiCategory.hiragana,
        viewBox: 109,
        strokePaths: ['M30,20 L30,80'],
      ),
    ];

Future<void> _pumpFrames(WidgetTester tester, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ホームに4つのカテゴリが出る', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MojiApp(
      repository: StrokeRepository(),
      progress: ProgressService(prefs)..load(),
      settings: SettingsService(prefs),
    ));
    await tester.pump();

    expect(find.text('ひらがな'), findsOneWidget);
    expect(find.text('カタカナ'), findsOneWidget);
    expect(find.text('ABC'), findsOneWidget);
    expect(find.text('abc'), findsOneWidget);
  });

  testWidgets('一覧から文字をえらぶと練習画面へ進める', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: CharacterListScreen(
        category: MojiCategory.hiragana,
        characters: _sampleChars(),
        progress: ProgressService(prefs)..load(),
        settings: SettingsService(prefs),
      ),
    ));
    await tester.pump();

    expect(find.text('あ'), findsOneWidget);

    await tester.tap(find.text('あ'));
    await _pumpFrames(tester);

    // 練習画面のツールバーが出ていること。
    expect(find.text('おてほん'), findsOneWidget);
    expect(find.text('かきじゅん'), findsOneWidget);
    expect(find.text('けす'), findsOneWidget);
  });
}
