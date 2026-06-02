import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moji_tracing/models/moji_character.dart';
import 'package:moji_tracing/screens/practice_screen.dart';
import 'package:moji_tracing/services/progress_service.dart';
import 'package:moji_tracing/services/settings_service.dart';
import 'package:moji_tracing/theme.dart';
import 'package:moji_tracing/widgets/tracing_canvas.dart';
import 'package:shared_preferences/shared_preferences.dart';

// お手本は中央の横線 1 本（viewBox 0..109、y=55、x=15..94）。
const _char = MojiCharacter(
  char: 'ー',
  label: 'ー',
  key: 'TEST',
  category: MojiCategory.hiragana,
  viewBox: 109,
  strokePaths: ['M15,55 L94,55'],
);

Future<Widget> _app() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return MaterialApp(
    theme: AppTheme.light,
    home: PracticeScreen(
      characters: const [_char],
      index: 0,
      progress: ProgressService(prefs)..load(),
      settings: SettingsService(prefs),
    ),
  );
}

/// viewBox 座標 -> キャンバス内のグローバル座標。
Offset _toGlobal(Rect square, double vx, double vy) {
  final scale = square.width * 0.80 / 109;
  final origin = square.width * 0.10;
  return Offset(
    square.left + vx * scale + origin,
    square.top + vy * scale + origin,
  );
}

Future<void> _trace(WidgetTester tester, double fromX, double toX) async {
  // TracingCanvas は正方形をその領域の中央に置くので、中央正方形を求める。
  final outer = tester.getRect(find.byType(TracingCanvas));
  final side = outer.shortestSide;
  final square = Rect.fromLTWH(
    outer.left + (outer.width - side) / 2,
    outer.top + (outer.height - side) / 2,
    side,
    side,
  );
  final start = _toGlobal(square, fromX, 55);
  final end = _toGlobal(square, toX, 55);
  final g = await tester.startGesture(start);
  const steps = 24;
  for (var i = 1; i <= steps; i++) {
    await g.moveTo(Offset.lerp(start, end, i / steps)!);
  }
  await g.up();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('お手本を最後までなぞると花丸が出る', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pump();

    await _trace(tester, 15, 94); // 全体をなぞる

    expect(find.text('はなまる！'), findsOneWidget);
  });

  testWidgets('一部しかなぞらないと花丸は出ない', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pump();

    await _trace(tester, 15, 32); // 左の一部だけ

    expect(find.text('はなまる！'), findsNothing);
  });
}
