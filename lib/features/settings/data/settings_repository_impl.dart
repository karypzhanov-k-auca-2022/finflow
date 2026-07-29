import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this.preferences);
  final SharedPreferences preferences;
  static const _themeKey = 'finflow_theme_mode';
  static const _localeKey = 'finflow_locale';

  @override
  ThemeMode loadThemeMode() {
    final name = preferences.getString(_themeKey);
    return ThemeMode.values.where((item) => item.name == name).firstOrNull ??
        ThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await preferences.setString(_themeKey, mode.name);
  }

  @override
  Locale loadLocale() {
    final languageCode = preferences.getString(_localeKey);
    return Locale(languageCode == 'ru' ? 'ru' : 'en');
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    await preferences.setString(_localeKey, locale.languageCode);
  }
}
