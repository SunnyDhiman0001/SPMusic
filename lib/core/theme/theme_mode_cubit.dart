import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'app_theme_mode';

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._prefs) : super(_readInitial(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readInitial(SharedPreferences prefs) {
    final stored = prefs.getString(_themeModeKey);
    return stored == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    await _prefs.setString(_themeModeKey, next == ThemeMode.light ? 'light' : 'dark');
  }
}
