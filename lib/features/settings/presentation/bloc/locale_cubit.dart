import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/settings_repository.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this.repository) : super(repository.loadLocale());

  final SettingsRepository repository;

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    emit(locale);
    await repository.saveLocale(locale);
  }
}
