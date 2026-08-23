import 'package:core_data/core_data.dart';

sealed class ConnectivityEvent {
  const ConnectivityEvent();
}

final class ConnectivityStarted extends ConnectivityEvent {
  const ConnectivityStarted();
}

final class ConnectivityStatusChanged extends ConnectivityEvent {
  const ConnectivityStatusChanged(this.status);

  final ConnectivityStatus status;
}

final class ConnectivityRecheckRequested extends ConnectivityEvent {
  const ConnectivityRecheckRequested();
}

final class ConnectivityAppResumed extends ConnectivityEvent {
  const ConnectivityAppResumed();
}
