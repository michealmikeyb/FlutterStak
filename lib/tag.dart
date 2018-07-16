import 'dart:math';

class Tag {
  int _rating;
  int _likeMultiplier;
  int _dislikeMultiplier;
  String name;
  String type;
  List<int> listIndexes;

  Tag(this.name, this.type) {
    _rating = 0;
    _likeMultiplier = 50;
    _dislikeMultiplier = 50;
    listIndexes = new List();
  }

  bool isNegative() {
    return _rating < 0;
  }
  int get rating => _rating;

  int firstLike() {
    _rating = 500;
    _likeMultiplier = 60;
    _dislikeMultiplier = 40;
    return 500;
  }

  void addNumbers(List<int> list, bool alreadyIn) {
    for (int j in list) {
      listIndexes.add(j);
    }
    if (alreadyIn) {
      _rating += list.length;
    }
  }

  List<int> takeNumbers(int i) {
    int numberOfPlaces = _rating;
    List<int> removed = new List(i);
    if (i < numberOfPlaces) {
      for (int j = i; j > 0; j--) {
        removed[j - 1] = listIndexes.removeLast();
        numberOfPlaces--;
      }
      _rating = numberOfPlaces;
      return removed;
    } else {
      for (int j = numberOfPlaces; j > 0; j--) {
        removed[j - 1] = listIndexes.removeLast();
        numberOfPlaces--;
      }
      _rating = numberOfPlaces;
      return removed;
    }
  }

  int firstDislike() {
    _rating = -200;
    _dislikeMultiplier = 60;
    _likeMultiplier = 40;
    return -200;
  }

  int dislike() {
    int deficit = 2 * _dislikeMultiplier;
    if (_dislikeMultiplier < 100) {
      _dislikeMultiplier += 10;
      _likeMultiplier -= 10;
    }
    return deficit;
  }

  int like() {
    int raise = 2 * _likeMultiplier;
    if (_likeMultiplier < 100) {
      _likeMultiplier += 10;
      _dislikeMultiplier -= 10;
    }
    return raise;
  }

  @override
  String toString() {
    return "tag name: $name tag rating: $_rating";
  }
}

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
}

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
}

class PlaceHolder {
  String _place;
  String _source;
  String _name;

  PlaceHolder(this._name, this._place, this._source);

  String get place => _place;
  String get source => _source;
  String get name => _name;
  set place(p) => _place = p;
}

class PlaceList {
  List<PlaceHolder> list;

  PlaceList() {
    list = new List();
  }

  String getPlace(String tag, String source) {
    for (PlaceHolder p in list) {
      if (p.name == tag && p.source == source) return p.place;
    }
    list.add(new PlaceHolder(tag, "not in", source));
    return "not in";
  }

  void setPlace(String tag, String source, String place) {
    for (PlaceHolder p in list) {
      if (p.name == tag && p.source == source)
      p.place = place;
    }
  }
}
