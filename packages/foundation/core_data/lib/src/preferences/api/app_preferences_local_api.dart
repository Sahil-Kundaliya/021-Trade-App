import '../models/app_preferences.dart';

abstract interface class AppPreferencesLocalApi {
  Future<AppPreferences?> read();

  Future<void> write(AppPreferences preferences);
}
