import 'package:flutter_test/flutter_test.dart';
import 'package:moji_tracing/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProgressService> newService() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return ProgressService(prefs)..load();
  }

  test('クリアと花丸が記録される', () async {
    final s = await newService();
    expect(s.isCompleted('U+3042'), isFalse);
    expect(s.starCount('U+3042'), 0);

    await s.markCompleted('U+3042');
    expect(s.isCompleted('U+3042'), isTrue);
    expect(s.starCount('U+3042'), 1);

    await s.markCompleted('U+3042');
    expect(s.starCount('U+3042'), 2);
  });

  test('保存した進捗が読み込み直せる', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final s1 = ProgressService(prefs)..load();
    await s1.markCompleted('U+3044');

    final s2 = ProgressService(prefs)..load();
    expect(s2.isCompleted('U+3044'), isTrue);
    expect(s2.starCount('U+3044'), 1);
  });

  test('リセットで全部消える', () async {
    final s = await newService();
    await s.markCompleted('U+3042');
    await s.resetAll();
    expect(s.isCompleted('U+3042'), isFalse);
    expect(s.starCount('U+3042'), 0);
  });
}
