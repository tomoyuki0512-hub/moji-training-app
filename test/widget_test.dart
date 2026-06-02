import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tashizan/main.dart';

void main() {
  testWidgets('ホーム画面に タイトルと レベルが ひょうじされる', (WidgetTester tester) async {
    await tester.pumpWidget(const TashizanApp());

    expect(find.text('たしざん'), findsOneWidget);
    expect(find.text('レベル1'), findsOneWidget);
    expect(find.text('レベル2'), findsOneWidget);
    expect(find.text('10までの たしざん'), findsOneWidget);
    expect(find.text('くりあがりの たしざん'), findsOneWidget);
  });

  testWidgets('レベルを えらぶと たしざんが はじまる', (WidgetTester tester) async {
    await tester.pumpWidget(const TashizanApp());

    await tester.tap(find.text('レベル1'));
    await tester.pumpAndSettle();

    // しき（… ＝ ?）と ヒントボタンが でる。
    expect(find.textContaining('＝ ?'), findsOneWidget);
    expect(find.text('かぞえてみよう'), findsOneWidget);
  });
}
