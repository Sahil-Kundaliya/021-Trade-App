import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:navigation_contract/navigation_contract.dart';

import '../../domain/enums/order_enums.dart';
import '../../domain/repositories/order_placement_repository.dart';
import 'order_placement_event.dart';
import 'order_placement_state.dart';

@injectable
class OrderPlacementBloc
    extends Bloc<OrderPlacementEvent, OrderPlacementState> {
  OrderPlacementBloc(this._repository) : super(const OrderPlacementState()) {
    on<OrderPlacementStarted>(_start);
    on<OrderSideChanged>(
      (event, emit) => _edit(emit, state.copyWith(side: event.side)),
    );
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
  }

  final OrderPlacementRepository _repository;

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
      final instrument = await _repository.getInstrument(event.fundId);
      emit(
        OrderPlacementState(
          status: OrderPlacementStatus.ready,
          instrument: instrument,
          side: event.side == TradeSide.sell ? OrderSide.sell : OrderSide.buy,
          exchange: instrument.defaultExchange,
          quantity: instrument.quantityStep,
          product: instrument.allowedProducts.first,
          limitPrice: instrument.ltp,
          triggerPrice: instrument.ltp,
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
      _edit(emit, state.copyWith(exchange: event.exchange));
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

  void _changeQuantity(Emitter<OrderPlacementState> emit, int quantity) =>
      _edit(emit, state.copyWith(quantity: quantity));

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
    final draft = state.draft;
    final errors = _validate(state);
    if (draft == null || errors.isNotEmpty) {
      emit(
        state.copyWith(status: OrderPlacementStatus.ready, fieldErrors: errors),
      );
      return;
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
}
