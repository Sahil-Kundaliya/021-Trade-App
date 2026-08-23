import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_bloc.dart';
import 'package:zero_two_one_trade_assignment/app/connectivity/connectivity_event.dart';

void main() {
  test('starts checking and resolves online', () async {
    final service = _FakeConnectivityService(ConnectivityStatus.online);
    final bloc = ConnectivityBloc(service);

    expect(bloc.state.status, ConnectivityStatus.checking);
    bloc.add(const ConnectivityStarted());
    await _settle();

    expect(bloc.state.status, ConnectivityStatus.online);
    expect(bloc.state.hasCheckedInitially, isTrue);
    expect(service.checkCount, 1);
    await bloc.close();
    await service.dispose();
  });

  test('starts checking and resolves offline', () async {
    final service = _FakeConnectivityService(ConnectivityStatus.offline);
    final bloc = ConnectivityBloc(service);

    expect(bloc.state.status, ConnectivityStatus.checking);
    bloc.add(const ConnectivityStarted());
    await _settle();

    expect(bloc.state.isOffline, isTrue);
    expect(bloc.state.hasCheckedInitially, isTrue);
    await bloc.close();
    await service.dispose();
  });

  test('tracks online, offline and online transitions', () async {
    final service = _FakeConnectivityService(ConnectivityStatus.online);
    final bloc = ConnectivityBloc(service)..add(const ConnectivityStarted());
    await _settle();

    service.emit(ConnectivityStatus.offline);
    await _settle();
    expect(bloc.state.isOffline, isTrue);

    service.emit(ConnectivityStatus.online);
    await _settle();
    expect(bloc.state.isOnline, isTrue);

    await bloc.close();
    await service.dispose();
  });

  test('explicit retry and app resume recheck globally', () async {
    final service = _FakeConnectivityService(ConnectivityStatus.offline);
    final bloc = ConnectivityBloc(service)..add(const ConnectivityStarted());
    await _settle();

    service.next = ConnectivityStatus.online;
    bloc.add(const ConnectivityRecheckRequested());
    await _settle();
    expect(bloc.state.isOnline, isTrue);

    service.next = ConnectivityStatus.offline;
    bloc.add(const ConnectivityAppResumed());
    await _settle();
    expect(bloc.state.isOffline, isTrue);
    expect(service.checkCount, 3);

    await bloc.close();
    await service.dispose();
  });

  test('deduplicates identical status events', () async {
    final service = _FakeConnectivityService(ConnectivityStatus.online);
    final bloc = ConnectivityBloc(service)..add(const ConnectivityStarted());
    final emitted = <ConnectivityStatus>[];
    final subscription = bloc.stream.listen(
      (state) => emitted.add(state.status),
    );
    await _settle();

    service
      ..emit(ConnectivityStatus.online)
      ..emit(ConnectivityStatus.online);
    await _settle();

    expect(
      emitted.where((status) => status == ConnectivityStatus.online),
      hasLength(1),
    );
    await subscription.cancel();
    await bloc.close();
    await service.dispose();
  });
}

Future<void> _settle() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

final class _FakeConnectivityService implements ConnectivityService {
  _FakeConnectivityService(this.next);

  final StreamController<ConnectivityStatus> _controller =
      StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus next;
  int checkCount = 0;

  @override
  Stream<ConnectivityStatus> get statusStream => _controller.stream;

  @override
  Future<ConnectivityStatus> checkNow() async {
    checkCount++;
    return next;
  }

  void emit(ConnectivityStatus status) => _controller.add(status);

  @override
  Future<void> dispose() => _controller.close();
}
