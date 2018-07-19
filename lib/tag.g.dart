// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) =>
    new Tag(json['name'] as String, json['type'] as String)
      ..rating = json['rating'] as int
      ..likeMultiplier = json['likeMultiplier'] as int
      ..dislikeMultiplier = json['dislikeMultiplier'] as int
      ..listIndexes =
          (json['listIndexes'] as List)?.map((e) => e as int)?.toList();

abstract class _$TagSerializerMixin {
  int get rating;
  int get likeMultiplier;
  int get dislikeMultiplier;
  String get name;
  String get type;
  List<int> get listIndexes;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'rating': rating,
        'likeMultiplier': likeMultiplier,
        'dislikeMultiplier': dislikeMultiplier,
        'name': name,
        'type': type,
        'listIndexes': listIndexes
      };
}

Deficit _$DeficitFromJson(Map<String, dynamic> json) => new Deficit(
    json['def'] as int,
    (json['places'] as List)?.map((e) => e as int)?.toList());

abstract class _$DeficitSerializerMixin {
  int get def;
  List<int> get places;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'def': def, 'places': places};
}

TagList _$TagListFromJson(Map<String, dynamic> json) => new TagList()
  ..list = (json['list'] as List)?.map((e) => e as String)?.toList()
  ..allTags = (json['allTags'] as List)
      ?.map(
          (e) => e == null ? null : new Tag.fromJson(e as Map<String, dynamic>))
      ?.toList()
  ..def = json['def'] == null
      ? null
      : new Deficit.fromJson(json['def'] as Map<String, dynamic>);

abstract class _$TagListSerializerMixin {
  List<String> get list;
  List<Tag> get allTags;
  Deficit get def;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'list': list, 'allTags': allTags, 'def': def};
}
