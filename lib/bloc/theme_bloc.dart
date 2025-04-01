import 'package:flutter/material.dart';
import 'package:wiretap_webclient/component/state_manager/state_manager.dart';
import 'package:wiretap_webclient/repo/setting/setting_repo.dart';

class ThemeBloc extends Cubit<ThemeMode> {
  ThemeBloc.createInstance([super.initialState = ThemeMode.system]);

  static ThemeBloc? _instance;

  factory ThemeBloc() {
    _instance ??= ThemeBloc.createInstance();
    return _instance!;
  }

  void init() async {
    final themeString = await SettingRepo.themeEntry.value;
    final themeMode = SettingRepo.themeEntry.options[themeString];
    if (themeMode != null) {
      emit(themeMode);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> setTheme(ThemeMode theme) async {
    final themeString = SettingRepo.themeEntry.options.entries
        .firstWhere((element) => element.value == theme)
        .key;
    emit(theme);
    await SettingRepo.themeEntry.setValue(themeString);
  }

  Future<void> setThemeByString(String theme) async {
    final themeMode = SettingRepo.themeEntry.options[theme];
    if (themeMode != null) {
      emit(themeMode);
      await SettingRepo.themeEntry.setValue(theme);
    }
  }
}
