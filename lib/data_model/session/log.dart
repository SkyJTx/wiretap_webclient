// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


class Log {
  final int id;
  final String type;
  final String data;
  final DateTime createdAt;

  Log({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Log copyWith({
    int? id,
    String? type,
    String? data,
    DateTime? createdAt,
  }) {
    return Log(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'] as int,
      type: map['type'] as String,
      data: map['data'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory Log.fromJson(String source) => Log.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Log(id: $id, type: $type, data: $data, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant Log other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.type == type &&
      other.data == data &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      type.hashCode ^
      data.hashCode ^
      createdAt.hashCode;
  }
}
