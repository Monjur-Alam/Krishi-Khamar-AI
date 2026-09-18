import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/models.dart';

class DummyData {
  DummyData._();

  static const WeatherInfo weather = WeatherInfo(
    tempC: 29,
    condition: 'Partly Cloudy',
    humidity: 72,
    windKmh: 12,
    uvIndex: 6,
    rainChance: 68,
    rainNote: 'Rain expected by 4PM',
  );

  static const List<MandiPrice> mandiPrices = [
    MandiPrice(emoji: '🌾', name: 'Wheat', price: '₹2,180', changePercent: 1.2),
    MandiPrice(emoji: '🌽', name: 'Maize', price: '₹1,640', changePercent: -0.8),
    MandiPrice(
      emoji: '🫘',
      name: 'Soybean',
      price: '₹4,250',
      changePercent: 2.1,
    ),
  ];

  static const List<CropItem> crops = [
    CropItem(name: 'Wheat', emoji: '🌾', status: CropStatus.healthy),
    CropItem(name: 'Rice', emoji: '🌾', status: CropStatus.monitor),
    CropItem(name: 'Tomato', emoji: '🍅', status: CropStatus.alert),
  ];

  static const String kisanBotAlert =
      'Your tomato crop shows early signs of blight. Apply copper fungicide within 48 hours.';

  static const List<ChatMessage> chatHistory = [
    ChatMessage(
      text:
          'Namaste! 🙏 I\'m KisanBot AI, your smart farming assistant.\n\nI can help you with:\n• Crop disease diagnosis\n• Weather & irrigation advice\n• Fertilizer recommendations\n• Government schemes\n\nHow can I help your farm today?',
      sender: MessageSender.bot,
      time: '10:00 AM',
    ),
    ChatMessage(
      text: 'My tomato leaves are turning yellow, what should I do?',
      sender: MessageSender.user,
      time: '10:02 AM',
    ),
    ChatMessage(
      text:
          'Yellow leaves in tomatoes can indicate several issues:\n\n🔍 Possible Causes:\n• Nitrogen deficiency\n• Early Blight disease\n• Overwatering\n• Root rot\n\n💊 Immediate Action:\nApply 200ml of Urea solution (2%) spray on leaves. Ensure proper drainage.\n\n📷 You can also upload a photo for precise AI diagnosis!',
      sender: MessageSender.bot,
      time: '10:02 AM',
    ),
  ];

  static const List<String> suggestedQuestions = [
    'Best fertilizer for wheat?',
    'When to sow paddy?',
    'Pesticides for aphids?',
  ];

  static const List<CropScan> recentScans = [
    CropScan(
      crop: 'Tomato',
      diagnosis: 'Early Blight',
      timeAgo: '2 days ago',
      risk: ScanRisk.high,
      emoji: '🍅',
    ),
    CropScan(
      crop: 'Wheat',
      diagnosis: 'Healthy',
      timeAgo: '5 days ago',
      risk: ScanRisk.healthy,
      emoji: '🌾',
    ),
  ];

  static const List<String> photoTips = [
    'Capture affected leaves clearly',
    'Use natural daylight for best results',
    'Include the stem if disease spreads there',
    'Take multiple shots from different angles',
  ];

  static final DiseaseResult diseaseResult = DiseaseResult(
    name: 'Early Blight',
    scientificName: 'Alternaria solani',
    severity: 'High',
    matchPercent: 87,
    spread: '30% Leaves',
    description:
        'Early blight caused by Alternaria solani affects leaves, stems, and fruits. Characterized by dark brown spots with concentric rings (target-board pattern). Act immediately to prevent further spread.',
    treatments: const [
      TreatmentStep(
        number: 1,
        description: 'Remove infected leaves immediately',
        color: AppColors.danger,
      ),
      TreatmentStep(
        number: 2,
        description: 'Apply Copper Oxychloride 50% WP @ 3g/L',
        color: AppColors.danger,
      ),
      TreatmentStep(
        number: 3,
        description: 'Spray Mancozeb 75% WP as preventive measure',
        color: AppColors.warning,
      ),
      TreatmentStep(
        number: 4,
        description: 'Improve air circulation between plants',
        color: AppColors.success,
      ),
      TreatmentStep(
        number: 5,
        description: 'Avoid overhead irrigation',
        color: AppColors.warning,
      ),
    ],
  );

  static const List<AdvisoryItem> advisories = [
    AdvisoryItem(
      icon: Icons.water_drop,
      color: Colors.blue,
      text: 'Avoid irrigation today — rain expected in the evening',
    ),
    AdvisoryItem(
      icon: Icons.block,
      color: Colors.red,
      text: 'Do not apply fungicides before rain — dilution reduces effectiveness',
    ),
    AdvisoryItem(
      icon: Icons.check_box,
      color: Colors.green,
      text: 'Good time for manual weeding in morning hours',
    ),
    AdvisoryItem(
      icon: Icons.grass,
      color: Colors.green,
      text: 'Transplanting seedlings: Postpone to tomorrow after rain',
    ),
  ];

  static const List<HourlyWeather> hourly = [
    HourlyWeather(
      label: 'Now',
      tempC: 29,
      icon: Icons.wb_cloudy,
      isNow: true,
    ),
    HourlyWeather(label: '1 PM', tempC: 30, icon: Icons.wb_cloudy),
    HourlyWeather(label: '2 PM', tempC: 31, icon: Icons.wb_sunny),
    HourlyWeather(label: '3 PM', tempC: 30, icon: Icons.cloud),
    HourlyWeather(label: '4 PM', tempC: 28, icon: Icons.thunderstorm),
    HourlyWeather(label: '5 PM', tempC: 27, icon: Icons.grain),
  ];

  static const List<DailyWeather> weekly = [
    DailyWeather(
      day: 'Mon',
      icon: Icons.wb_cloudy,
      precipChance: 60,
      high: 29,
      low: 22,
    ),
    DailyWeather(
      day: 'Tue',
      icon: Icons.thunderstorm,
      precipChance: 85,
      high: 26,
      low: 20,
    ),
    DailyWeather(
      day: 'Wed',
      icon: Icons.grain,
      precipChance: 45,
      high: 27,
      low: 21,
    ),
    DailyWeather(
      day: 'Thu',
      icon: Icons.wb_sunny,
      precipChance: 10,
      high: 32,
      low: 24,
    ),
    DailyWeather(
      day: 'Fri',
      icon: Icons.wb_sunny,
      precipChance: 5,
      high: 33,
      low: 25,
    ),
    DailyWeather(
      day: 'Sat',
      icon: Icons.wb_cloudy,
      precipChance: 30,
      high: 30,
      low: 23,
    ),
    DailyWeather(
      day: 'Sun',
      icon: Icons.cloud,
      precipChance: 40,
      high: 28,
      low: 22,
    ),
  ];

  static const List<RainBar> rainBars = [
    RainBar(label: '6AM', value: 0.15),
    RainBar(label: '8AM', value: 0.25),
    RainBar(label: '10AM', value: 0.4),
    RainBar(label: '12PM', value: 0.55),
    RainBar(label: '2PM', value: 0.95),
    RainBar(label: '4PM', value: 0.7),
    RainBar(label: '6PM', value: 0.45),
    RainBar(label: '8PM', value: 0.3),
  ];

  static const UserProfile profile = UserProfile(
    name: 'Ramesh Kumar',
    phone: '+91 98765 43210',
    location: 'Pune, Maharashtra',
    farmArea: '4.5 Acres',
    activeCrops: '3 Active',
    memberSince: '2023',
    language: 'English',
    crops: 'Wheat, Tomato, Rice',
    cardLast4: '4821',
    creditLimit: '₹1,50,000',
    validThru: '12/2026',
    notificationsEnabled: true,
  );
}
