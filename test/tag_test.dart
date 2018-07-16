import 'package:test/test.dart';
import 'package:stak_swipe/tag.dart';

void main() {
  Tag testTag;
  test('test constructor', (){
      testTag = new Tag("testTag", "reddit");
      expect(testTag.rating, 0, );
  });
  test('test firstlike', (){
    testTag = new Tag("testTag", "reddit");
    testTag.firstLike();
    expect(testTag.rating, 500, );

  });
  test('test firstdislike', (){
    testTag = new Tag("testTag", "reddit");
    testTag.firstDislike();
    expect(testTag.rating, -200, );

  });
  
  
}