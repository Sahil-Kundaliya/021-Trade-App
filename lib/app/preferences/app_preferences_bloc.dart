import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class AppPreferencesEvent {
  const AppPreferencesEvent();
}

final class AppPreferencesStarted extends AppPreferencesEvent {
  const AppPreferencesStarted();
}

final class AppPrivacyModeChanged extends AppPreferencesEvent {
  const AppPrivacyModeChanged(this.enabled);
  final bool enabled;
}

final class AppNotificationsChanged extends AppPreferencesEvent {
  const AppNotificationsChanged(this.enabled);
  final bool enabled;
}

final class AppNotificationPermissionRefreshed extends AppPreferencesEvent {
  const AppNotificationPermissionRefreshed();
}

final class AppThemeModeChanged extends AppPreferencesEvent {
  const AppThemeModeChanged(this.mode);
  final AppThemeMode mode;
}

final class _RepositoryPreferencesChanged extends AppPreferencesEvent {
  const _RepositoryPreferencesChanged(this.preferences);
  final AppPreferences preferences;
}

final class AppPreferencesState {
  const AppPreferencesState({
    this.preferences = const AppPreferences(),
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
    this.notificationPermission = NotificationPermissionStatus.notDetermined,
  });

  final AppPreferences preferences;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final NotificationPermissionStatus notificationPermission;

  bool get notificationsEffective =>
      preferences.notificationsEnabled &&
      notificationPermission == NotificationPermissionStatus.authorized;
}

final class AppPreferencesBloc
    extends Bloc<AppPreferencesEvent, AppPreferencesState> {
  AppPreferencesBloc(this._repository, this._notifications)
    : super(const AppPreferencesState()) {
    on<AppPreferencesStarted>(_started);
    on<AppPrivacyModeChanged>(
      (event, emit) =>
          _save(emit, (value) => value.copyWith(privacyMode: event.enabled)),
    );
    on<AppNotificationsChanged>(_notificationsChanged);
    on<AppNotificationPermissionRefreshed>(_refreshPermission);
    on<AppThemeModeChanged>(
      (event, emit) =>
          _save(emit, (value) => value.copyWith(themeMode: event.mode)),
    );
    on<_RepositoryPreferencesChanged>(
      (event, emit) => emit(
        AppPreferencesState(
          preferences: event.preferences,
          isLoading: false,
          notificationPermission: state.notificationPermission,
        ),
      ),
    );
    _subscription = _repository.changes.listen(
      (preferences) => add(_RepositoryPreferencesChanged(preferences)),
    );
  }

  final AppPreferencesRepository _repository;
  final LocalNotificationService _notifications;
  late final StreamSubscription<AppPreferences> _subscription;

  Future<void> _started(
    AppPreferencesStarted event,
    Emitter<AppPreferencesState> emit,
  ) async {
    try {
      final preferences = await _repository.getPreferences();
      NotificationPermissionStatus permission;
      try {
        permission = await _notifications.getPermissionStatus();
      } catch (_) {
        permission = NotificationPermissionStatus.denied;
      }
      emit(
        AppPreferencesState(
          preferences: preferences,
          isLoading: false,
          notificationPermission: permission,
        ),
      );
    } catch (_) {
      emit(
        AppPreferencesState(
          preferences: state.preferences,
          isLoading: false,
          errorMessage: 'Could not load app preferences.',
          notificationPermission: state.notificationPermission,
        ),
      );
    }
  }

  Future<void> _save(
    Emitter<AppPreferencesState> emit,
    AppPreferences Function(AppPreferences value) change,
  ) async {
    final previous = state.preferences;
    emit(
      AppPreferencesState(
        preferences: change(previous),
        isLoading: false,
        isSaving: true,
        notificationPermission: state.notificationPermission,
      ),
    );
    try {
      await _repository.update(change);
    } catch (_) {
      emit(
        AppPreferencesState(
          preferences: previous,
          isLoading: false,
          errorMessage: 'Preference could not be saved.',
          notificationPermission: state.notificationPermission,
        ),
      );
    }
  }

  Future<void> _notificationsChanged(
    AppNotificationsChanged event,
    Emitter<AppPreferencesState> emit,
  ) async {
    if (!event.enabled) {
      await _save(emit, (value) => value.copyWith(notificationsEnabled: false));
      return;
    }
    var permission = NotificationPermissionStatus.denied;
    try {
      permission = await _notifications.getPermissionStatus();
      if (permission != NotificationPermissionStatus.authorized) {
        final granted = await _notifications.requestPermission();
        permission = granted
            ? NotificationPermissionStatus.authorized
            : NotificationPermissionStatus.denied;
      }
    } catch (_) {
      permission = NotificationPermissionStatus.denied;
    }
    if (permission != NotificationPermissionStatus.authorized) {
      await _repository.update(
        (value) => value.copyWith(notificationsEnabled: false),
      );
      emit(
        AppPreferencesState(
          preferences: state.preferences.copyWith(notificationsEnabled: false),
          isLoading: false,
          notificationPermission: permission,
          errorMessage:
              'Notification permission is disabled. Enable it from system settings to receive order alerts.',
        ),
      );
      return;
    }
    emit(
      AppPreferencesState(
        preferences: state.preferences,
        isLoading: false,
        notificationPermission: permission,
      ),
    );
    await _save(emit, (value) => value.copyWith(notificationsEnabled: true));
  }

  Future<void> _refreshPermission(
    AppNotificationPermissionRefreshed event,
    Emitter<AppPreferencesState> emit,
  ) async {
    NotificationPermissionStatus permission;
    try {
      permission = await _notifications.getPermissionStatus();
    } catch (_) {
      permission = NotificationPermissionStatus.denied;
    }
    emit(
      AppPreferencesState(
        preferences: state.preferences,
        isLoading: false,
        notificationPermission: permission,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
