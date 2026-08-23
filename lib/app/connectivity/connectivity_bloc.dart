import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_event.dart';
import 'connectivity_state.dart';

final class ConnectivityBloc
    extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc(this._service) : super(const ConnectivityState()) {
    on<ConnectivityStarted>(_onStarted);
    on<ConnectivityStatusChanged>(_onStatusChanged);
    on<ConnectivityRecheckRequested>(_onRecheck);
    on<ConnectivityAppResumed>(_onRecheck);
  }

  final ConnectivityService _service;
  StreamSubscription<ConnectivityStatus>? _subscription;
  bool _started = false;

  Future<void> _onStarted(
    ConnectivityStarted event,
    Emitter<ConnectivityState> emit,
  ) async {
    if (_started) return;
    _started = true;
    _subscription = _service.statusStream.listen(
      (status) => add(ConnectivityStatusChanged(status)),
    );
    final status = await _service.checkNow();
    add(ConnectivityStatusChanged(status));
  }

  void _onStatusChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    if (state.status == event.status && state.hasCheckedInitially) return;
    emit(state.copyWith(status: event.status, hasCheckedInitially: true));
  }

  Future<void> _onRecheck(
    ConnectivityEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    final status = await _service.checkNow();
    add(ConnectivityStatusChanged(status));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
