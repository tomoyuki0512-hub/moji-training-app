import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moji_tracing/models/pen_settings.dart';
import 'package:moji_tracing/widgets/pen_picker.dart';

void main() {
  testWidgets('ペンの太さをタップすると onChanged が呼ばれる', (tester) async {
    PenSettings? changed;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PenPicker(
          pen: const PenSettings(color: Color(0xFF67C7F2), width: 10),
          onChanged: (p) => changed = p,
        ),
      ),
    ));

    // 一番太い線（widths の最後）をタップ。
    final target = PenSettings.widths.last;

    // 当たり判定を広げた選択肢（color 6 + width 3）。末尾 = 最も太い太さ。
    final dots = find.byWidgetPredicate((w) =>
        w is GestureDetector && w.behavior == HitTestBehavior.opaque);
    expect(dots, findsWidgets);
    await tester.tap(dots.last);
    await tester.pump();

    expect(changed, isNotNull);
    expect(changed!.width, target);
  });
}
