import 'dart:async';

import 'package:injectable/injectable.dart';

import '../api/app_preferences_local_api.dart';
import '../models/app_preferences.dart';

@lazySingleton
final class AppPreferencesRepository {
  AppPreferencesRepository(this._localApi);

  final AppPreferencesLocalApi _localApi;
  Future<void> _pendingWrite = Future.value();
  final StreamController<AppPreferences> _changes =
      StreamController<AppPreferences>.broadcast(sync: true);
  AppPreferences? _current;

  Stream<AppPreferences> get changes => _changes.stream;
  AppPreferences? get current => _current;

  Future<AppPreferences> getPreferences() async {
    await _pendingWrite;
    final preferences = await _localApi.read() ?? const AppPreferences();
    _current = preferences;
    return preferences;
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
        _current = updated;
        _changes.add(updated);
        completer.complete(updated);
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}
