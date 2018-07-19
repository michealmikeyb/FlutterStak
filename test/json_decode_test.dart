import 'package:test/test.dart';
import 'package:stak_swipe/placeList.dart';
import 'package:stak_swipe/tag.dart';
import 'dart:convert';

void main(){
  test('test taglist encode decode', (){
    JsonEncoder encoder = new JsonEncoder();
    JsonDecoder decoder = new JsonDecoder();
    TagList before = new TagList();
    before.like("test");
    String tagJson = encoder.convert(before);
    Map afterMap = decoder.convert(tagJson);
    TagList after = TagList.fromJson(afterMap);
    expect(after.getPercent("test", "reddit"), before.getPercent("test", "reddit"));
    expect(after.allTags.removeLast().name, before.allTags.removeLast().name);
  });
  test('test tag encode decode', (){
    JsonEncoder encoder = new JsonEncoder();
    JsonDecoder decoder = new JsonDecoder();
    Tag test = new Tag("test", "reddit");
    test.firstLike();
    String tagJson = encoder.convert(test);
    Map aftermap = decoder.convert(tagJson);
    Tag after = Tag.fromJson(aftermap);
    expect(after.rating, test.rating);
    expect(after.likeMultiplier, test.likeMultiplier);
  });

  test('test placelist encode decode', (){
    JsonEncoder encoder = new JsonEncoder();
    JsonDecoder decoder = new JsonDecoder();
    PlaceList before = new PlaceList();
    before.setPlace("test", "reddit", "1");
    String tagJson = encoder.convert(before);
    Map afterMap = decoder.convert(tagJson);
    PlaceList after = PlaceList.fromJson(afterMap);
    expect(after.getPlace("test", "reddit"), before.getPlace("test", "reddit"));
  });
}