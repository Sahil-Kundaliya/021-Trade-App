import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../cache/key_value_storage.dart';
import '../exceptions/orderbook_data_exception.dart';
import '../models/order_dto.dart';
import 'orderbook_local_api.dart';

@LazySingleton(as: OrderBookLocalApi)
final class OrderBookLocalApiImpl implements OrderBookLocalApi {
  OrderBookLocalApiImpl(this._storage);

  static const storageKey = 'trading_orders_v1';
  static const _requestDelay = Duration(milliseconds: 800);

  final KeyValueStorage _storage;

  @override
  Future<List<OrderDto>> getOrders() async {
    await Future<void>.delayed(_requestDelay);
    try {
      final source = await _storage.getString(storageKey);
      if (source == null || source.trim().isEmpty) return const <OrderDto>[];
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic> || decoded['orders'] is! List) {
        throw const FormatException('Invalid order book document.');
      }
      return List<OrderDto>.unmodifiable(
        (decoded['orders'] as List).map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Invalid order entry.');
          }
          return OrderDto.fromJson(value);
        }),
      );
    } on OrderBookDataException {
      rethrow;
    } on Object catch (error) {
      throw OrderBookDataException('Unable to read orders.', error);
    }
  }

  @override
  Future<void> saveOrders(List<OrderDto> orders) async {
    await Future<void>.delayed(_requestDelay);
    try {
      final ids = orders.map((order) => order.id).toSet();
      if (ids.length != orders.length) {
        throw const OrderBookDataException('Order IDs must be unique.');
      }
      await _storage.setString(
        storageKey,
        jsonEncode(<String, dynamic>{
          'orders': orders.map((order) => order.toJson()).toList(),
        }),
      );
    } on OrderBookDataException {
      rethrow;
    } on Object catch (error) {
      throw OrderBookDataException('Unable to save orders.', error);
    }
  }
}
