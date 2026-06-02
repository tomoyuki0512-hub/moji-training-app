import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tashizan/models/level.dart';
import 'package:tashizan/services/addition_service.dart';

void main() {
  group('AdditionService', () {
    test('1ラウンドで 指定した 問題数を 生成する', () {
      final service = AdditionService(Random(1));
      final round = service.generateRound(Level.level1);
      expect(round, hasLength(AdditionService.problemsPerRound));
    });

    test('オペランドは どちらも 1〜9 の 1けた', () {
      final service = AdditionService(Random(2));
      for (final level in Level.values) {
        for (var i = 0; i < 300; i++) {
          final p = service.generateProblem(level);
          expect(p.a, inInclusiveRange(1, 9));
          expect(p.b, inInclusiveRange(1, 9));
        }
      }
    });

    test('レベル1は こたえが 2〜10（10を こえない）', () {
      final service = AdditionService(Random(3));
      for (var i = 0; i < 500; i++) {
        final p = service.generateProblem(Level.level1);
        expect(p.answer, inInclusiveRange(2, 10),
            reason: '${p.a} + ${p.b} = ${p.answer}');
      }
    });

    test('レベル2は こたえが 11〜18（2けた・くりあがり）', () {
      final service = AdditionService(Random(4));
      for (var i = 0; i < 500; i++) {
        final p = service.generateProblem(Level.level2);
        expect(p.answer, inInclusiveRange(11, 18),
            reason: '${p.a} + ${p.b} = ${p.answer}');
      }
    });

    test('選択肢は 重複のない 3つで、正解を かならず ふくみ、すべて 1以上', () {
      final service = AdditionService(Random(5));
      for (final level in Level.values) {
        for (var i = 0; i < 300; i++) {
          final p = service.generateProblem(level);
          expect(p.options, hasLength(AdditionService.optionCount));
          expect(p.options.toSet(), hasLength(AdditionService.optionCount),
              reason: '選択肢が 重複: ${p.options}');
          expect(p.options, contains(p.answer));
          expect(p.options.every((o) => o >= 1), isTrue,
              reason: '1未満の 選択肢: ${p.options}');
        }
      }
    });
  });
}
