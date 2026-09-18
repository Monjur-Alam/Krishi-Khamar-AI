import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/weather_repository.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  @override
  List<Object?> get props => [];
}

class WeatherStarted extends WeatherEvent {
  const WeatherStarted();
}

class WeatherRefreshRequested extends WeatherEvent {
  const WeatherRefreshRequested({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

class WeatherHourSelected extends WeatherEvent {
  const WeatherHourSelected(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class WeatherState extends Equatable {
  const WeatherState({
    this.advisories = const [],
    this.hourly = const [],
    this.weekly = const [],
    this.rainBars = const [],
    this.selectedHour = 0,
    this.isLoading = false,
    this.error,
    this.current,
  });

  final List<AdvisoryItem> advisories;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> weekly;
  final List<RainBar> rainBars;
  final int selectedHour;
  final bool isLoading;
  final String? error;
  final WeatherInfo? current;

  WeatherState copyWith({
    List<AdvisoryItem>? advisories,
    List<HourlyWeather>? hourly,
    List<DailyWeather>? weekly,
    List<RainBar>? rainBars,
    int? selectedHour,
    bool? isLoading,
    String? error,
    WeatherInfo? current,
    bool clearError = false,
  }) {
    return WeatherState(
      advisories: advisories ?? this.advisories,
      hourly: hourly ?? this.hourly,
      weekly: weekly ?? this.weekly,
      rainBars: rainBars ?? this.rainBars,
      selectedHour: selectedHour ?? this.selectedHour,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      current: current ?? this.current,
    );
  }

  @override
  List<Object?> get props => [
        advisories,
        hourly,
        weekly,
        rainBars,
        selectedHour,
        isLoading,
        error,
        current,
      ];
}

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc({WeatherRepository? weatherRepository})
      : _weatherRepository = weatherRepository ?? WeatherRepository(),
        super(const WeatherState(isLoading: true)) {
    on<WeatherStarted>(_onStarted);
    on<WeatherRefreshRequested>(_onRefresh);
    on<WeatherHourSelected>((e, emit) {
      emit(state.copyWith(selectedHour: e.index));
    });
  }

  final WeatherRepository _weatherRepository;

  Future<void> _onStarted(
    WeatherStarted event,
    Emitter<WeatherState> emit,
  ) async {
    emit(
      WeatherState(
        advisories: List.of(DummyData.advisories),
        hourly: List.of(DummyData.hourly),
        weekly: List.of(DummyData.weekly),
        rainBars: List.of(DummyData.rainBars),
        current: DummyData.weather,
        isLoading: true,
      ),
    );
    await _fetch(
      emit,
      WeatherRepository.fallbackLat,
      WeatherRepository.fallbackLon,
    );
  }

  Future<void> _onRefresh(
    WeatherRefreshRequested event,
    Emitter<WeatherState> emit,
  ) async {
    await _fetch(emit, event.latitude, event.longitude);
  }

  Future<void> _fetch(
    Emitter<WeatherState> emit,
    double lat,
    double lon,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final bundle = await _weatherRepository.fetchForecast(
        latitude: lat,
        longitude: lon,
      );
      emit(
        state.copyWith(
          current: bundle.current,
          advisories: bundle.advisories,
          hourly: bundle.hourly,
          weekly: bundle.weekly,
          rainBars: bundle.rainBars,
          selectedHour: 0,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Unable to load live weather. Showing last available data.',
        ),
      );
    }
  }
}
