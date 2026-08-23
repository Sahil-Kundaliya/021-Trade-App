import 'package:core_data/core_data.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/profile_preferences_repository.dart';

@LazySingleton(as: ProfilePreferencesRepository)
final class ProfilePreferencesRepositoryImpl
    implements ProfilePreferencesRepository {
  const ProfilePreferencesRepositoryImpl(this._appPreferencesRepository);

  final AppPreferencesRepository _appPreferencesRepository;

  @override
  Future<AppPreferences> getPreferences() =>
      _appPreferencesRepository.getPreferences();

  @override
  Future<AppPreferences> update(
    AppPreferences Function(AppPreferences current) change,
  ) => _appPreferencesRepository.update(change);
}
