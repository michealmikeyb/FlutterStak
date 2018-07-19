// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placeList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceList _$PlaceListFromJson(Map<String, dynamic> json) => new PlaceList()
  ..list = (json['list'] as List)
      ?.map((e) => e == null
          ? null
          : new PlaceHolder.fromJson(e as Map<String, dynamic>))
      ?.toList();

abstract class _$PlaceListSerializerMixin {
  List<PlaceHolder> get list;
  Map<String, dynamic> toJson() => <String, dynamic>{'list': list};
}
