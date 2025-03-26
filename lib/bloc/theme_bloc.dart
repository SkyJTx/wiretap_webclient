import 'package:flutter/material.dart';
import 'package:wiretap_webclient/component/state_manager/state_manager.dart';
import 'package:wiretap_webclient/repo/setting/entry/theme_entry.dart';

class ThemeBloc extends Cubit<ThemeMode> {
  ThemeBloc.createInstance([super.initialState = ThemeMode.system]);

  static ThemeBloc? _instance;

  factory ThemeBloc() {
    _instance ??= ThemeBloc.createInstance();
    return _instance!;
  }

  void setTheme(ThemeMode theme) {
    emit(theme);
  }

  void setThemeByString(String theme) {
    final themeMode = ThemeEntry().options[theme];
    if (themeMode != null) {
      emit(themeMode);
    }
  }
}