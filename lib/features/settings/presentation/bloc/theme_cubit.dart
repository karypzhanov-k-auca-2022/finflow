import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/settings_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this.repository) : super(repository.loadThemeMode());
  final SettingsRepository repository;
  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await repository.saveThemeMode(mode);
  }
}
