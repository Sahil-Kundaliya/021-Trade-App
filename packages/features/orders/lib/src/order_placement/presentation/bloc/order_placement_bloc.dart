import 'dart:async';
import 'dart:math' as math;

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../domain/enums/order_enums.dart';
import '../../domain/entities/order_draft.dart';
import '../../domain/entities/order_instrument.dart';
import '../../domain/repositories/order_placement_repository.dart';
import 'order_placement_event.dart';
import 'order_placement_state.dart';

@injectable
class OrderPlacementBloc
    extends Bloc<OrderPlacementEvent, OrderPlacementState> {
  OrderPlacementBloc(this._repository, [this._livePrices])
    : super(const OrderPlacementState()) {
    on<OrderPlacementStarted>(_start);
    on<OrderSideChanged>((event, emit) {
      final next = state.copyWith(side: event.side);
      _edit(emit, next);
      final error = _sellQuantityError(next);
      if (error != null) {
        emit(next.copyWith(fieldErrors: {'quantity': error}));
      }
    });
    on<OrderExchangeChanged>(_exchangeChanged);
    on<OrderQuantityIncremented>(
      (_, emit) => _changeQuantity(
        emit,
        state.quantity + (state.instrument?.quantityStep ?? 1),
      ),
    );
    on<OrderQuantityDecremented>(
      (_, emit) => _changeQuantity(
        emit,
        math.max(
          state.instrument?.quantityStep ?? 1,
          state.quantity - (state.instrument?.quantityStep ?? 1),
        ),
      ),
    );
    on<OrderQuantityChanged>(
      (event, emit) => _changeQuantity(emit, int.tryParse(event.value) ?? 0),
    );
    on<OrderTypeChanged>(
      (event, emit) => _edit(emit, state.copyWith(orderType: event.orderType)),
    );
    on<OrderLimitPriceChanged>((event, emit) {
      final value = double.tryParse(event.value);
      _edit(
        emit,
        state.copyWith(limitPrice: value, clearLimitPrice: value == null),
      );
    });
    on<OrderTriggerPriceChanged>((event, emit) {
      final value = double.tryParse(event.value);
      _edit(
        emit,
        state.copyWith(triggerPrice: value, clearTriggerPrice: value == null),
      );
    });
    on<OrderProductChanged>(_productChanged);
    on<OrderValidityChanged>(
      (event, emit) => _edit(emit, state.copyWith(validity: event.validity)),
    );
    on<OrderReviewRequested>(_review);
    on<OrderReviewCancelled>(
      (_, emit) => emit(
        state.copyWith(status: OrderPlacementStatus.ready, clearError: true),
      ),
    );
    on<OrderPlacementConfirmed>(_confirm);
    on<OrderPlacementRetryRequested>(_confirm);
    on<OrderLivePricesReceived>(_onLivePrices);
    on<OrderPositionAvailabilityChanged>(_refreshAvailability);
  }

  final OrderPlacementRepository _repository;
  final LivePriceStreamManager? _livePrices;
  LivePriceLease? _lease;
  StreamSubscription<LivePriceBatch>? _liveSubscription;
  StreamSubscription<void>? _positionSubscription;

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _lease?.dispose();
    return super.close();
  }

  Future<void> _start(
    OrderPlacementStarted event,
    Emitter<OrderPlacementState> emit,
  ) async {
    emit(
      OrderPlacementState(
        status: OrderPlacementStatus.loading,
        side: event.side == TradeSide.sell ? OrderSide.sell : OrderSide.buy,
      ),
    );
    try {
      final loaded = await _repository.getInstrument(event.fundId);
      final exchange = loaded.availableExchanges.contains(event.exchange)
          ? event.exchange
          : loaded.defaultExchange;
      final instrument = loaded.forExchange(exchange);
      _watch(instrument);
      _positionSubscription ??= _repository.positionChanges.listen(
        (_) => add(const OrderPositionAvailabilityChanged()),
      );
      final available = await _repository.getAvailableSellQuantity(
        fundId: instrument.id,
        exchange: exchange,
      );
      emit(
        OrderPlacementState(
          status: OrderPlacementStatus.ready,
          instrument: instrument,
          side: event.side == TradeSide.sell ? OrderSide.sell : OrderSide.buy,
          exchange: exchange,
          quantity: instrument.quantityStep,
          product: instrument.allowedProducts.first,
          limitPrice: instrument.ltp,
          triggerPrice: instrument.ltp,
          availableSellQuantity: available,
        ),
      );
    } on Object {
      emit(
        OrderPlacementState(
          status: OrderPlacementStatus.error,
          errorMessage: 'Unable to load instrument.',
        ),
      );
    }
  }

  void _exchangeChanged(
    OrderExchangeChanged event,
    Emitter<OrderPlacementState> emit,
  ) {
    if (state.instrument?.availableExchanges.contains(event.exchange) ??
        false) {
      final instrument = state.instrument!.forExchange(event.exchange);
      _edit(
        emit,
        state.copyWith(exchange: event.exchange, instrument: instrument),
      );
      _watch(instrument);
      add(const OrderPositionAvailabilityChanged());
    }
  }

  void _productChanged(
    OrderProductChanged event,
    Emitter<OrderPlacementState> emit,
  ) {
    if (state.instrument?.allowedProducts.contains(event.product) ?? false) {
      _edit(emit, state.copyWith(product: event.product));
    }
  }

  void _changeQuantity(Emitter<OrderPlacementState> emit, int quantity) {
    final next = state.copyWith(quantity: quantity);
    _edit(emit, next);
    if (next.side == OrderSide.sell) {
      final error = _sellQuantityError(next);
      if (error != null) {
        emit(
          next.copyWith(
            status: OrderPlacementStatus.ready,
            fieldErrors: {'quantity': error},
          ),
        );
      }
    }
  }

  void _edit(Emitter<OrderPlacementState> emit, OrderPlacementState next) {
    emit(
      next.copyWith(
        status: OrderPlacementStatus.ready,
        clearFieldErrors: true,
        clearError: true,
      ),
    );
  }

  void _review(OrderReviewRequested event, Emitter<OrderPlacementState> emit) {
    final errors = _validate(state);
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(status: OrderPlacementStatus.ready, fieldErrors: errors),
      );
      return;
    }
    emit(state.copyWith(status: OrderPlacementStatus.review, clearError: true));
  }

  Future<void> _confirm(
    OrderPlacementEvent event,
    Emitter<OrderPlacementState> emit,
  ) async {
    if (state.isPlacingOrder ||
        (state.status != OrderPlacementStatus.review &&
            state.status != OrderPlacementStatus.error)) {
      return;
    }
    var draft = state.draft;
    final errors = _validate(state);
    if (draft == null || errors.isNotEmpty) {
      emit(
        state.copyWith(status: OrderPlacementStatus.ready, fieldErrors: errors),
      );
      return;
    }
    final latest = _livePrices?.latestFor(draft.instrument.marketKey);
    if (latest != null) {
      draft = OrderDraft(
        instrument: draft.instrument.withLivePrice(latest),
        side: draft.side,
        exchange: draft.exchange,
        quantity: draft.quantity,
        orderType: draft.orderType,
        product: draft.product,
        validity: draft.validity,
        limitPrice: draft.limitPrice,
        triggerPrice: draft.triggerPrice,
      );
    }
    emit(
      state.copyWith(status: OrderPlacementStatus.placing, clearError: true),
    );
    try {
      final placed = await _repository.placeOrder(draft);
      emit(
        state.copyWith(
          status: OrderPlacementStatus.success,
          placedOrder: placed,
        ),
      );
    } on InsufficientPositionException catch (error) {
      emit(
        state.copyWith(
          status: OrderPlacementStatus.ready,
          fieldErrors: {'quantity': error.message},
          errorMessage: error.message,
        ),
      );
      add(const OrderPositionAvailabilityChanged());
    } on Object {
      emit(
        state.copyWith(
          status: OrderPlacementStatus.error,
          errorMessage: 'Unable to place order.',
        ),
      );
    }
  }

  Map<String, String> _validate(OrderPlacementState value) {
    final errors = <String, String>{};
    final instrument = value.instrument;
    if (instrument == null) {
      return {'form': 'Instrument is unavailable.'};
    }
    if (value.exchange == null ||
        !instrument.availableExchanges.contains(value.exchange)) {
      errors['exchange'] = 'Select a valid exchange.';
    }
    if (value.quantity <= 0) {
      errors['quantity'] = 'Quantity must be greater than 0.';
    } else if (instrument.isDerivative &&
        value.quantity % instrument.lotSize != 0) {
      errors['quantity'] =
          'Quantity must be in multiples of ${instrument.lotSize}.';
    }
    final sellError = _sellQuantityError(value);
    if (sellError != null) errors['quantity'] = sellError;
    if (!instrument.allowedProducts.contains(value.product)) {
      errors['product'] = 'Select a valid product.';
    }
    if (!instrument.allowedOrderTypes.contains(value.orderType)) {
      errors['orderType'] = 'Select a valid order type.';
    }
    if (value.showsLimitPrice) {
      _validatePrice(
        'limitPrice',
        'Limit price',
        value.limitPrice,
        instrument.tickSize,
        errors,
      );
    }
    if (value.showsTriggerPrice) {
      _validatePrice(
        'triggerPrice',
        'Trigger price',
        value.triggerPrice,
        instrument.tickSize,
        errors,
      );
    }
    if (errors.isEmpty && value.showsTriggerPrice) {
      final trigger = value.triggerPrice!;
      if (value.side == OrderSide.buy && trigger < instrument.ltp) {
        errors['triggerPrice'] = 'Buy trigger must be at or above LTP.';
      }
      if (value.side == OrderSide.sell && trigger > instrument.ltp) {
        errors['triggerPrice'] = 'Sell trigger must be at or below LTP.';
      }
      if (value.orderType == TradeOrderType.stopLoss) {
        final limit = value.limitPrice!;
        if (value.side == OrderSide.buy && limit < trigger) {
          errors['limitPrice'] = 'Buy limit must be at or above trigger.';
        }
        if (value.side == OrderSide.sell && limit > trigger) {
          errors['limitPrice'] = 'Sell limit must be at or below trigger.';
        }
      }
    }
    return errors;
  }

  String? _sellQuantityError(OrderPlacementState value) {
    if (value.side != OrderSide.sell || value.quantity <= 0) return null;
    final available = value.availableSellQuantity;
    if (value.quantity <= available) return null;
    return available <= 0
        ? 'No quantity available to sell.'
        : 'Only $available quantity available to sell.';
  }

  Future<void> _refreshAvailability(
    OrderPositionAvailabilityChanged event,
    Emitter<OrderPlacementState> emit,
  ) async {
    final instrument = state.instrument;
    final exchange = state.exchange;
    if (instrument == null || exchange == null) return;
    final available = await _repository.getAvailableSellQuantity(
      fundId: instrument.id,
      exchange: exchange,
    );
    final next = state.copyWith(availableSellQuantity: available);
    final error = _sellQuantityError(next);
    emit(
      next.copyWith(
        fieldErrors: error == null ? const {} : {'quantity': error},
      ),
    );
  }

  void _validatePrice(
    String key,
    String label,
    double? value,
    double tick,
    Map<String, String> errors,
  ) {
    if (value == null || value <= 0) {
      errors[key] = '$label must be greater than 0.';
      return;
    }
    if (tick > 0) {
      final units = value / tick;
      if ((units - units.round()).abs() > 0.000001) {
        errors[key] =
            '$label must follow the ${tick.toStringAsFixed(2)} tick size.';
      }
    }
  }

  void _watch(OrderInstrument instrument) {
    final manager = _livePrices;
    if (manager == null) return;
    final cached = manager.latestFor(instrument.marketKey);
    if (cached != null) {
      add(
        OrderLivePricesReceived(
          LivePriceBatch(
            sequence: cached.sequence,
            timestamp: cached.timestamp,
            updates: <LivePriceTick>[cached],
          ),
        ),
      );
    }
    final seed = LiveInstrumentSeed.fromPrices(
      marketKey: instrument.marketKey,
      fundId: instrument.id,
      exchange: instrument.exchange,
      assetType: switch (instrument.instrumentType) {
        OrderInstrumentType.equity => LiveMarketAssetType.equity,
        OrderInstrumentType.future => LiveMarketAssetType.future,
        OrderInstrumentType.option => LiveMarketAssetType.option,
      },
      symbol: instrument.symbol,
      ltp: instrument.ltp,
      previousClose: instrument.previousClose,
      tickSize: instrument.tickSize,
    );
    final lease = _lease;
    if (lease == null) {
      final acquired = manager.acquire(instruments: [seed]);
      _lease = acquired;
      _liveSubscription = acquired.stream.listen(
        (batch) => add(OrderLivePricesReceived(batch)),
      );
    } else {
      unawaited(lease.update([seed]));
    }
  }

  void _onLivePrices(
    OrderLivePricesReceived event,
    Emitter<OrderPlacementState> emit,
  ) {
    final instrument = state.instrument;
    if (instrument == null) return;
    for (final tick in event.batch.updates) {
      if (tick.instrumentId == instrument.marketKey) {
        emit(state.copyWith(instrument: instrument.withLivePrice(tick)));
        return;
      }
    }
  }
}
