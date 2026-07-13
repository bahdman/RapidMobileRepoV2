import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rapid_app/core/utils/shared_prefs_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPrefsHelper _prefsHelper;

  ThemeCubit(this._prefsHelper) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final modeStr = _prefsHelper.getThemeMode();
    if (modeStr == 'dark') {
      emit(ThemeMode.dark);
    } else if (modeStr == 'light') {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _prefsHelper.setThemeMode(isDark ? 'dark' : 'light');
    emit(mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String modeStr;
    switch (mode) {
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
    }
    await _prefsHelper.setThemeMode(modeStr);
    emit(mode);
  }
}
