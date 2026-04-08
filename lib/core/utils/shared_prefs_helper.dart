import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  final SharedPreferences _prefs;

  SharedPrefsHelper(this._prefs);

  static const _hasOpenedHomeKey = 'hasOpenedHome';
  static const _hasCompletedOnboardingKey = 'hasCompletedOnboarding';
  static const _notificationsEnabledKey = 'notificationsEnabled';
  static const _themeModeKey = 'themeMode';
  static const _tokenKey = 'access_token';
  static const _userKey = 'user_data';

  Future<void> setHasOpenedHome(bool value) async {
    await _prefs.setBool(_hasOpenedHomeKey, value);
  }

  bool hasOpenedHome() {
    return _prefs.getBool(_hasOpenedHomeKey) ?? false;
  }

  Future<void> setHasCompletedOnboarding(bool value) async {
    await _prefs.setBool(_hasCompletedOnboardingKey, value);
  }

  bool hasCompletedOnboarding() {
    return _prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_notificationsEnabledKey, value);
  }

  bool areNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setThemeMode(String value) async {
    await _prefs.setString(_themeModeKey, value);
  }

  String getThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> saveUser(String userJson) async {
    await _prefs.setString(_userKey, userJson);
  }

  String? getUser() {
    return _prefs.getString(_userKey);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }
}
