import 'package:core_data/core_data.dart';

enum ProfileLoadStatus { initial, loading, ready, failure }

final class ProfileState {
  const ProfileState({
    this.status = ProfileLoadStatus.initial,
    this.preferences = const AppPreferences(),
    this.availableFunds = 0,
    this.isSaving = false,
    this.errorMessage,
  });

  final ProfileLoadStatus status;
  final AppPreferences preferences;
  final double availableFunds;
  final bool isSaving;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileLoadStatus? status,
    AppPreferences? preferences,
    double? availableFunds,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) => ProfileState(
    status: status ?? this.status,
    preferences: preferences ?? this.preferences,
    availableFunds: availableFunds ?? this.availableFunds,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
