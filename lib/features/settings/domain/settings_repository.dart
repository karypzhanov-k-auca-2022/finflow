import 'package:flutter/material.dart';

abstract interface class SettingsRepository {
  ThemeMode loadThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}
