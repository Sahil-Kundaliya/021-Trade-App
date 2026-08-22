import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'key_value_storage.dart';

@LazySingleton(as: KeyValueStorage)
final class FlutterKeyValueStorage implements KeyValueStorage {
  const FlutterKeyValueStorage();

  static const _storage = FlutterSecureStorage();

  @override
  Future<void> setString(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> getString(String key) => _storage.read(key: key);

  @override
  Future<void> remove(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}
