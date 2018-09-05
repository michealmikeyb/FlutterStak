// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placeList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceList _$PlaceListFromJson(Map<String, dynamic> json) {
  return new PlaceList()
    ..list = (json['list'] as List)
        ?.map((e) => e == null
            ? null
            : new PlaceHolder.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..lastReset = json['lastReset'] == null
        ? null
        : DateTime.parse(json['lastReset'] as String);
}

abstract class _$PlaceListSerializerMixin {
  List<PlaceHolder> get list;
  DateTime get lastReset;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'list': list,
        'lastReset': lastReset?.toIso8601String()
      };
}
