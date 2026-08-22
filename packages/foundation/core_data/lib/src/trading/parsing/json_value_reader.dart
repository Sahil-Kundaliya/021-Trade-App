import '../exceptions/trading_data_exception.dart';

abstract final class JsonValueReader {
  static String string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw TradingDataException('Expected a non-empty string at "$key".');
  }

  static String? nullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return value;
    throw TradingDataException('Expected a string or null at "$key".');
  }

  static double number(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    throw TradingDataException('Expected a number at "$key".');
  }

  static double? nullableNumber(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw TradingDataException('Expected a number or null at "$key".');
  }

  static int integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    throw TradingDataException('Expected an integer at "$key".');
  }

  static int? nullableInteger(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    throw TradingDataException('Expected an integer or null at "$key".');
  }

  static DateTime date(Map<String, dynamic> json, String key) {
    final raw = string(json, key);
    final value = DateTime.tryParse(raw);
    if (value != null) return value;
    throw TradingDataException('Invalid date at "$key": $raw.');
  }

  static DateTime? nullableDate(Map<String, dynamic> json, String key) {
    final raw = nullableString(json, key);
    if (raw == null) return null;
    final value = DateTime.tryParse(raw);
    if (value != null) return value;
    throw TradingDataException('Invalid date at "$key": $raw.');
  }

  static Map<String, dynamic> object(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    throw TradingDataException('Expected an object at "$key".');
  }

  static List<dynamic> list(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is List<dynamic>) return value;
    throw TradingDataException('Expected a list at "$key".');
  }

  static Map<String, dynamic> listObject(dynamic value, String path) {
    if (value is Map<String, dynamic>) return value;
    throw TradingDataException('Expected an object at "$path".');
  }
}
