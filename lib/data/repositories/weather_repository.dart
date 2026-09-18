import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../dummy/dummy_data.dart';
import '../models/models.dart';

/// Full forecast payload used by Home + Weather screens.
class WeatherBundle {
  const WeatherBundle({
    required this.current,
    required this.hourly,
    required this.weekly,
    required this.rainBars,
    required this.advisories,
  });

  final WeatherInfo current;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> weekly;
  final List<RainBar> rainBars;
  final List<AdvisoryItem> advisories;
}

class WeatherRepository {
  WeatherRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Pune fallback when GPS is unavailable.
  static const double fallbackLat = 18.5204;
  static const double fallbackLon = 73.8567;

  Future<WeatherBundle> fetchForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toStringAsFixed(4),
      'longitude': longitude.toStringAsFixed(4),
      'current': [
        'temperature_2m',
        'relative_humidity_2m',
        'weather_code',
        'wind_speed_10m',
        'uv_index',
        'precipitation_probability',
      ].join(','),
      'hourly': [
        'temperature_2m',
        'weather_code',
        'precipitation_probability',
        'precipitation',
      ].join(','),
      'daily': [
        'weather_code',
        'temperature_2m_max',
        'temperature_2m_min',
        'precipitation_probability_max',
      ].join(','),
      'timezone': 'auto',
      'forecast_days': '7',
      'wind_speed_unit': 'kmh',
    });

    final response = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Weather API error (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return _mapResponse(json);
  }

  WeatherBundle _mapResponse(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final hourly = json['hourly'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};

    final weatherCode = _asInt(current['weather_code']);
    final rainChance = _asInt(current['precipitation_probability']);
    final condition = OpenMeteoMapper.conditionLabel(weatherCode);
    final rainNote = rainChance >= 50
        ? 'Rain likely later today'
        : rainChance >= 30
            ? 'Chance of light rain'
            : 'Mostly dry conditions';

    final currentInfo = WeatherInfo(
      tempC: _asInt(current['temperature_2m']),
      condition: condition,
      humidity: _asInt(current['relative_humidity_2m']),
      windKmh: _asInt(current['wind_speed_10m']),
      uvIndex: _asInt(current['uv_index']),
      rainChance: rainChance,
      rainNote: rainNote,
    );

    final times = (hourly['time'] as List?)?.cast<String>() ?? const [];
    final temps = (hourly['temperature_2m'] as List?) ?? const [];
    final codes = (hourly['weather_code'] as List?) ?? const [];
    final precipProb = (hourly['precipitation_probability'] as List?) ?? const [];
    final precip = (hourly['precipitation'] as List?) ?? const [];

    final now = DateTime.now();
    var startIndex = 0;
    for (var i = 0; i < times.length; i++) {
      final t = DateTime.tryParse(times[i]);
      if (t != null && !t.isBefore(now.subtract(const Duration(minutes: 30)))) {
        startIndex = i;
        break;
      }
    }

    final hourlyItems = <HourlyWeather>[];
    for (var i = startIndex; i < times.length && hourlyItems.length < 6; i++) {
      final t = DateTime.tryParse(times[i]) ?? now;
      final isNow = hourlyItems.isEmpty;
      hourlyItems.add(
        HourlyWeather(
          label: isNow ? 'Now' : _hourLabel(t),
          tempC: _asInt(temps.length > i ? temps[i] : 0),
          icon: OpenMeteoMapper.icon(_asInt(codes.length > i ? codes[i] : 0)),
          isNow: isNow,
        ),
      );
    }

    final rainBars = <RainBar>[];
    for (var i = startIndex; i < times.length && rainBars.length < 8; i += 2) {
      final t = DateTime.tryParse(times[i]) ?? now;
      final mm = _asDouble(precip.length > i ? precip[i] : 0);
      final chance = _asInt(precipProb.length > i ? precipProb[i] : 0);
      final value = (mm / 8).clamp(0.08, 1.0);
      rainBars.add(
        RainBar(
          label: _hourLabel(t),
          value: chance > 0 || mm > 0 ? value : 0.08,
        ),
      );
    }

    final dayTimes = (daily['time'] as List?)?.cast<String>() ?? const [];
    final dayCodes = (daily['weather_code'] as List?) ?? const [];
    final highs = (daily['temperature_2m_max'] as List?) ?? const [];
    final lows = (daily['temperature_2m_min'] as List?) ?? const [];
    final dayPrecip = (daily['precipitation_probability_max'] as List?) ?? const [];

    final weekly = <DailyWeather>[];
    for (var i = 0; i < dayTimes.length && i < 7; i++) {
      final day = DateTime.tryParse(dayTimes[i]);
      weekly.add(
        DailyWeather(
          day: day == null ? '—' : _weekday(day),
          icon: OpenMeteoMapper.icon(_asInt(dayCodes.length > i ? dayCodes[i] : 0)),
          precipChance: _asInt(dayPrecip.length > i ? dayPrecip[i] : 0),
          high: _asInt(highs.length > i ? highs[i] : 0),
          low: _asInt(lows.length > i ? lows[i] : 0),
        ),
      );
    }

    return WeatherBundle(
      current: currentInfo,
      hourly: hourlyItems.isEmpty ? List.of(DummyData.hourly) : hourlyItems,
      weekly: weekly.isEmpty ? List.of(DummyData.weekly) : weekly,
      rainBars: rainBars.isEmpty ? List.of(DummyData.rainBars) : rainBars,
      advisories: OpenMeteoMapper.buildAdvisories(currentInfo, weekly),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String _hourLabel(DateTime t) {
    final hour = t.hour;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h $suffix';
  }

  static String _weekday(DateTime t) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[t.weekday - 1];
  }
}

class OpenMeteoMapper {
  OpenMeteoMapper._();

  static String conditionLabel(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Cloudy';
  }

  static IconData icon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.wb_cloudy;
    if (code <= 48) return Icons.cloud;
    if (code <= 67) return Icons.grain;
    if (code <= 77) return Icons.ac_unit;
    if (code <= 82) return Icons.umbrella;
    if (code <= 99) return Icons.thunderstorm;
    return Icons.cloud;
  }

  static List<AdvisoryItem> buildAdvisories(
    WeatherInfo current,
    List<DailyWeather> weekly,
  ) {
    final items = <AdvisoryItem>[];

    if (current.rainChance >= 50) {
      items.add(
        AdvisoryItem(
          icon: Icons.water_drop,
          color: Colors.blue,
          text:
              'Avoid irrigation today — rain chance about ${current.rainChance}%',
        ),
      );
      items.add(
        const AdvisoryItem(
          icon: Icons.block,
          color: Colors.red,
          text:
              'Do not apply fungicides before rain — dilution reduces effectiveness',
        ),
      );
    } else {
      items.add(
        AdvisoryItem(
          icon: Icons.water_drop,
          color: Colors.blue,
          text:
              'Irrigation OK if soil is dry — rain chance only ${current.rainChance}%',
        ),
      );
    }

    if (current.windKmh >= 20) {
      items.add(
        AdvisoryItem(
          icon: Icons.air,
          color: Colors.orange,
          text:
              'Strong winds (${current.windKmh} km/h) — delay pesticide sprays',
        ),
      );
    } else {
      items.add(
        const AdvisoryItem(
          icon: Icons.check_box,
          color: Colors.green,
          text: 'Good time for manual weeding in morning hours',
        ),
      );
    }

    final todayPrecip = weekly.isNotEmpty ? weekly.first.precipChance : 0;
    if (todayPrecip >= 60) {
      items.add(
        const AdvisoryItem(
          icon: Icons.grass,
          color: Colors.green,
          text: 'Transplanting seedlings: postpone until after heavy rain',
        ),
      );
    } else if (current.uvIndex >= 7) {
      items.add(
        AdvisoryItem(
          icon: Icons.wb_sunny,
          color: Colors.orange,
          text:
              'High UV (UV ${current.uvIndex}) — protect outdoor workers midday',
        ),
      );
    } else {
      items.add(
        const AdvisoryItem(
          icon: Icons.grass,
          color: Colors.green,
          text: 'Favorable conditions for field operations this afternoon',
        ),
      );
    }

    return items.take(4).toList();
  }
}
