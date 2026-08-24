import 'package:core_data/core_data.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

final class ProfileFundsRefreshRequested extends ProfileEvent {
  const ProfileFundsRefreshRequested();
}

final class ProfileAvailableFundsChanged extends ProfileEvent {
  const ProfileAvailableFundsChanged(this.balance);
  final double balance;
}

final class ProfilePrivacyModeChanged extends ProfileEvent {
  const ProfilePrivacyModeChanged(this.enabled);
  final bool enabled;
}

final class ProfileNotificationsChanged extends ProfileEvent {
  const ProfileNotificationsChanged(this.enabled);
  final bool enabled;
}

final class ProfileOrderPreferencesChanged extends ProfileEvent {
  const ProfileOrderPreferencesChanged({
    required this.side,
    required this.orderType,
    required this.productType,
  });
  final DefaultOrderSide side;
  final DefaultOrderType orderType;
  final DefaultProductType productType;
}

final class ProfilePriceDisplayChanged extends ProfileEvent {
  const ProfilePriceDisplayChanged(this.mode);
  final PriceDisplayMode mode;
}

final class ProfileRetryRequested extends ProfileEvent {
  const ProfileRetryRequested();
}
