import '../../domain/entities/order_draft.dart';
import '../../domain/entities/order_instrument.dart';
import '../../domain/entities/placed_order.dart';
import '../../domain/enums/order_enums.dart';
import 'package:core_data/core_data.dart' show LivePriceTick;

enum OrderPlacementStatus {
  initial,
  loading,
  ready,
  review,
  placing,
  success,
  failed,
  error,
}

class OrderPlacementState {
  const OrderPlacementState({
    this.status = OrderPlacementStatus.initial,
    this.instrument,
    this.side = OrderSide.buy,
    this.exchange,
    this.quantity = 1,
    this.orderType = TradeOrderType.market,
    this.product = TradeProduct.delivery,
    this.validity = OrderValidity.day,
    this.limitPrice,
    this.triggerPrice,
    this.fieldErrors = const {},
    this.errorMessage,
    this.placedOrder,
    this.availableSellQuantity = 0,
    this.availableFunds = 0,
    this.requiredFunds = 0,
    this.isAddingFunds = false,
    this.addFundsError,
    this.liveTick,
  });

  final OrderPlacementStatus status;
  final OrderInstrument? instrument;
  final OrderSide side;
  final TradeExchange? exchange;
  final int quantity;
  final TradeOrderType orderType;
  final TradeProduct product;
  final OrderValidity validity;
  final double? limitPrice;
  final double? triggerPrice;
  final Map<String, String> fieldErrors;
  final String? errorMessage;
  final PlacedOrder? placedOrder;
  final int availableSellQuantity;
  final double availableFunds;
  final double requiredFunds;
  final bool isAddingFunds;
  final String? addFundsError;
  final LivePriceTick? liveTick;

  bool get hasInstrument => instrument != null;
  bool get isPlacingOrder => status == OrderPlacementStatus.placing;
  bool get showsLimitPrice => orderType.requiresLimitPrice;
  bool get showsTriggerPrice => orderType.requiresTriggerPrice;
  double get estimatedOrderValue =>
      quantity * (showsLimitPrice ? (limitPrice ?? 0) : (instrument?.ltp ?? 0));
  double get fundShortfall =>
      (requiredFunds - availableFunds).clamp(0, double.infinity);
  String? errorFor(String field) => fieldErrors[field];

  OrderDraft? get draft {
    final value = instrument;
    final selectedExchange = exchange;
    if (value == null || selectedExchange == null) return null;
    return OrderDraft(
      instrument: value,
      side: side,
      exchange: selectedExchange,
      quantity: quantity,
      orderType: orderType,
      product: product,
      validity: validity,
      limitPrice: showsLimitPrice ? limitPrice : null,
      triggerPrice: showsTriggerPrice ? triggerPrice : null,
    );
  }

  OrderPlacementState copyWith({
    OrderPlacementStatus? status,
    OrderInstrument? instrument,
    OrderSide? side,
    TradeExchange? exchange,
    int? quantity,
    TradeOrderType? orderType,
    TradeProduct? product,
    OrderValidity? validity,
    double? limitPrice,
    double? triggerPrice,
    Map<String, String>? fieldErrors,
    String? errorMessage,
    PlacedOrder? placedOrder,
    bool clearError = false,
    bool clearFieldErrors = false,
    bool clearLimitPrice = false,
    bool clearTriggerPrice = false,
    int? availableSellQuantity,
    double? availableFunds,
    double? requiredFunds,
    bool? isAddingFunds,
    String? addFundsError,
    bool clearAddFundsError = false,
    LivePriceTick? liveTick,
    bool clearLiveTick = false,
  }) => OrderPlacementState(
    status: status ?? this.status,
    instrument: instrument ?? this.instrument,
    side: side ?? this.side,
    exchange: exchange ?? this.exchange,
    quantity: quantity ?? this.quantity,
    orderType: orderType ?? this.orderType,
    product: product ?? this.product,
    validity: validity ?? this.validity,
    limitPrice: clearLimitPrice ? null : (limitPrice ?? this.limitPrice),
    triggerPrice: clearTriggerPrice
        ? null
        : (triggerPrice ?? this.triggerPrice),
    fieldErrors: clearFieldErrors
        ? const {}
        : (fieldErrors ?? this.fieldErrors),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    placedOrder: placedOrder ?? this.placedOrder,
    availableSellQuantity: availableSellQuantity ?? this.availableSellQuantity,
    availableFunds: availableFunds ?? this.availableFunds,
    requiredFunds: requiredFunds ?? this.requiredFunds,
    isAddingFunds: isAddingFunds ?? this.isAddingFunds,
    addFundsError: clearAddFundsError
        ? null
        : (addFundsError ?? this.addFundsError),
    liveTick: clearLiveTick ? null : (liveTick ?? this.liveTick),
  );
}
