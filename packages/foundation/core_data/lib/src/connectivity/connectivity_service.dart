import 'connectivity_status.dart';

abstract interface class ConnectivityService {
  Stream<ConnectivityStatus> get statusStream;

  Future<ConnectivityStatus> checkNow();

  Future<void> dispose();
}
