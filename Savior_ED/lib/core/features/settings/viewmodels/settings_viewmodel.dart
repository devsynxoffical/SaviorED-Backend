import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _darkTheme = false;
  String _language = 'English';
  String _colorScheme = 'blue';

  bool get darkTheme => _darkTheme;
  String get language => _language;
  String get colorScheme => _colorScheme;
  ThemeMode get themeMode => _darkTheme ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    await _storageService.ensureInitialized();
    final isDark = _storageService.getBool('profile_dark_theme');
    final lang = _storageService.getString('profile_language');
    final scheme = _storageService.getString('profile_color_scheme');

    if (isDark != null) _darkTheme = isDark;
    if (lang != null) _language = lang;
    if (scheme != null) _colorScheme = scheme;

    notifyListeners();
  }

  Future<void> setDarkTheme(bool value) async {
    _darkTheme = value;
    await _storageService.saveBool('profile_dark_theme', value);
    notifyListeners();
  }

  Future<void> setScheme(String value) async {
    _colorScheme = value;
    await _storageService.saveString('profile_color_scheme', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _storageService.saveString('profile_language', value);
    notifyListeners();
  }
}
