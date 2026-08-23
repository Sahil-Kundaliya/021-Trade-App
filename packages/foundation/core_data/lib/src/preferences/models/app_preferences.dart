enum AppThemeMode { system, light, dark }

enum DefaultOrderSide { buy, sell }

enum DefaultOrderType { market, limit }

enum DefaultProductType { delivery, intraday }

enum PriceDisplayMode { absoluteAndPercent, percentOnly, absoluteOnly }

final class AppPreferences {
  const AppPreferences({
    this.themeMode = AppThemeMode.system,
    this.privacyMode = false,
    this.notificationsEnabled = true,
    this.defaultOrderSide = DefaultOrderSide.buy,
    this.defaultOrderType = DefaultOrderType.market,
    this.defaultProductType = DefaultProductType.delivery,
    this.priceDisplayMode = PriceDisplayMode.absoluteAndPercent,
  });

  final AppThemeMode themeMode;
  final bool privacyMode;
  final bool notificationsEnabled;
  final DefaultOrderSide defaultOrderSide;
  final DefaultOrderType defaultOrderType;
  final DefaultProductType defaultProductType;
  final PriceDisplayMode priceDisplayMode;

  AppPreferences copyWith({
    AppThemeMode? themeMode,
    bool? privacyMode,
    bool? notificationsEnabled,
    DefaultOrderSide? defaultOrderSide,
    DefaultOrderType? defaultOrderType,
    DefaultProductType? defaultProductType,
    PriceDisplayMode? priceDisplayMode,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    privacyMode: privacyMode ?? this.privacyMode,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    defaultOrderSide: defaultOrderSide ?? this.defaultOrderSide,
    defaultOrderType: defaultOrderType ?? this.defaultOrderType,
    defaultProductType: defaultProductType ?? this.defaultProductType,
    priceDisplayMode: priceDisplayMode ?? this.priceDisplayMode,
  );
}
