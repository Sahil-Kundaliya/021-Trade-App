import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/mappers/fund_chart_mapper.dart';
import '../../../domain/entities/option_chain.dart';
import '../../../domain/repositories/option_chain_repository.dart';
import 'option_chain_state.dart';

@injectable
class OptionChainBloc extends Bloc<OptionChainEvent, OptionChainState> {
  OptionChainBloc(this._repository, this._livePrices)
    : super(const OptionChainState()) {
    on<OptionChainStarted>(_onStarted);
    on<OptionChainExpiryChanged>(_onExpiryChanged);
    on<OptionChainLivePricesReceived>(_onLivePrices);
    on<OptionChainRetryRequested>(_onRetry);
    on<OptionChainStreamFailed>(_onStreamFailed);
  }

  final OptionChainRepository _repository;
  final LivePriceStreamManager _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _subscription;
  LiveInstrumentSeed? _underlyingSeed;
  List<OptionContract> _allContracts = const [];

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _onStarted(
    OptionChainStarted event,
    Emitter<OptionChainState> emit,
  ) async {
    emit(
      OptionChainState(
        status: OptionChainStatus.loading,
        underlyingSymbol: event.underlyingSymbol,
        exchange: event.exchange,
        selectedStrikeMinor: event.selectedStrikeMinor,
      ),
    );
    await _load(emit);
  }

  Future<void> _onRetry(
    OptionChainRetryRequested event,
    Emitter<OptionChainState> emit,
  ) async {
    if (state.underlyingSymbol.isEmpty) return;
    emit(state.copyWith(status: OptionChainStatus.loading, clearError: true));
    await _load(emit);
  }

  Future<void> _onExpiryChanged(
    OptionChainExpiryChanged event,
    Emitter<OptionChainState> emit,
  ) async {
    if (state.status != OptionChainStatus.loaded) return;
    emit(_rebuild(expiry: event.expiry));
    await _syncLease();
  }

  void _onStreamFailed(
    OptionChainStreamFailed event,
    Emitter<OptionChainState> emit,
  ) {
    if (state.status == OptionChainStatus.loaded) {
      emit(state.copyWith(liveUnavailable: true));
    }
  }

  void _onLivePrices(
    OptionChainLivePricesReceived event,
    Emitter<OptionChainState> emit,
  ) {
    if (state.status != OptionChainStatus.loaded) return;
    final livePrices = LivePriceTick.merge(
      state.livePrices,
      event.batch.updates,
    );
    var underlyingLtp = state.underlyingLtpMinor;
    var spotChanged = false;
    for (final tick in event.batch.updates) {
      if (_underlyingSeed != null &&
          tick.instrumentId == _underlyingSeed!.instrumentId &&
          underlyingLtp != tick.ltpMinor) {
        underlyingLtp = tick.ltpMinor;
        spotChanged = true;
      }
    }
    if (!spotChanged && identical(livePrices, state.livePrices)) return;
    if (spotChanged) {
      emit(_rebuild(spotMinor: underlyingLtp, livePrices: livePrices));
      return;
    }
    emit(state.copyWith(livePrices: livePrices));
  }

  Future<void> _load(Emitter<OptionChainState> emit) async {
    try {
      final result = await _repository.getOptionChain(
        underlyingSymbol: state.underlyingSymbol,
        exchange: state.exchange,
        selectedStrikeMinor: state.selectedStrikeMinor,
      );
      _allContracts = result.allContracts;
      final underlying = result.underlying;
      _underlyingSeed = underlying == null
          ? null
          : OptionChainMapper.equitySeed(
              dto: underlying,
              exchange: state.exchange,
            );
      final cachedSpot = _underlyingSeed == null
          ? null
          : _livePrices.latestFor(_underlyingSeed!.instrumentId);
      final spotMinor =
          cachedSpot?.ltpMinor ??
          (underlying == null ? null : (underlying.ltp * 100).round());
      emit(
        _rebuild(
          status: OptionChainStatus.loaded,
          expiry: result.snapshot.selectedExpiry,
          spotMinor: spotMinor,
          availableExpiries: result.snapshot.availableExpiries,
          nearestFuture: result.snapshot.nearestFuture,
        ),
      );
      await _syncLease();
    } on Object {
      emit(
        state.copyWith(
          status: OptionChainStatus.error,
          errorMessage: 'Unable to load option chain',
        ),
      );
    }
  }

  OptionChainState _rebuild({
    OptionChainStatus? status,
    DateTime? expiry,
    int? spotMinor,
    List<DateTime>? availableExpiries,
    FutureOverview? nearestFuture,
    Map<String, LivePriceTick>? livePrices,
  }) {
    final selectedExpiry = expiry ?? state.selectedExpiry;
    final spot = spotMinor ?? state.underlyingLtpMinor;
    final rows = selectedExpiry == null
        ? const <OptionChainRow>[]
        : OptionChainAssembler.rows(
            contracts: _allContracts,
            expiry: selectedExpiry,
            spotMinor: spot,
            selectedStrikeMinor: state.selectedStrikeMinor,
          );
    final visible = [
      for (final contract in _allContracts)
        if (selectedExpiry != null &&
            OptionChainAssembler.sameDay(contract.expiry, selectedExpiry))
          contract,
    ];
    return state.copyWith(
      status: status ?? OptionChainStatus.loaded,
      availableExpiries: availableExpiries ?? state.availableExpiries,
      selectedExpiry: selectedExpiry,
      rows: rows,
      contracts: visible,
      underlyingLtpMinor: spot,
      atmStrikeMinor: OptionChainAssembler.atmStrikeMinor(
        strikes: rows.map((row) => row.strikeMinor),
        spotMinor: spot ?? 0,
      ),
      nearestFuture: nearestFuture ?? state.nearestFuture,
      livePrices: livePrices ?? state.livePrices,
      liveUnavailable: false,
      clearError: true,
    );
  }

  Future<void> _syncLease() async {
    final seeds = <LiveInstrumentSeed>[
      ?_underlyingSeed,
      for (final contract in state.contracts)
        OptionChainMapper.seedFor(contract),
    ];
    if (seeds.isEmpty) return;
    if (_lease == null) {
      final acquired = _livePrices.acquire(instruments: seeds);
      _lease = acquired;
      _subscription = acquired.stream.listen(
        (batch) => add(OptionChainLivePricesReceived(batch)),
        onError: (_) => add(const OptionChainStreamFailed()),
      );
      return;
    }
    await _lease!.update(seeds);
  }
}
