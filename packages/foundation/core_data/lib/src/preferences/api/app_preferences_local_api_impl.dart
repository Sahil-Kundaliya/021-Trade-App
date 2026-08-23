import 'package:injectable/injectable.dart';

import '../../cache/key_value_storage.dart';
import '../exceptions/app_preferences_exception.dart';
import '../models/app_preferences.dart';
import '../models/app_preferences_dto.dart';
import 'app_preferences_local_api.dart';

@LazySingleton(as: AppPreferencesLocalApi)
final class AppPreferencesLocalApiImpl implements AppPreferencesLocalApi {
  const AppPreferencesLocalApiImpl(this._storage);

  static const storageKey = 'app_preferences_v1';
  final KeyValueStorage _storage;

  @override
  Future<AppPreferences?> read() async {
    try {
      final stored = await _storage.getString(storageKey);
      if (stored == null) return null;
      return AppPreferencesDto.fromJsonString(stored).preferences;
    } catch (error) {
      throw AppPreferencesException('Could not read app preferences.', error);
    }
  }

  @override
  Future<void> write(AppPreferences preferences) async {
    try {
      await _storage.setString(
        storageKey,
        AppPreferencesDto(preferences).toJsonString(),
      );
    } catch (error) {
      throw AppPreferencesException('Could not save app preferences.', error);
    }
  }
}
