part of 'settings_cubit.dart';

enum SettingsActionStatus { idle, working, success, failure }

class SettingsActionState extends Equatable {
  const SettingsActionState({
    this.status = SettingsActionStatus.idle,
    this.message = '',
  });

  final SettingsActionStatus status;
  final String message;

  @override
  List<Object?> get props => [status, message];
}
