// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserName _$UserNameFromJson(Map<String, dynamic> json) =>
    new UserName(json['name'] as String)..id = json['id'] as int;

abstract class _$UserNameSerializerMixin {
  String get name;
  int get id;
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'id': id};
}
