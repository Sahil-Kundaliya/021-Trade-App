import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import 'local_notification_service.dart';

@LazySingleton(as: LocalNotificationService)
class LocalNotificationServiceImpl implements LocalNotificationService {
  LocalNotificationServiceImpl() : _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'trading_orders';
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _available = true;

  @override
  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
        defaultPresentSound: true,
      ),
    );
    try {
      await _plugin.initialize(settings: settings);
      if (Platform.isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                _channelId,
                'Trading Orders',
                description:
                    'Local updates about order placement and execution.',
                importance: Importance.high,
              ),
            );
      }
    } on Object catch (error) {
      _available = false;
      if (kDebugMode) {
        debugPrint('[Notifications] Native plugin unavailable: $error');
      }
    }
    _initialized = true;
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    if (kIsWeb) return NotificationPermissionStatus.denied;
    await initialize();
    if (!_available) return NotificationPermissionStatus.notDetermined;
    if (Platform.isAndroid) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
      return enabled == true
          ? NotificationPermissionStatus.authorized
          : NotificationPermissionStatus.denied;
    }
    if (Platform.isIOS) {
      final options = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      if (options == null) return NotificationPermissionStatus.notDetermined;
      return options.isEnabled
          ? NotificationPermissionStatus.authorized
          : NotificationPermissionStatus.denied;
    }
    return NotificationPermissionStatus.authorized;
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await initialize();
    if (!_available) return false;
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true, badge: true) ??
          false;
    }
    return true;
  }

  @override
  Future<void> showTradingNotification(TradingNotification notification) async {
    await initialize();
    if (!_available) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Trading Orders',
        channelDescription:
            'Local updates about order placement and execution.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: notification.payload,
    );
  }
}
