import 'package:flutter/material.dart';

abstract interface class SettingsRepository {
  ThemeMode loadThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
  Locale loadLocale();
  Future<void> saveLocale(Locale locale);
}
