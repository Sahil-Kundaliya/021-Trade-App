import 'package:core_data/core_data.dart';

final class ConnectivityState {
  const ConnectivityState({
    this.status = ConnectivityStatus.checking,
    this.hasCheckedInitially = false,
  });

  final ConnectivityStatus status;
  final bool hasCheckedInitially;

  bool get isOnline => status == ConnectivityStatus.online;
  bool get isOffline => status == ConnectivityStatus.offline;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    bool? hasCheckedInitially,
  }) => ConnectivityState(
    status: status ?? this.status,
    hasCheckedInitially: hasCheckedInitially ?? this.hasCheckedInitially,
  );
}
