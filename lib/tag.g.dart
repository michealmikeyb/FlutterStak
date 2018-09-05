// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) {
  return new Tag(json['name'] as String, json['type'] as String)
    ..rating = json['rating'] as int
    ..likeMultiplier = json['likeMultiplier'] as int
    ..dislikeMultiplier = json['dislikeMultiplier'] as int
    ..listIndexes =
        (json['listIndexes'] as List)?.map((e) => e as int)?.toList();
}

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

SourceName _$SourceNameFromJson(Map<String, dynamic> json) {
  return new SourceName(json['name'] as String, json['source'] as String);
}

abstract class _$SourceNameSerializerMixin {
  String get source;
  String get name;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'source': source, 'name': name};
}

Deficit _$DeficitFromJson(Map<String, dynamic> json) {
  return new Deficit(json['def'] as int,
      (json['places'] as List)?.map((e) => e as int)?.toList());
}

abstract class _$DeficitSerializerMixin {
  int get def;
  List<int> get places;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'def': def, 'places': places};
}

TagList _$TagListFromJson(Map<String, dynamic> json) {
  return new TagList()
    ..list = (json['list'] as List)
        ?.map((e) => e == null
            ? null
            : new SourceName.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..allTags = (json['allTags'] as List)
        ?.map((e) =>
            e == null ? null : new Tag.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..def = json['def'] == null
        ? null
        : new Deficit.fromJson(json['def'] as Map<String, dynamic>)
    ..lastTag = json['lastTag'] == null
        ? null
        : new SourceName.fromJson(json['lastTag'] as Map<String, dynamic>);
}

abstract class _$TagListSerializerMixin {
  List<SourceName> get list;
  List<Tag> get allTags;
  Deficit get def;
  SourceName get lastTag;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'list': list,
        'allTags': allTags,
        'def': def,
        'lastTag': lastTag
      };
}
