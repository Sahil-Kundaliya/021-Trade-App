import 'package:core_data/core_data.dart';

abstract interface class ProfilePreferencesRepository {
  Future<AppPreferences> getPreferences();

  Future<AppPreferences> update(
    AppPreferences Function(AppPreferences current) change,
  );
}
