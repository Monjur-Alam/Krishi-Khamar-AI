import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus {
  initial,
  requesting,
  denied,
  permanentlyDenied,
  serviceDisabled,
  ready,
  error,
}

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.latitude,
    this.longitude,
    this.city,
    this.area,
    this.message,
  });

  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? area;
  final String? message;

  /// Prefer "City, Area/State"; fall back to coordinates or a short status.
  String get displayLabel {
    if (city != null && city!.isNotEmpty) {
      if (area != null && area!.isNotEmpty && area != city) {
        return '$city, $area';
      }
      return city!;
    }
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(3)}, ${longitude!.toStringAsFixed(3)}';
    }
    return switch (status) {
      LocationStatus.requesting => 'Detecting location...',
      LocationStatus.denied => 'Location permission denied',
      LocationStatus.permanentlyDenied => 'Enable location in Settings',
      LocationStatus.serviceDisabled => 'Turn on location services',
      LocationStatus.error => message ?? 'Location unavailable',
      _ => 'Location unavailable',
    };
  }

  String get cityLabel => city ?? 'Your area';

  bool get hasFix => latitude != null && longitude != null;

  LocationState copyWith({
    LocationStatus? status,
    double? latitude,
    double? longitude,
    String? city,
    String? area,
    String? message,
  }) {
    return LocationState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      area: area ?? this.area,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props =>
      [status, latitude, longitude, city, area, message];
}

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(const LocationState());

  Future<void> requestAndFetch() async {
    emit(state.copyWith(status: LocationStatus.requesting));

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(
        state.copyWith(
          status: LocationStatus.serviceDisabled,
          message: 'Location services are disabled',
        ),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      emit(state.copyWith(status: LocationStatus.denied));
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(status: LocationStatus.permanentlyDenied));
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      String? city;
      String? area;
      try {
        final places = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (places.isNotEmpty) {
          final p = places.first;
          city = p.locality?.isNotEmpty == true
              ? p.locality
              : (p.subAdministrativeArea?.isNotEmpty == true
                  ? p.subAdministrativeArea
                  : p.name);
          area = p.administrativeArea;
        }
      } catch (_) {
        // Coordinates alone are still useful if reverse geocode fails.
      }

      emit(
        LocationState(
          status: LocationStatus.ready,
          latitude: position.latitude,
          longitude: position.longitude,
          city: city,
          area: area,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationStatus.error,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
