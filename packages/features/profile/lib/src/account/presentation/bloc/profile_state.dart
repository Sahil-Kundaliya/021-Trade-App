import 'package:core_data/core_data.dart';

enum ProfileLoadStatus { initial, loading, ready, failure }

final class ProfileState {
  const ProfileState({
    this.status = ProfileLoadStatus.initial,
    this.preferences = const AppPreferences(),
    this.isSaving = false,
    this.errorMessage,
  });

  final ProfileLoadStatus status;
  final AppPreferences preferences;
  final bool isSaving;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileLoadStatus? status,
    AppPreferences? preferences,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) => ProfileState(
    status: status ?? this.status,
    preferences: preferences ?? this.preferences,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
