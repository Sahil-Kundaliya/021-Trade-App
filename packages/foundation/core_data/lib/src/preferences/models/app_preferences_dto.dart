import 'dart:convert';

import 'app_preferences.dart';

final class AppPreferencesDto {
  const AppPreferencesDto(this.preferences);

  final AppPreferences preferences;

  factory AppPreferencesDto.fromJsonString(String source) {
    final value = jsonDecode(source);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Preferences must be a JSON object.');
    }
    return AppPreferencesDto(
      AppPreferences(
        themeMode: _enumValue(
          AppThemeMode.values,
          value['themeMode'],
          AppThemeMode.system,
        ),
        privacyMode: value['privacyMode'] as bool? ?? false,
        notificationsEnabled: value['notificationsEnabled'] as bool? ?? true,
        defaultOrderSide: _enumValue(
          DefaultOrderSide.values,
          value['defaultOrderSide']?.toString().toLowerCase(),
          DefaultOrderSide.buy,
        ),
        defaultOrderType: _enumValue(
          DefaultOrderType.values,
          value['defaultOrderType']?.toString().toLowerCase(),
          DefaultOrderType.market,
        ),
        defaultProductType: _enumValue(
          DefaultProductType.values,
          value['defaultProductType']?.toString().toLowerCase(),
          DefaultProductType.delivery,
        ),
        priceDisplayMode: _enumValue(
          PriceDisplayMode.values,
          value['priceDisplayMode'],
          PriceDisplayMode.absoluteAndPercent,
        ),
      ),
    );
  }

  String toJsonString() => jsonEncode({
    'themeMode': preferences.themeMode.name,
    'privacyMode': preferences.privacyMode,
    'notificationsEnabled': preferences.notificationsEnabled,
    'defaultOrderSide': preferences.defaultOrderSide.name.toUpperCase(),
    'defaultOrderType': preferences.defaultOrderType.name.toUpperCase(),
    'defaultProductType': preferences.defaultProductType.name.toUpperCase(),
    'priceDisplayMode': preferences.priceDisplayMode.name,
  });

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? name,
    T fallback,
  ) {
    if (name is! String) return fallback;
    return values.where((value) => value.name == name).firstOrNull ?? fallback;
  }
}
