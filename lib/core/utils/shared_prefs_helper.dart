import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  final SharedPreferences _prefs;

  SharedPrefsHelper(this._prefs);

  static const _hasOpenedHomeKey = 'hasOpenedHome';
  static const _hasCompletedOnboardingKey = 'hasCompletedOnboarding';
  static const _notificationsEnabledKey = 'notificationsEnabled';
  static const _themeModeKey = 'themeMode';
  static const _tokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessTokenExpiryKey = 'access_token_expiry';
  static const _refreshTokenExpiryKey = 'refresh_token_expiry';
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

  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> saveAccessTokenExpiry(String expiryUtc) async {
    await _prefs.setString(_accessTokenExpiryKey, expiryUtc);
  }

  String? getAccessTokenExpiry() {
    return _prefs.getString(_accessTokenExpiryKey);
  }

  Future<void> saveRefreshTokenExpiry(String expiryUtc) async {
    await _prefs.setString(_refreshTokenExpiryKey, expiryUtc);
  }

  String? getRefreshTokenExpiry() {
    return _prefs.getString(_refreshTokenExpiryKey);
  }

  /// Returns true if the stored access token is expired or will expire
  /// within [bufferSeconds] seconds (default 60 s).
  bool isAccessTokenExpired({int bufferSeconds = 60}) {
    final expiry = getAccessTokenExpiry();
    if (expiry == null || expiry.isEmpty) return true;
    try {
      final expiryDate = DateTime.parse(expiry).toLocal();
      return DateTime.now().isAfter(
        expiryDate.subtract(Duration(seconds: bufferSeconds)),
      );
    } catch (_) {
      return true;
    }
  }

  Future<void> saveUser(String userJson) async {
    await _prefs.setString(_userKey, userJson);
  }

  String? getUser() {
    return _prefs.getString(_userKey);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_accessTokenExpiryKey);
    await _prefs.remove(_refreshTokenExpiryKey);
    await _prefs.remove(_userKey);

    // Clear all persistent HTTP caches
    try {
      final keys = _prefs.getKeys().where((k) => k.startsWith('http_cache_')).toList();
      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (_) {}
  }
}
