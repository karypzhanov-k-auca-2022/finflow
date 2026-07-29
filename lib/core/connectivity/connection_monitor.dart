import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectionMonitor {
  Future<bool> hasConnection();
  Stream<bool> get onConnectionChanged;
}

class ConnectivityConnectionMonitor implements ConnectionMonitor {
  ConnectivityConnectionMonitor([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  bool _isOnline(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.contains(ConnectivityResult.none);

  @override
  Future<bool> hasConnection() async =>
      _isOnline(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onConnectionChanged =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();
}
