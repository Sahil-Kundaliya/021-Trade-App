import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/profile_preferences_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
final class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository) : super(const ProfileState()) {
    on<ProfileStarted>(_load);
    on<ProfileRetryRequested>(_load);
    on<ProfilePrivacyModeChanged>(
      (event, emit) =>
          _save(emit, (value) => value.copyWith(privacyMode: event.enabled)),
    );
    on<ProfileNotificationsChanged>(
      (event, emit) => _save(
        emit,
        (value) => value.copyWith(notificationsEnabled: event.enabled),
      ),
    );
    on<ProfileOrderPreferencesChanged>(
      (event, emit) => _save(
        emit,
        (value) => value.copyWith(
          defaultOrderSide: event.side,
          defaultOrderType: event.orderType,
          defaultProductType: event.productType,
        ),
      ),
    );
    on<ProfilePriceDisplayChanged>(
      (event, emit) =>
          _save(emit, (value) => value.copyWith(priceDisplayMode: event.mode)),
    );
  }

  final ProfilePreferencesRepository _repository;

  Future<void> _load(ProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileLoadStatus.loading, clearError: true));
    try {
      final preferences = await _repository.getPreferences();
      emit(
        ProfileState(status: ProfileLoadStatus.ready, preferences: preferences),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileLoadStatus.failure,
          errorMessage: 'Could not load your preferences.',
        ),
      );
    }
  }

  Future<void> _save(
    Emitter<ProfileState> emit,
    AppPreferences Function(AppPreferences value) change,
  ) async {
    final previous = state.preferences;
    final optimistic = change(previous);
    emit(
      state.copyWith(preferences: optimistic, isSaving: true, clearError: true),
    );
    try {
      final saved = await _repository.update(change);
      emit(state.copyWith(preferences: saved, isSaving: false));
    } catch (_) {
      emit(
        state.copyWith(
          preferences: previous,
          isSaving: false,
          errorMessage:
              'Preference could not be saved. The previous value was restored.',
        ),
      );
    }
  }
}
