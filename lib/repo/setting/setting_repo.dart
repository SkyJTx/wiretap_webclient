import 'package:wiretap_webclient/repo/setting/entry/base_entry.dart';
import 'package:wiretap_webclient/repo/setting/entry/theme_entry.dart';

class SettingRepo {
  static Future<void> init() async {
    for (var entry in entries) {
      await entry.init();
    }
  }

  static ThemeEntry get themeEntry => ThemeEntry();

  static List<BaseEntry> get entries => [
    themeEntry,
  ];
}