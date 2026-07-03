import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

class SettingsService {
  static const _themeKey = 'theme_mode_name';
  static const _appNameKey = 'app_name';

  Future<String> getThemeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? AppConstants.premiumTheme;
  }

  Future<void> setThemeName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }

  Future<String> getAppName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appNameKey) ?? AppConstants.defaultAppName;
  }

  Future<void> setAppName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final name = value.trim().isEmpty ? AppConstants.defaultAppName : value.trim();
    await prefs.setString(_appNameKey, name);
  }
}
