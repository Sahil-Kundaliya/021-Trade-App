import 'dart:async';

import 'package:injectable/injectable.dart';

import '../api/app_preferences_local_api.dart';
import '../models/app_preferences.dart';

@lazySingleton
final class AppPreferencesRepository {
  AppPreferencesRepository(this._localApi);

  final AppPreferencesLocalApi _localApi;
  Future<void> _pendingWrite = Future.value();

  Future<AppPreferences> getPreferences() async {
    await _pendingWrite;
    return await _localApi.read() ?? const AppPreferences();
  }

  Future<AppPreferences> update(
    AppPreferences Function(AppPreferences current) change,
  ) {
    final completer = Completer<AppPreferences>();
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        final current = await _localApi.read() ?? const AppPreferences();
        final updated = change(current);
        await _localApi.write(updated);
        completer.complete(updated);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}
