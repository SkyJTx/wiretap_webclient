// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ErrorBase {
  final int statusCode;
  final String message;
  final String code;
  final Object? data;

  ErrorBase({
    required this.statusCode,
    required this.message,
    required this.code,
    this.data,
  });

  @override
  String toString() {
    return 'ErrorBase(statusCode: $statusCode, message: $message, code: $code, data: $data)';
  }

  ErrorBase copyWith({
    int? statusCode,
    String? message,
    String? code,
    Object? data,
  }) {
    return ErrorBase(
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      code: code ?? this.code,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'statusCode': statusCode,
      'message': message,
      'code': code,
      'data': data,
    };
  }

  factory ErrorBase.fromMap(Map<String, dynamic> map) {
    return ErrorBase(
      statusCode: map['statusCode'] as int,
      message: map['message'] as String,
      code: map['code'] as String,
      data: map['data'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ErrorBase.fromJson(String source) => ErrorBase.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant ErrorBase other) {
    if (identical(this, other)) return true;
  
    return 
      other.statusCode == statusCode &&
      other.message == message &&
      other.code == code &&
      other.data == data;
  }

  @override
  int get hashCode {
    return statusCode.hashCode ^
      message.hashCode ^
      code.hashCode ^
      data.hashCode;
  }
}
