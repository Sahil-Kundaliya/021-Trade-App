enum NotificationPermissionStatus { authorized, denied, notDetermined }

class TradingNotification {
  const TradingNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String? payload;
}

abstract interface class LocalNotificationService {
  Future<void> initialize();
  Future<NotificationPermissionStatus> getPermissionStatus();
  Future<bool> requestPermission();
  Future<void> showTradingNotification(TradingNotification notification);
}
