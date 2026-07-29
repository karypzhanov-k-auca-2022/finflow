import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connection_monitor.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionStatus> {
  ConnectionCubit(this.monitor) : super(ConnectionStatus.checking) {
    _subscription = monitor.onConnectionChanged.listen(
      _setAvailability,
      onError: (_, _) => _setAvailability(false),
    );
    recheck();
  }

  final ConnectionMonitor monitor;
  late final StreamSubscription<bool> _subscription;

  Future<void> recheck() async {
    try {
      _setAvailability(await monitor.hasConnection());
    } catch (_) {
      _setAvailability(false);
    }
  }

  void _setAvailability(bool online) {
    if (isClosed) return;
    emit(online ? ConnectionStatus.online : ConnectionStatus.offline);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
