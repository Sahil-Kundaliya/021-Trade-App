import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../orderbook/store/order_store.dart';
import '../preferences/models/app_preferences.dart';
import '../preferences/repositories/app_preferences_repository.dart';
import 'local_notification_service.dart';
import 'trading_notification_mapper.dart';
import 'trading_order_event.dart';

@lazySingleton
class TradingNotificationCoordinator {
  TradingNotificationCoordinator(
    this._notifications,
    this._preferences,
    this._orders,
  );

  final LocalNotificationService _notifications;
  final AppPreferencesRepository _preferences;
  final OrderStore _orders;
  final Set<String> _delivered = <String>{};
  StreamSubscription<TradingOrderEvent>? _subscription;
  StreamSubscription<AppPreferences>? _preferenceSubscription;
  AppPreferences _current = const AppPreferences();

  Future<void> start() async {
    if (_subscription != null) return;
    await _notifications.initialize();
    _current = await _preferences.getPreferences();
    _preferenceSubscription = _preferences.changes.listen(
      (value) => _current = value,
    );
    _subscription = _orders.events.listen(_onEvent);
  }

  Future<void> _onEvent(TradingOrderEvent event) async {
    if (!_current.notificationsEnabled || !_delivered.add(event.eventId)) {
      return;
    }
    try {
      if (await _notifications.getPermissionStatus() !=
          NotificationPermissionStatus.authorized) {
        return;
      }
      await _notifications.showTradingNotification(
        TradingNotificationMapper.map(event, private: false),
      );
    } catch (error) {
      if (kDebugMode) debugPrint('[Notifications] $error');
    }
  }

  @visibleForTesting
  Future<void> stop() async {
    await _subscription?.cancel();
    await _preferenceSubscription?.cancel();
    _subscription = null;
    _preferenceSubscription = null;
  }
}
