import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:wiretap_webclient/hive/hive_registrar.g.dart';
import 'package:wiretap_webclient/repo/database/entity/setting_entity.dart';

const settingEntityBoxName = 'settingEntityBox';
const userBoxName = 'userBox';
const userBoxKey = (
  token: 'token',
  self: 'self', // UserSafe
);

class DatabaseRepo {
  static Box<SettingEntity>? _settingEntityBox;
  static Box? _userBox;

  static Box<SettingEntity> get settingEntityBox {
    if (_settingEntityBox == null) {
      throw Exception('DatabaseRepo not initialized');
    }
    return _settingEntityBox!;
  }

  static Box get userBox {
    if (_userBox == null) {
      throw Exception('DatabaseRepo not initialized');
    }
    return _userBox!;
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    _settingEntityBox = await Hive.openBox<SettingEntity>(settingEntityBoxName);
    _userBox = await Hive.openBox(userBoxName);
  }
}
