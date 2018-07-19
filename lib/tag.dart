import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  int rating;
  int likeMultiplier;
  int dislikeMultiplier;
  String name;
  String type;
  List<int> listIndexes;

  Tag(this.name, this.type) {
    rating = 0;
    likeMultiplier = 50;
    dislikeMultiplier = 50;
    listIndexes = new List();
  }

  bool isNegative() {
    return rating < 0;
  }

  int firstLike() {
    rating = 500;
    likeMultiplier = 60;
    dislikeMultiplier = 40;
    return 500;
  }

  void addNumbers(List<int> list, bool alreadyIn) {
    for (int j in list) {
      listIndexes.add(j);
    }
    if (alreadyIn) {
      rating += list.length;
    }
  }

  List<int> takeNumbers(int i) {
    int numberOfPlaces = rating;
    List<int> removed = new List(i);
    if (i < numberOfPlaces) {
      for (int j = i; j > 0; j--) {
        removed[j - 1] = listIndexes.removeLast();
        numberOfPlaces--;
      }
      rating = numberOfPlaces;
      return removed;
    } else {
      for (int j = numberOfPlaces; j > 0; j--) {
        removed[j - 1] = listIndexes.removeLast();
        numberOfPlaces--;
      }
      rating = numberOfPlaces;
      return removed;
    }
  }

  int firstDislike() {
    rating = -200;
    dislikeMultiplier = 60;
    likeMultiplier = 40;
    return -200;
  }

  int dislike() {
    int deficit = 2 * dislikeMultiplier;
    if (dislikeMultiplier < 100) {
      dislikeMultiplier += 10;
      likeMultiplier -= 10;
    }
    return deficit;
  }

  int like() {
    int raise = 2 * likeMultiplier;
    if (likeMultiplier < 100) {
      likeMultiplier += 10;
      dislikeMultiplier -= 10;
    }
    return raise;
    
  }

  @override
  String toString() {
    return "tag name: $name tag rating: $rating";
  }

  Map<String, dynamic> toJson()=>{
    'likeMultiplier': likeMultiplier,
    'dislikeMultiplier': dislikeMultiplier,
    'listIndexes': listIndexes,
    'rating': rating,
    'name': name,
    'type': type,
  };

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
    /**:_likeMultiplier = json['likemultiplier'],
    _dislikeMultiplier = json['dislikemultiplier'],
    listIndexes = json['listindexes'],
    _rating = json['rating'],
    name = json['name'],
    type = json['type'];**/

}
@JsonSerializable()
class Deficit {
  int def;
  List<int> places;

  Deficit(this.def, this.places);

  List<int> give(int j) {
    if (def == 0) return null;
    int tempDef = def;
    List<int> numToGive = new List();
    for (int i = def; i > def - j && i > 1; i--) {
      numToGive.add(places[i - 1]);
      places[i - 1] = 0;
      tempDef -= 1;
    }
    def = tempDef;
    return numToGive;
  }

  void take(List<int> j) {
    for (int i in j) places.add(i);
    def = places.length;
  }

  Map<String, dynamic> toJson()=>{
    'def': def,
    'places': places,

  };

  factory Deficit.fromJson(Map<String, dynamic> json) => _$DeficitFromJson(json);
  /**:def = json['def'],
  places = json['places'].cast<int>();**/
}
@JsonSerializable()
class TagList {
  List<String> list;
  List<Tag> allTags;
  Deficit def;

  TagList() {
    allTags = new List();
    list = new List(10000);
    Tag popular = new Tag("popular", "reddit");

    for (int i = 0; i < 10000; i++) {
      list[i] = "popular";
    }
    allTags.add(popular);
    List<int> defList = new List();
    for (int i = 0; i < 8000; i++) {
      defList.add(i);
    }
    def = new Deficit(8000, defList);
  }

  void like(String tag) {
    if (tag == null) return;
    int raise = 0;
    int allTagsPlace = -1;
    bool alreadyIn = false;
    for (Tag t in allTags) {
      if (t.name == tag) {
        allTagsPlace = allTags.indexOf(t);
        alreadyIn = true;
        break;
      }
    }
     
    if (alreadyIn) {
      raise = allTags[allTagsPlace].like();
    
    } 
    else {
      Tag t = new Tag(tag, "reddit");
      raise = t.firstLike();
      allTags.add(t);
      allTagsPlace = allTags.length - 1;
    }
    if (def.def > 0) {
      if (raise < def.def) {
        List<int> numbers = def.give(raise);
        allTags[allTagsPlace].addNumbers(numbers, alreadyIn);
        for (int i in numbers) {
          list[i] = tag;
        }
      }
    } 
    else {
      int newRaise = def.def;
      List<int> numbers = def.give(newRaise);
      allTags[allTagsPlace].addNumbers(numbers, alreadyIn);
      for (int i in numbers){list[i] = tag;} 
    }
  }

  void dislike(String tag) {
    if (tag == null) return;
    int allTagsPlace = -1;
    bool alreadyIn = false;
    for (Tag t in allTags) {
      if (t.name == tag) {
        allTagsPlace = allTags.indexOf(t);
        alreadyIn = true;
        break;
      }
    }
    int deficit;
    if (alreadyIn) {
      deficit = allTags[allTagsPlace].dislike();

      if (allTags[allTagsPlace].isNegative())
        return;
      else {
        if (def.def - deficit < 10000) {
          List<int> nums = allTags[allTagsPlace].takeNumbers(deficit);
          def.take(nums);
        } else {
          int newDeficit = 10000 - def.def;
          def.take(allTags[allTagsPlace].takeNumbers(newDeficit));
        }
      }
    } else {
      Tag t = new Tag(tag, "reddit");
      t.firstDislike();
      allTags.add(t);
    }
  }

  String getTag() {
    Random generator = new Random.secure();
    int number = generator.nextInt(10000);
    while (list[number] == null) {
      list[number] = "popular";
      number = number = generator.nextInt(10000);
      List<int> nullNumber = [number];
      def.take(nullNumber);
    }
    return list[number];
  }

  double getPercent(String name, String source){
    double percent = 0.0;
    for(String s in list){
      if(s==name)
        percent += 0.01;
    }
    return percent;
  }

  String toString(){
    String s;
    for(Tag t in allTags){
      s+=(t.toString()+"\n");
    }
    return s;
  }

  Map<String, dynamic> toJson() =>{
    'list': list,
    'allTags': allTags,
    'def':def,
  };

  factory TagList.fromJson(Map<String, dynamic> json)=> _$TagListFromJson(json);
    /**:list = json['taglist'].cast<String>(),
    allTags = json['alltags'].cast<Tag>(),
    def = new Deficit.fromJson(json['def']);**/
}


