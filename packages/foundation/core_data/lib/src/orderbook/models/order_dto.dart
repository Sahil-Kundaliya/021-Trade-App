class OrderDto {
  OrderDto({
    required this.id,
    required this.fundId,
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.instrumentType,
    required this.side,
    required this.orderType,
    required this.productType,
    required this.status,
    required this.quantity,
    required this.filledQuantity,
    required this.pendingQuantity,
    required this.ltp,
    required this.validity,
    required this.createdAt,
    required this.updatedAt,
    this.exchangeOrderId,
    this.averagePrice,
    this.limitPrice,
    this.triggerPrice,
    this.orderValue,
    this.rejectionReason,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    final quantity = json['quantity'];
    final filledQuantity = json['filledQuantity'];
    final pendingQuantity = json['pendingQuantity'];
    if (json['id'] is! String ||
        (json['id'] as String).trim().isEmpty ||
        json['fundId'] is! String ||
        json['symbol'] is! String ||
        json['companyName'] is! String ||
        json['exchange'] is! String ||
        json['instrumentType'] is! String ||
        json['side'] is! String ||
        json['orderType'] is! String ||
        json['productType'] is! String ||
        json['status'] is! String ||
        quantity is! int ||
        filledQuantity is! int ||
        pendingQuantity is! int ||
        json['ltp'] is! num ||
        json['validity'] is! String ||
        createdAt == null ||
        updatedAt == null) {
      throw const FormatException('Invalid order JSON.');
    }
    return OrderDto(
      id: json['id'] as String,
      exchangeOrderId: json['exchangeOrderId'] as String?,
      fundId: json['fundId'] as String,
      symbol: json['symbol'] as String,
      companyName: json['companyName'] as String,
      exchange: json['exchange'] as String,
      instrumentType: json['instrumentType'] as String,
      side: json['side'] as String,
      orderType: json['orderType'] as String,
      productType: json['productType'] as String,
      status: json['status'] as String,
      quantity: quantity,
      filledQuantity: filledQuantity,
      pendingQuantity: pendingQuantity,
      ltp: (json['ltp'] as num).toDouble(),
      averagePrice: (json['averagePrice'] as num?)?.toDouble(),
      limitPrice: (json['limitPrice'] as num?)?.toDouble(),
      triggerPrice: (json['triggerPrice'] as num?)?.toDouble(),
      orderValue: (json['orderValue'] as num?)?.toDouble(),
      validity: json['validity'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  final String id;
  final String? exchangeOrderId;
  final String fundId;
  final String symbol;
  final String companyName;
  final String exchange;
  final String instrumentType;
  final String side;
  final String orderType;
  final String productType;
  final String status;
  final int quantity;
  final int filledQuantity;
  final int pendingQuantity;
  final double ltp;
  final double? averagePrice;
  final double? limitPrice;
  final double? triggerPrice;
  final double? orderValue;
  final String validity;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDto copyWith({
    String? status,
    int? filledQuantity,
    int? pendingQuantity,
    double? averagePrice,
    double? orderValue,
    String? rejectionReason,
    DateTime? updatedAt,
  }) => OrderDto(
    id: id,
    exchangeOrderId: exchangeOrderId,
    fundId: fundId,
    symbol: symbol,
    companyName: companyName,
    exchange: exchange,
    instrumentType: instrumentType,
    side: side,
    orderType: orderType,
    productType: productType,
    status: status ?? this.status,
    quantity: quantity,
    filledQuantity: filledQuantity ?? this.filledQuantity,
    pendingQuantity: pendingQuantity ?? this.pendingQuantity,
    ltp: ltp,
    averagePrice: averagePrice ?? this.averagePrice,
    limitPrice: limitPrice,
    triggerPrice: triggerPrice,
    orderValue: orderValue ?? this.orderValue,
    validity: validity,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'exchangeOrderId': exchangeOrderId,
    'fundId': fundId,
    'symbol': symbol,
    'companyName': companyName,
    'exchange': exchange,
    'instrumentType': instrumentType,
    'side': side,
    'orderType': orderType,
    'productType': productType,
    'status': status,
    'quantity': quantity,
    'filledQuantity': filledQuantity,
    'pendingQuantity': pendingQuantity,
    'ltp': ltp,
    'averagePrice': averagePrice,
    'limitPrice': limitPrice,
    'triggerPrice': triggerPrice,
    'orderValue': orderValue,
    'validity': validity,
    'rejectionReason': rejectionReason,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
