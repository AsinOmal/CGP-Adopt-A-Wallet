import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  LanguageProvider() {
    SharedPreferences.getInstance().then(
      (value) {
        var languageCode = value.getString('language_preference') ?? 'en';
        _locale = Locale(languageCode);
      },
    );
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    SharedPreferences.getInstance().then(
      (value) {
        value.setString('language_preference', locale.languageCode);
      },
    );
    notifyListeners();
  }
}
