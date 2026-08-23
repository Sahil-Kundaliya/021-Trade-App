import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'order store emits runtime semantic transitions after persistence',
    () async {
      final store = OrderStore(_OrderApi());
      final events = <TradingOrderEvent>[];
      final subscription = store.events.listen(events.add);
      final placed = _order(status: 'open');

      await store.append(placed);
      await store.replace(
        placed.copyWith(
          status: 'executed',
          filledQuantity: 10,
          pendingQuantity: 0,
          averagePrice: 99,
          updatedAt: DateTime(2026, 1, 1, 0, 1),
        ),
      );

      expect(events.map((event) => event.type), [
        TradingOrderEventType.placed,
        TradingOrderEventType.executed,
      ]);
      await subscription.cancel();
    },
  );

  test('coordinator respects notification preference and permission', () async {
    final api = _OrderApi();
    final store = OrderStore(api);
    final preferences = AppPreferencesRepository(_PreferencesApi());
    final notifications = _Notifications();
    final coordinator = TradingNotificationCoordinator(
      notifications,
      preferences,
      store,
    );
    await preferences.update(
      (value) => value.copyWith(notificationsEnabled: true, privacyMode: true),
    );
    await coordinator.start();

    await store.append(_order(status: 'executed'));
    await Future<void>.delayed(Duration.zero);
    expect(notifications.shown, hasLength(1));
    expect(notifications.shown.single.body, contains('RELIANCE'));
    expect(notifications.shown.single.body, contains('10 Qty'));

    await preferences.update(
      (value) => value.copyWith(notificationsEnabled: false),
    );
    await store.append(_order(id: 'second', status: 'open'));
    await Future<void>.delayed(Duration.zero);
    expect(notifications.shown, hasLength(1));
    await coordinator.stop();
  });
}

class _OrderApi implements OrderBookLocalApi {
  List<OrderDto> orders = const [];

  @override
  Future<List<OrderDto>> getOrders() async => orders;

  @override
  Future<void> saveOrders(List<OrderDto> value) async {
    orders = List.unmodifiable(value);
  }
}

class _PreferencesApi implements AppPreferencesLocalApi {
  AppPreferences? value;

  @override
  Future<AppPreferences?> read() async => value;

  @override
  Future<void> write(AppPreferences preferences) async => value = preferences;
}

class _Notifications implements LocalNotificationService {
  final shown = <TradingNotification>[];

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async =>
      NotificationPermissionStatus.authorized;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> showTradingNotification(TradingNotification notification) async {
    shown.add(notification);
  }
}

OrderDto _order({String id = 'first', required String status}) => OrderDto(
  id: id,
  fundId: 'RELIANCE_EQ',
  symbol: 'RELIANCE',
  companyName: 'Reliance Industries',
  exchange: 'nse',
  instrumentType: 'equity',
  side: 'buy',
  orderType: status == 'executed' ? 'market' : 'limit',
  productType: 'delivery',
  status: status,
  quantity: 10,
  filledQuantity: status == 'executed' ? 10 : 0,
  pendingQuantity: status == 'executed' ? 0 : 10,
  ltp: 100,
  averagePrice: status == 'executed' ? 100 : null,
  limitPrice: status == 'executed' ? null : 99,
  orderValue: 1000,
  validity: 'DAY',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);
