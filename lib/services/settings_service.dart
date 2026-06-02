import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pen_settings.dart';

/// ペンの色・太さを端末に保存する。
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _colorKey = 'pen.color';
  static const _widthKey = 'pen.width';

  PenSettings load() {
    final colorValue = _prefs.getInt(_colorKey);
    final width = _prefs.getDouble(_widthKey);
    return PenSettings(
      color: colorValue != null ? Color(colorValue) : PenSettings.initial.color,
      width: width ?? PenSettings.initial.width,
    );
  }

  Future<void> save(PenSettings pen) async {
    await _prefs.setInt(_colorKey, pen.color.toARGB32());
    await _prefs.setDouble(_widthKey, pen.width);
  }
}
