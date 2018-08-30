import 'package:test/test.dart';
import 'package:stak_swipe/tag.dart';

void main() {
  test('constructor test', (){
    TagList t = new TagList();
    expect(t.getPercent("popular", "reddit"), 100.0);  
  });
  
  test('test first like', (){
    TagList t = new TagList();
    t.like("testTag", "test");
    expect(t.getPercent("testTag", "reddit"), 5.0, );  
  });

  test('test first dislike', (){
    TagList t = new TagList();
    t.dislike("testTag");
    expect(t.getPercent("testTag", "reddit"), 0.0);  
  });

  test('test two likes', (){
    TagList t = new TagList();
    t.like("testTag");
    t.like("testTag");
    expect(t.getPercent("testTag", "reddit"), 6.2);  
  });

  test('test two dislikes', (){
    TagList t = new TagList();
    t.dislike("testTag");
    t.dislike("testTag");
    expect(t.getPercent("testTag", "reddit"), 0.0);  
  });

  

  test('test dislike then 10 likes', (){
    TagList t = new TagList();
    t.dislike("testTag");
    for(int i = 0; i<10; i++)
      t.like("testTag");
    expect(t.getPercent("testTag", "reddit"), 2.0);
  });
}