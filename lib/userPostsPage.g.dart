// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userPostsPage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => new Post(
    json['title'] as String,
    json['score'] as String,
    json['link'] as String,
    json['tag'] as String);

abstract class _$PostSerializerMixin {
  String get title;
  String get score;
  String get link;
  String get tag;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'score': score,
        'link': link,
        'tag': tag
      };
}
