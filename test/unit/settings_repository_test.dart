import 'package:finflow/features/settings/data/settings_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists selected locale', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SettingsRepositoryImpl(preferences);

    expect(repository.loadLocale(), const Locale('en'));

    await repository.saveLocale(const Locale('ru'));

    expect(repository.loadLocale(), const Locale('ru'));
  });
}
