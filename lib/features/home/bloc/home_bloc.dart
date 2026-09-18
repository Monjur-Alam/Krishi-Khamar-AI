import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/weather_repository.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeWeatherRefreshRequested extends HomeEvent {
  const HomeWeatherRefreshRequested({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.userName,
    required this.location,
    required this.weather,
    required this.mandiPrices,
    required this.crops,
    required this.kisanBotAlert,
    this.weatherLoading = false,
    this.weatherError,
  });

  final String userName;
  final String location;
  final WeatherInfo weather;
  final List<MandiPrice> mandiPrices;
  final List<CropItem> crops;
  final String kisanBotAlert;
  final bool weatherLoading;
  final String? weatherError;

  HomeLoaded copyWith({
    WeatherInfo? weather,
    bool? weatherLoading,
    String? weatherError,
    bool clearWeatherError = false,
  }) {
    return HomeLoaded(
      userName: userName,
      location: location,
      weather: weather ?? this.weather,
      mandiPrices: mandiPrices,
      crops: crops,
      kisanBotAlert: kisanBotAlert,
      weatherLoading: weatherLoading ?? this.weatherLoading,
      weatherError: clearWeatherError ? null : (weatherError ?? this.weatherError),
    );
  }

  @override
  List<Object?> get props => [
        userName,
        location,
        weather,
        mandiPrices,
        crops,
        kisanBotAlert,
        weatherLoading,
        weatherError,
      ];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({WeatherRepository? weatherRepository})
      : _weatherRepository = weatherRepository ?? WeatherRepository(),
        super(const HomeLoading()) {
    on<HomeStarted>(_onStarted);
    on<HomeWeatherRefreshRequested>(_onWeatherRefresh);
  }

  final WeatherRepository _weatherRepository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(
      HomeLoaded(
        userName: DummyData.profile.name,
        location: DummyData.profile.location,
        weather: DummyData.weather,
        mandiPrices: DummyData.mandiPrices,
        crops: DummyData.crops,
        kisanBotAlert: DummyData.kisanBotAlert,
        weatherLoading: true,
      ),
    );

    // Load with fallback coords until GPS arrives.
    await _loadWeather(
      emit,
      WeatherRepository.fallbackLat,
      WeatherRepository.fallbackLon,
    );
  }

  Future<void> _onWeatherRefresh(
    HomeWeatherRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadWeather(emit, event.latitude, event.longitude);
  }

  Future<void> _loadWeather(
    Emitter<HomeState> emit,
    double lat,
    double lon,
  ) async {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(weatherLoading: true, clearWeatherError: true));
    }

    try {
      final bundle = await _weatherRepository.fetchForecast(
        latitude: lat,
        longitude: lon,
      );
      final loaded = state;
      if (loaded is HomeLoaded) {
        emit(
          loaded.copyWith(
            weather: bundle.current,
            weatherLoading: false,
            clearWeatherError: true,
          ),
        );
      }
    } catch (e) {
      final loaded = state;
      if (loaded is HomeLoaded) {
        emit(
          loaded.copyWith(
            weatherLoading: false,
            weatherError: 'Could not refresh weather',
          ),
        );
      }
    }
  }
}
