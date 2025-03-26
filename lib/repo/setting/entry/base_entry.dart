import 'dart:async';

import 'package:wiretap_webclient/constant/error.dart';
import 'package:wiretap_webclient/repo/database/database_repo.dart';
import 'package:wiretap_webclient/repo/database/entity/setting_entity.dart';

abstract class BaseEntry {
  final String key;
  final String defaultValue;
  final bool defaultEnabled;
  final String title;
  final String? description;

  BaseEntry({
    required this.key,
    required this.defaultValue,
    this.defaultEnabled = false,
    required this.title,
    this.description,
  });

  Map<String, Object?> get params => {
    'key': key,
    'defaultValue': defaultValue,
    'defaultEnabled': defaultEnabled,
    'title': title,
    'description': description,
    'options': null,
  };

  /// Construct the entry.
  /// If not overriden, it will return itself
  FutureOr<BaseEntry> rebase() async {
    return this;
  }

  Future<void> init() async {
    final box = DatabaseRepo.settingEntityBox;
    if (!box.containsKey(key)) {
      await box.put(
        key,
        SettingEntity(
          name: key,
          value: defaultValue,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<bool> get isEnabled async => defaultEnabled;

  Future<String> get value {
    final box = DatabaseRepo.settingEntityBox;
    final entity = box.get(key);
    if (entity == null) throw settingNotFoundError;
    return Future.value(entity.value);
  }

  Future<void> setValue(String value) {
    final box = DatabaseRepo.settingEntityBox;
    final entity = box.get(key);
    if (entity == null) throw settingNotFoundError;
    return box.put(
      key,
      entity.copyWith(
        value: value,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> reset() {
    final box = DatabaseRepo.settingEntityBox;
    final entity = box.get(key);
    if (entity == null) throw settingNotFoundError;
    return box.put(
      key,
      entity.copyWith(
        value: defaultValue,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> delete() async {
    final box = DatabaseRepo.settingEntityBox;
    return await box.delete(key);
  }
}

mixin Options<T> on BaseEntry {
  Map<String, T> _options = {};

  Map<String, T> get options => _options;
}

abstract class BaseEntryWithOptions<T> extends BaseEntry with Options<T> {
  BaseEntryWithOptions({
    required super.key,
    required super.defaultValue,
    super.defaultEnabled,
    required super.title,
    super.description,
    required Map<String, T> options,
  }) {
    _options = options;
  }

  @override
  get params => super.params..['options'] = options;

  @override
  Future<void> init() async {
    final box = DatabaseRepo.settingEntityBox;
    final entity = box.get(key);
    if (entity == null) {
      await box.put(
        key,
        SettingEntity(
          name: key,
          value: defaultValue,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } else if (!options.containsKey(entity.value)) {
      await box.put(
        key,
        entity.copyWith(
          value: defaultValue,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> setValue(String value) {
    if (!options.containsKey(value)) throw settingIsNotInTheOptionsError;

    return super.setValue(value);
  }
}
