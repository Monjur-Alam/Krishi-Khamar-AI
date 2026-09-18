import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MandiPrice extends Equatable {
  const MandiPrice({
    required this.emoji,
    required this.name,
    required this.price,
    required this.changePercent,
  });

  final String emoji;
  final String name;
  final String price;
  final double changePercent;

  bool get isUp => changePercent >= 0;

  @override
  List<Object?> get props => [emoji, name, price, changePercent];
}

enum CropStatus { healthy, monitor, alert }

class CropItem extends Equatable {
  const CropItem({
    required this.name,
    required this.emoji,
    required this.status,
  });

  final String name;
  final String emoji;
  final CropStatus status;

  String get statusLabel => switch (status) {
        CropStatus.healthy => 'Healthy',
        CropStatus.monitor => 'Monitor',
        CropStatus.alert => 'Disease Alert',
      };

  @override
  List<Object?> get props => [name, emoji, status];
}

class WeatherInfo extends Equatable {
  const WeatherInfo({
    required this.tempC,
    required this.condition,
    required this.humidity,
    required this.windKmh,
    required this.uvIndex,
    required this.rainChance,
    required this.rainNote,
  });

  final int tempC;
  final String condition;
  final int humidity;
  final int windKmh;
  final int uvIndex;
  final int rainChance;
  final String rainNote;

  @override
  List<Object?> get props =>
      [tempC, condition, humidity, windKmh, uvIndex, rainChance, rainNote];
}

enum MessageSender { user, bot }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
  });

  final String text;
  final MessageSender sender;
  final String time;

  bool get isBot => sender == MessageSender.bot;

  @override
  List<Object?> get props => [text, sender, time];
}

enum ScanRisk { high, healthy, medium }

class CropScan extends Equatable {
  const CropScan({
    required this.crop,
    required this.diagnosis,
    required this.timeAgo,
    required this.risk,
    required this.emoji,
  });

  final String crop;
  final String diagnosis;
  final String timeAgo;
  final ScanRisk risk;
  final String emoji;

  String get riskLabel => switch (risk) {
        ScanRisk.high => 'High Risk',
        ScanRisk.healthy => 'Healthy',
        ScanRisk.medium => 'Medium',
      };

  @override
  List<Object?> get props => [crop, diagnosis, timeAgo, risk, emoji];
}

class TreatmentStep extends Equatable {
  const TreatmentStep({
    required this.number,
    required this.description,
    required this.color,
  });

  final int number;
  final String description;
  final Color color;

  @override
  List<Object?> get props => [number, description, color];
}

class DiseaseResult extends Equatable {
  const DiseaseResult({
    required this.name,
    required this.scientificName,
    required this.severity,
    required this.matchPercent,
    required this.spread,
    required this.description,
    required this.treatments,
  });

  final String name;
  final String scientificName;
  final String severity;
  final int matchPercent;
  final String spread;
  final String description;
  final List<TreatmentStep> treatments;

  @override
  List<Object?> get props => [
        name,
        scientificName,
        severity,
        matchPercent,
        spread,
        description,
        treatments,
      ];
}

class AdvisoryItem extends Equatable {
  const AdvisoryItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  List<Object?> get props => [icon, color, text];
}

class HourlyWeather extends Equatable {
  const HourlyWeather({
    required this.label,
    required this.tempC,
    required this.icon,
    this.isNow = false,
  });

  final String label;
  final int tempC;
  final IconData icon;
  final bool isNow;

  @override
  List<Object?> get props => [label, tempC, icon, isNow];
}

class DailyWeather extends Equatable {
  const DailyWeather({
    required this.day,
    required this.icon,
    required this.precipChance,
    required this.high,
    required this.low,
  });

  final String day;
  final IconData icon;
  final int precipChance;
  final int high;
  final int low;

  @override
  List<Object?> get props => [day, icon, precipChance, high, low];
}

class RainBar extends Equatable {
  const RainBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  List<Object?> get props => [label, value];
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.location,
    required this.farmArea,
    required this.activeCrops,
    required this.memberSince,
    required this.language,
    required this.crops,
    required this.cardLast4,
    required this.creditLimit,
    required this.validThru,
    required this.notificationsEnabled,
  });

  final String name;
  final String phone;
  final String location;
  final String farmArea;
  final String activeCrops;
  final String memberSince;
  final String language;
  final String crops;
  final String cardLast4;
  final String creditLimit;
  final String validThru;
  final bool notificationsEnabled;

  @override
  List<Object?> get props => [
        name,
        phone,
        location,
        farmArea,
        activeCrops,
        memberSince,
        language,
        crops,
        cardLast4,
        creditLimit,
        validThru,
        notificationsEnabled,
      ];
}
