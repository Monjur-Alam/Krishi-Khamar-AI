import 'package:flutter/material.dart';

class L10n {
  L10n(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('bn'),
  ];

  bool get isBn => locale.languageCode == 'bn';

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n) ?? L10n(const Locale('en'));
  }

  String _t(String en, String bn) => isBn ? bn : en;

  // Common / nav
  String get appName => 'AgriVisionX AI';
  String get tagline =>
      _t('Smart Farming Powered by AI', 'এআই চালিত স্মার্ট কৃষি');
  String get home => _t('Home', 'হোম');
  String get aiChat => _t('AI Chat', 'এআই চ্যাট');
  String get scan => _t('Scan', 'স্ক্যান');
  String get weather => _t('Weather', 'আবহাওয়া');
  String get profile => _t('Profile', 'প্রোফাইল');
  String get language => _t('Language', 'ভাষা');
  String get english => _t('English', 'ইংরেজি');
  String get bangla => _t('Bangla', 'বাংলা');
  String get chooseLanguage =>
      _t('Choose language', 'ভাষা নির্বাচন করুন');
  String get cancel => _t('Cancel', 'বাতিল');
  String get logout => _t('Logout', 'লগআউট');
  String get settings => _t('Settings', 'সেটিংস');
  String get moreSettings => _t('More settings →', 'আরও সেটিংস →');
  String get viewAll => _t('View All', 'সব দেখুন');

  // Splash / login
  String get madeForFarmers =>
      _t('v1.0.0 • Made for Indian Farmers', 'v1.০.০ • কৃষকদের জন্য তৈরি');
  String get welcomeBack => _t('Welcome Back 👋', 'আবার স্বাগতম 👋');
  String get loginSubtitle => _t(
        'Login to access your farm dashboard',
        'ফার্ম ড্যাশবোর্ডে প্রবেশ করতে লগইন করুন',
      );
  String get mobileNumber => _t('Mobile Number', 'মোবাইল নম্বর');
  String get enterMobile =>
      _t('Enter your mobile number', 'আপনার মোবাইল নম্বর লিখুন');
  String get sendOtp => _t('Send OTP', 'ওটিপি পাঠান');
  String get orContinueWith =>
      _t('or continue with', 'অথবা চালিয়ে যান');
  String get continueWithGoogle =>
      _t('Continue with Google', 'গুগল দিয়ে চালিয়ে যান');
  String get newFarmer => _t('New farmer? ', 'নতুন কৃষক? ');
  String get registerNow => _t('Register Now', 'এখনই নিবন্ধন করুন');
  String get cropHealth => _t('Crop Health', 'ফসলের স্বাস্থ্য');
  String get mandiPrices => _t('Mandi Prices', 'মন্ডি দাম');

  // Home
  String get goodMorning => _t('Good Morning ⛅', 'শুভ সকাল ⛅');
  String get quickActions => _t('Quick Actions', 'দ্রুত কাজ');
  String get diseaseDetect => _t('Disease Detect', 'রোগ শনাক্ত');
  String get schemes => _t('Schemes', 'স্কিম');
  String get todaysWeather =>
      _t("TODAY'S WEATHER", 'আজকের আবহাওয়া');
  String get humidity => _t('Humidity', 'আর্দ্রতা');
  String get wind => _t('Wind', 'বাতাস');
  String get uvIndex => _t('UV Index', 'ইউভি সূচক');
  String get view7DayForecast =>
      _t('View 7-day forecast >', '৭ দিনের পূর্বাভাস দেখুন >');
  String get live => _t('Live', 'লাইভ');
  String get myCrops => _t('My Crops', 'আমার ফসল');
  String get governmentSchemes =>
      _t('Government Schemes', 'সরকারি স্কিম');
  String get schemesAvailable =>
      _t('3 schemes available for you', 'আপনার জন্য ৩টি স্কিম আছে');
  String get cropDiseaseDetection =>
      _t('Crop Disease Detection', 'ফসলের রোগ শনাক্তকরণ');
  String get scanCropsWithAi => _t(
        'Scan your crops with AI • 98% accuracy',
        'এআই দিয়ে ফসল স্ক্যান করুন • ৯৮% নির্ভুলতা',
      );
  String get noActiveDiseaseAlerts => _t(
        '✅ No active disease alerts — tap to scan a crop',
        '✅ কোনো সক্রিয় রোগ সতর্কতা নেই — স্ক্যান করতে ট্যাপ করুন',
      );
  String alertDetected(String crop, String diagnosis) => _t(
        '⚠️ Alert: $crop — $diagnosis',
        '⚠️ সতর্কতা: $crop — $diagnosis',
      );
  String get askFarming =>
      _t('Ask me anything about farming →', 'কৃষি নিয়ে যেকোনো প্রশ্ন করুন →');
  String get rainLikely => _t('Rain likely', 'বৃষ্টির সম্ভাবনা');

  // Chat
  String get kisanBotAi => 'KisanBot AI';
  String get onlinePoweredByOpenai =>
      _t('Online • Powered by OpenAI', 'অনলাইন • OpenAI চালিত');
  String get askAboutFarm =>
      _t('Ask about your farm...', 'আপনার খামার সম্পর্কে জিজ্ঞাসা করুন...');
  String get speakNow => _t('Speak now…', 'এখন বলুন…');
  String get listening =>
      _t('Listening… tap mic to stop', 'শুনছি… বন্ধ করতে মাইকে ট্যাপ করুন');
  String get takePhoto => _t('Take photo', 'ছবি তুলুন');
  String get chooseFromGallery =>
      _t('Choose from gallery', 'গ্যালারি থেকে বেছে নিন');
  String get attachFile => _t('Attach file', 'ফাইল সংযুক্ত করুন');
  String get micUnavailable => _t(
        'Microphone / speech not available',
        'মাইক্রোফোন / কণ্ঠস্বর উপলব্ধ নয়',
      );

  // Scan
  String get dropCropPhoto =>
      _t('Drop your crop photo here', 'এখানে ফসলের ছবি দিন');
  String get supportsJpg =>
      _t('Supports JPG, PNG • Max 10MB', 'JPG, PNG সমর্থিত • সর্বোচ্চ ১০MB');
  String get browsePhoto => _t('Browse Photo', 'ছবি ব্রাউজ করুন');
  String get captureWithCamera =>
      _t('Capture with Camera', 'ক্যামেরা দিয়ে তুলুন');
  String get takePhotoForAi => _t(
        'Take a photo for instant AI analysis',
        'তাৎক্ষণিক এআই বিশ্লেষণের জন্য ছবি তুলুন',
      );
  String get photoTips => _t('📸 Photo Tips', '📸 ছবির টিপস');
  String get recentScans => _t('Recent Scans', 'সাম্প্রতিক স্ক্যান');
  String get noScansYet => _t(
        'No scans yet. Capture a crop photo to get AI disease detection.',
        'এখনো কোনো স্ক্যান নেই। রোগ শনাক্ত করতে ফসলের ছবি তুলুন।',
      );
  String get analyzingCrop =>
      _t('Analyzing Crop...', 'ফসল বিশ্লেষণ করা হচ্ছে...');
  String get aiScanning => _t(
        'AI is scanning for diseases & deficiencies',
        'এআই রোগ ও ঘাটতি খুঁজছে',
      );
  String get leafTexture =>
      _t('Leaf texture analysis...', 'পাতার টেক্সচার বিশ্লেষণ...');
  String get diseasePattern =>
      _t('Disease pattern matching...', 'রোগের প্যাটার্ন মিলানো...');
  String get generatingRecs =>
      _t('Generating recommendations...', 'সুপারিশ তৈরি হচ্ছে...');
  String get aiPoweredAccuracy =>
      _t('AI-powered • 98% accuracy', 'এআই চালিত • ৯৮% নির্ভুলতা');
  String get treatmentPlan => _t('Treatment Plan', 'চিকিৎসা পরিকল্পনা');
  String get scanAnotherCrop =>
      _t('Scan Another Crop', 'আরেকটি ফসল স্ক্যান করুন');
  String get disease => _t('Disease', 'রোগ');
  String get severity => _t('Severity', 'তীব্রতা');
  String get spread => _t('Spread', 'বিস্তার');
  String get highRisk => _t('High Risk', 'উচ্চ ঝুঁকি');
  String get healthy => _t('Healthy', 'সুস্থ');
  String get medium => _t('Medium', 'মাঝারি');

  // Weather
  String get weatherAdvisory =>
      _t('Weather & Advisory', 'আবহাওয়া ও পরামর্শ');
  String get todaysFarmingAdvisory =>
      _t("Today's Farming Advisory", 'আজকের কৃষি পরামর্শ');
  String get hourlyForecast =>
      _t('Hourly Forecast', 'ঘণ্টাভিত্তিক পূর্বাভাস');
  String get sevenDayForecast =>
      _t('7-Day Forecast', '৭ দিনের পূর্বাভাস');
  String get rainPrediction =>
      _t('Rain Prediction', 'বৃষ্টির পূর্বাভাস');
  String get now => _t('Now', 'এখন');

  // Profile
  String get myProfile => _t('My Profile', 'আমার প্রোফাইল');
  String get verifiedFarmer =>
      _t('Verified Farmer', 'যাচাইকৃত কৃষক');
  String get farmArea => _t('Farm Area', 'খামারের এলাকা');
  String get crops => _t('Crops', 'ফসল');
  String get memberSince => _t('Member Since', 'সদস্য হয়েছেন');
  String get kisanCreditCard =>
      _t('KISAN CREDIT CARD', 'কিষাণ ক্রেডিট কার্ড');
  String get creditLimit => _t('CREDIT LIMIT', 'ক্রেডিট সীমা');
  String get validThru => _t('VALID THRU', 'মেয়াদ');
  String get farmDetails => _t('FARM DETAILS', 'খামারের বিবরণ');
  String get farmLocation => _t('Farm Location', 'খামারের অবস্থান');
  String get cropProfile => _t('Crop Profile', 'ফসল প্রোফাইল');
  String get preferences => _t('PREFERENCES', 'পছন্দসমূহ');
  String get notifications => _t('Notifications', 'নোটিফিকেশন');
  String get enabled => _t('Enabled', 'চালু');
  String get security => _t('SECURITY', 'নিরাপত্তা');
  String get privacySettings =>
      _t('Privacy Settings', 'গোপনীয়তা সেটিংস');
  String get helpSupport =>
      _t('Help & Support', 'সাহায্য ও সহায়তা');
  String get madeWithLove => _t(
        'AgriVisionX AI v1.0.0 • Made with ❤️ for Indian Farmers',
        'AgriVisionX AI v1.০.০ • কৃষকদের জন্য ❤️ দিয়ে তৈরি',
      );

  // Location status
  String get detectingLocation =>
      _t('Detecting location...', 'অবস্থান খোঁজা হচ্ছে...');
  String get locationDenied =>
      _t('Location permission denied', 'লোকেশন অনুমতি দেওয়া হয়নি');
  String get enableLocationSettings =>
      _t('Enable location in Settings', 'সেটিংসে লোকেশন চালু করুন');
  String get turnOnLocation =>
      _t('Turn on location services', 'লোকেশন সার্ভিস চালু করুন');
  String get locationUnavailable =>
      _t('Location unavailable', 'লোকেশন পাওয়া যায়নি');
  String get yourArea => _t('Your area', 'আপনার এলাকা');
}

class L10nDelegate extends LocalizationsDelegate<L10n> {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<L10n> load(Locale locale) async => L10n(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<L10n> old) => false;
}

extension L10nX on BuildContext {
  L10n get l10n => L10n.of(this);
}
