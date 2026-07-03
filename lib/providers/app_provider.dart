import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/work_record.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../utils/app_constants.dart';

class AppProvider extends ChangeNotifier {
  final AuthService authService;
  final SettingsService settingsService;
  final DatabaseHelper databaseHelper;

  AppProvider({
    required this.authService,
    required this.settingsService,
    required this.databaseHelper,
  });

  bool _isReady = false;
  bool _isLoggedIn = false;
  String _themeName = AppConstants.premiumTheme;
  String _appName = AppConstants.defaultAppName;
  ReportSummary _summary = ReportSummary.empty();
  WorkRecord? _lastRecord;

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  String get themeName => _themeName;
  String get appName => _appName;
  ReportSummary get summary => _summary;
  WorkRecord? get lastRecord => _lastRecord;

  Future<void> init() async {
    await authService.ensureDefaults();
    _isLoggedIn = await authService.isLoggedIn();
    _themeName = await settingsService.getThemeName();
    _appName = await settingsService.getAppName();
    await refreshDashboard();
    _isReady = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password, bool rememberMe) async {
    final ok = await authService.login(username: username, password: password, rememberMe: rememberMe);
    _isLoggedIn = ok;
    if (ok) await refreshDashboard();
    notifyListeners();
    return ok;
  }

  Future<void> logout() async {
    await authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    _summary = await databaseHelper.getSummary();
    _lastRecord = await databaseHelper.getLastRecord();
    notifyListeners();
  }

  Future<void> setTheme(String value) async {
    _themeName = value;
    await settingsService.setThemeName(value);
    notifyListeners();
  }

  Future<void> setAppName(String value) async {
    await settingsService.setAppName(value);
    _appName = await settingsService.getAppName();
    notifyListeners();
  }

  Future<void> changePassword(String password) async {
    await authService.changePassword(password);
  }

  Future<void> clearAllData() async {
    await databaseHelper.clearAll();
    await refreshDashboard();
  }
}
