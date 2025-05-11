import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return; // Ensure locale is supported

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }
}

// Helper class to define supported locales (could be in a separate file)
class L10n {
  static final all = [
    const Locale('en'), // English
    const Locale('my'), // Myanmar
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸'; // Example flag
      case 'my':
        return '🇲🇲'; // Example flag
      default:
        return '🌐';
    }
  }
}
