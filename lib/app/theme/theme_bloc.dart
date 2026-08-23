import 'package:core_data/core_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class ThemeEvent {
  const ThemeEvent();
}

final class ThemeStarted extends ThemeEvent {
  const ThemeStarted();
}

final class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.mode);

  final AppThemeMode mode;
}

final class ThemeState {
  const ThemeState({
    this.mode = AppThemeMode.system,
    this.isLoading = false,
    this.errorMessage,
  });

  final AppThemeMode mode;
  final bool isLoading;
  final String? errorMessage;
}

@injectable
final class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._repository) : super(const ThemeState()) {
    on<ThemeStarted>(_onStarted);
    on<ThemeModeChanged>(_onModeChanged);
  }

  final AppPreferencesRepository _repository;

  Future<void> _onStarted(ThemeStarted event, Emitter<ThemeState> emit) async {
    try {
      final preferences = await _repository.getPreferences();
      emit(ThemeState(mode: preferences.themeMode));
    } catch (_) {
      emit(const ThemeState(errorMessage: 'Could not load theme preference.'));
    }
  }

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    final previous = state.mode;
    emit(ThemeState(mode: event.mode, isLoading: true));
    try {
      await _repository.update(
        (preferences) => preferences.copyWith(themeMode: event.mode),
      );
      emit(ThemeState(mode: event.mode));
    } catch (_) {
      emit(
        ThemeState(
          mode: previous,
          errorMessage:
              'Theme could not be saved. Your previous theme was restored.',
        ),
      );
    }
  }
}
