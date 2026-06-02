import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 練習の進捗（クリアした文字・花丸の数）を端末に保存する。
class ProgressService {
  ProgressService(this._prefs);

  final SharedPreferences _prefs;

  static const _completedKey = 'progress.completed';
  static const _starsKey = 'progress.stars';

  Set<String> _completed = {};
  Map<String, int> _stars = {};

  /// 起動時に呼んで保存済みデータを読み込む。
  void load() {
    _completed = _prefs.getStringList(_completedKey)?.toSet() ?? <String>{};
    final raw = _prefs.getString(_starsKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _stars = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } else {
      _stars = {};
    }
  }

  bool isCompleted(String key) => _completed.contains(key);

  int starCount(String key) => _stars[key] ?? 0;

  /// クリア記録と花丸を 1 つ追加する。
  Future<void> markCompleted(String key) async {
    _completed.add(key);
    _stars[key] = (_stars[key] ?? 0) + 1;
    await _prefs.setStringList(_completedKey, _completed.toList());
    await _prefs.setString(_starsKey, jsonEncode(_stars));
  }

  /// すべての進捗を消す。
  Future<void> resetAll() async {
    _completed.clear();
    _stars.clear();
    await _prefs.remove(_completedKey);
    await _prefs.remove(_starsKey);
  }
}
