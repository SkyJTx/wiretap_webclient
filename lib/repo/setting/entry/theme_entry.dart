import 'package:flutter/material.dart';
import 'package:wiretap_webclient/repo/setting/entry/base_entry.dart';

class ThemeEntry extends BaseEntryWithOptions<ThemeMode> {
  ThemeEntry._internal()
    : super(
        key: 'theme',
        defaultValue: 'system',
        title: 'Theme',
        description: 'Select the theme for the app',
        options: {'light': ThemeMode.light, 'dark': ThemeMode.dark, 'system': ThemeMode.system},
      );

  static final ThemeEntry _instance = ThemeEntry._internal();

  factory ThemeEntry() => _instance;
}
