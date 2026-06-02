import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/moji_character.dart';

/// 書き順 JSON アセットを読み込み、カテゴリごとにキャッシュする。
class StrokeRepository {
  final Map<MojiCategory, List<MojiCharacter>> _cache = {};

  /// 指定カテゴリの全文字を描き順で返す。
  Future<List<MojiCharacter>> load(MojiCategory category) async {
    final cached = _cache[category];
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(category.asset);
    final list = (jsonDecode(raw) as List)
        .map((e) => MojiCharacter.fromJson(e as Map<String, dynamic>, category))
        .toList(growable: false);
    _cache[category] = list;
    return list;
  }
}
