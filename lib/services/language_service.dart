import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();
  static LanguageService get instance => _instance;

  static const String _languageCodeKey = 'language_code';

  Locale _appLocale = const Locale('en');
  Locale get appLocale => _appLocale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);
    if (languageCode != null) {
      _appLocale = Locale(languageCode);
    }
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _appLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
    notifyListeners();
  }
}
