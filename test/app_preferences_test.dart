import 'package:core_data/core_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile/profile.dart';
import 'package:zero_two_one_trade_assignment/app/theme/theme_bloc.dart';

void main() {
  test('missing preferences return defaults without writing storage', () async {
    final api = _MemoryPreferencesApi();
    final repository = AppPreferencesRepository(api);

    final preferences = await repository.getPreferences();

    expect(preferences.themeMode, AppThemeMode.system);
    expect(preferences.privacyMode, isFalse);
    expect(preferences.notificationsEnabled, isTrue);
    expect(preferences.defaultOrderSide, DefaultOrderSide.buy);
    expect(preferences.defaultOrderType, DefaultOrderType.market);
    expect(preferences.defaultProductType, DefaultProductType.delivery);
    expect(preferences.priceDisplayMode, PriceDisplayMode.absoluteAndPercent);
    expect(api.writeCount, 0);
  });

  test('theme applies and survives a bloc restart', () async {
    final api = _MemoryPreferencesApi();
    final repository = AppPreferencesRepository(api);
    final firstBloc = ThemeBloc(repository);

    firstBloc.add(const ThemeModeChanged(AppThemeMode.dark));
    await firstBloc.stream.firstWhere(
      (state) => state.mode == AppThemeMode.dark && !state.isLoading,
    );
    await firstBloc.close();

    final restartedBloc = ThemeBloc(repository)..add(const ThemeStarted());
    final restarted = await restartedBloc.stream.firstWhere(
      (state) => state.mode == AppThemeMode.dark,
    );

    expect(restarted.mode, AppThemeMode.dark);
    expect(api.writeCount, 1);
    await restartedBloc.close();
  });

  test('profile settings share one persisted preferences record', () async {
    final api = _MemoryPreferencesApi();
    final bloc = ProfileBloc(
      ProfilePreferencesRepositoryImpl(AppPreferencesRepository(api)),
    )..add(const ProfileStarted());
    await bloc.stream.firstWhere(
      (state) => state.status == ProfileLoadStatus.ready,
    );

    bloc.add(const ProfilePrivacyModeChanged(true));
    await bloc.stream.firstWhere(
      (state) => state.preferences.privacyMode && !state.isSaving,
    );
    bloc.add(const ProfileNotificationsChanged(false));
    await bloc.stream.firstWhere(
      (state) => !state.preferences.notificationsEnabled && !state.isSaving,
    );
    bloc.add(
      const ProfileOrderPreferencesChanged(
        side: DefaultOrderSide.sell,
        orderType: DefaultOrderType.limit,
        productType: DefaultProductType.intraday,
      ),
    );
    await bloc.stream.firstWhere(
      (state) =>
          state.preferences.defaultOrderSide == DefaultOrderSide.sell &&
          !state.isSaving,
    );
    bloc.add(const ProfilePriceDisplayChanged(PriceDisplayMode.percentOnly));
    await bloc.stream.firstWhere(
      (state) =>
          state.preferences.priceDisplayMode == PriceDisplayMode.percentOnly &&
          !state.isSaving,
    );

    expect(api.value!.privacyMode, isTrue);
    expect(api.value!.notificationsEnabled, isFalse);
    expect(api.value!.defaultOrderType, DefaultOrderType.limit);
    expect(api.value!.defaultProductType, DefaultProductType.intraday);
    expect(api.value!.priceDisplayMode, PriceDisplayMode.percentOnly);
    await bloc.close();
  });
}

final class _MemoryPreferencesApi implements AppPreferencesLocalApi {
  AppPreferences? value;
  int writeCount = 0;

  @override
  Future<AppPreferences?> read() async => value;

  @override
  Future<void> write(AppPreferences preferences) async {
    value = preferences;
    writeCount++;
  }
}
