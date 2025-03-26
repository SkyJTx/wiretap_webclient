import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:wiretap_webclient/hive/hive_registrar.g.dart';
import 'package:wiretap_webclient/repo/database/entity/setting_entity.dart';

const settingEntityBoxName = 'settingEntityBox';

class DatabaseRepo {
  static Box<SettingEntity>? _settingEntityBox;

  static Box<SettingEntity> get settingEntityBox {
    if (_settingEntityBox == null) {
      throw Exception('DatabaseRepo not initialized');
    }
    return _settingEntityBox!;
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    _settingEntityBox = await Hive.openBox<SettingEntity>(settingEntityBoxName);
  }
}
