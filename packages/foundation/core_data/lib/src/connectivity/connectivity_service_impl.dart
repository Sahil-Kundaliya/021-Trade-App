import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'connectivity_service.dart';
import 'connectivity_status.dart';

@LazySingleton(as: ConnectivityService)
final class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl()
    : this.withClients(Connectivity(), InternetConnection());

  ConnectivityServiceImpl.withClients(this._connectivity, this._internet) {
    _interfaceSubscription = _connectivity.onConnectivityChanged.listen(
      _onInterfacesChanged,
    );
  }

  static const Duration _reachabilityTimeout = Duration(seconds: 3);

  final Connectivity _connectivity;
  final InternetConnection _internet;
  final StreamController<ConnectivityStatus> _controller =
      StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _interfaceSubscription;
  ConnectivityStatus? _lastStatus;
  int _checkGeneration = 0;
  bool _disposed = false;

  @override
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  @override
  Future<ConnectivityStatus> checkNow() => _check(++_checkGeneration);

  Future<ConnectivityStatus> _check(int generation) async {
    ConnectivityStatus result;
    try {
      final interfaces = await _connectivity.checkConnectivity();
      if (!_hasNetworkInterface(interfaces)) {
        result = ConnectivityStatus.offline;
      } else {
        final reachable = await _internet.hasInternetAccess.timeout(
          _reachabilityTimeout,
          onTimeout: () => false,
        );
        result = reachable
            ? ConnectivityStatus.online
            : ConnectivityStatus.offline;
      }
    } on Object {
      result = ConnectivityStatus.offline;
    }
    if (generation != _checkGeneration) return _lastStatus ?? result;
    return _publish(result);
  }

  void _onInterfacesChanged(List<ConnectivityResult> interfaces) {
    if (_disposed) return;
    final generation = ++_checkGeneration;
    if (!_hasNetworkInterface(interfaces)) {
      _publish(ConnectivityStatus.offline);
      return;
    }
    unawaited(_check(generation));
  }

  bool _hasNetworkInterface(List<ConnectivityResult> interfaces) =>
      interfaces.isNotEmpty &&
      interfaces.any((result) => result != ConnectivityResult.none);

  ConnectivityStatus _publish(ConnectivityStatus status) {
    if (!_disposed && status != _lastStatus) {
      _lastStatus = status;
      _controller.add(status);
    }
    return status;
  }

  @override
  @disposeMethod
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _interfaceSubscription?.cancel();
    await _controller.close();
  }
}
