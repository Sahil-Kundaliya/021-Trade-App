import 'dart:async';

import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/profile_preferences_repository.dart';
import '../../domain/repositories/profile_funds_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
final class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository, this._fundsRepository)
    : super(const ProfileState()) {
    on<ProfileStarted>(_load);
    on<ProfileRetryRequested>(_load);
    on<ProfileFundsRefreshRequested>(_refreshFunds);
    on<ProfileAvailableFundsChanged>(
      (event, emit) =>
          emit(state.copyWith(availableFunds: event.balance, clearError: true)),
    );
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
    _fundsSubscription = _fundsRepository.watchAvailableBalance().listen(
      (balance) => add(ProfileAvailableFundsChanged(balance)),
    );
  }

  final ProfilePreferencesRepository _repository;
  final ProfileFundsRepository _fundsRepository;
  StreamSubscription<double>? _fundsSubscription;

  @override
  Future<void> close() async {
    await _fundsSubscription?.cancel();
    return super.close();
  }

  Future<void> _load(ProfileEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileLoadStatus.loading, clearError: true));
    try {
      final preferences = await _repository.getPreferences();
      final availableFunds = await _fundsRepository.getAvailableBalance();
      emit(
        ProfileState(
          status: ProfileLoadStatus.ready,
          preferences: preferences,
          availableFunds: availableFunds,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileLoadStatus.failure,
          errorMessage: 'Could not load your profile.',
        ),
      );
    }
  }

  Future<void> _refreshFunds(
    ProfileFundsRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final availableFunds = await _fundsRepository.getAvailableBalance();
      emit(state.copyWith(availableFunds: availableFunds, clearError: true));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not refresh available funds.'));
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
