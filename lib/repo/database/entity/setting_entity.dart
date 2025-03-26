// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_ce/hive.dart';

class SettingEntity extends HiveObject {
  String name;
  String value;
  DateTime createdAt;
  DateTime updatedAt;

  SettingEntity({
    required this.name,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  SettingEntity copyWith({
    String? name,
    String? value,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettingEntity(
      name: name ?? this.name,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'value': value,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory SettingEntity.fromMap(Map<String, dynamic> map) {
    return SettingEntity(
      name: map['name'] as String,
      value: map['value'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingEntity.fromJson(String source) => SettingEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SettingEntity(name: $name, value: $value, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant SettingEntity other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.value == value &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      value.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
}
