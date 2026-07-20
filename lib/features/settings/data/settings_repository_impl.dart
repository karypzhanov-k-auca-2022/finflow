import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this.preferences);
  final SharedPreferences preferences;
  static const _key = 'finflow_theme_mode';

  @override
  ThemeMode loadThemeMode() {
    final name = preferences.getString(_key);
    return ThemeMode.values.where((item) => item.name == name).firstOrNull ??
        ThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await preferences.setString(_key, mode.name);
  }
}
