import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('bn'));

  static const _key = 'app_locale';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'bn';
    emit(Locale(code));
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'bn'
        ? const Locale('en')
        : const Locale('bn');
    await setLocale(next);
  }

  String get languageLabel =>
      state.languageCode == 'bn' ? 'বাংলা' : 'English';
}
