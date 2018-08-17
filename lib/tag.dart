/**
 * this file holds the algorithm for handling which tags are seen and adjusting
 * them to the users interest. it revolves around a taglist, a list of 10,000
 * numbers which is randomly selected from to give the user a tag. likes and dislikes 
 * increase or decrease the indeces occupied by the tag in the list thus making it
 * more or less likely to be chosen.
 */
import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
part 'tag.g.dart';

/**
 * this holds a tag which will be the base for the taglist
 * that decides what content the user views. it has like and dislike
 * finctions that will increase the ratings and spaces within 
 * the taglist thus making them more common.
 */
@JsonSerializable()
class Tag {
  int rating; //the rating out of 10,000 of the tag
  int likeMultiplier; //the like multiplier, goes up as the user likes the tag consecutively
  int dislikeMultiplier; //goes up if the user dislikes the tag consecutively
  String name; //the name of the tag
  String type; //the type/ where the tag came from
  List<int>
      listIndexes; //the list of indexes within the taglist that the tag holds

  /**tags start off with a rating of 0 and a 50/50 like/dislike multiplier
   * @param name the name of the tag being made
   * @param type the type/source of the tag
 * **/
  Tag(this.name, this.type) {
    rating = 0;
    likeMultiplier = 50;
    dislikeMultiplier = 50;
    listIndexes = new List();
  }
/**
 * checks if the rating of the tag is negative
 */
  bool isNegative() {
    return rating < 0;
  }

  /**
   * on the first like the tag is given a rating of 500 to start
   * off corresponding to 5% in the taglist
   */
  int firstLike() {
    rating = 500;
    likeMultiplier = 60;
    dislikeMultiplier = 40;
    return 500;
  }

  /**
   * used to add numbers to the list indexes once
   * those numbers have been assigned by the taglist/deficit. 
   * if the tag is not already in the tag list then the 
   * first like/dislike handles the rating increase
   * @param list the list of numbers to add
   * @param alreadyin whether the tag is already in the taglist
   */
  void addNumbers(List<int> list, bool alreadyIn) {
    for (int j in list) {
      listIndexes.add(j);
    }
    if (alreadyIn) {
      rating += list.length;
    }
  }

/**
 * takes a given amount of numbers from the lstindexes
 * to allow them to be available in the taglist
 * @param i the amount of numbers to be taken
 */
  List<int> takeNumbers(int i) {
    int numberOfPlaces =
        rating; //the maximum number of places that can be taken
    List<int> removed = new List(i); //the list to store the new numbers
    if (i < numberOfPlaces) {
      //if it can take the amount take them and adjust the rating
      for (int j = i; j > 0; j--) {
        removed[j - 1] = listIndexes.removeLast();
        numberOfPlaces--;
      }
      rating = numberOfPlaces;
      return removed;
    } else {
      //otherwise take all the numbers and adjust the rating
      for (int j = numberOfPlaces; j > 0; j--) {
        removed[j - 1] = listIndexes.removeLast();
        numberOfPlaces--;
      }
      rating = numberOfPlaces;
      return removed;
    }
  }

  /**
   * on the first dislike it gives it a -2 rating 
   * and adjusts multipliers according to a regular 
   * dislike
   */
  int firstDislike() {
    rating = -200;
    dislikeMultiplier = 60;
    likeMultiplier = 40;
    return -200;
  }

  /**
   * lowers the rating by an amount based on the dislike
   * multiplier and reduces the like multiplier
   * and iterates the dislike multiplier.
   */
  int dislike() {
    int deficit = 2 * dislikeMultiplier;
    if (dislikeMultiplier < 100) {
      dislikeMultiplier += 10;
      likeMultiplier -= 10;
    }
    return deficit;
  }

  /**
   * increases the rating by an amount determined by the 
   * like multiplier then decrements the dislike multiplier
   * then increments the like multiplier
   */
  int like() {
    int raise = 2 * likeMultiplier;
    if (likeMultiplier < 100) {
      likeMultiplier += 10;
      dislikeMultiplier -= 10;
    }
    return raise;
  }

  /**
   * to string function in the format "tag name: name tag rating: rating"
   */
  @override
  String toString() {
    return "tag name: $name tag rating: $rating";
  }

  /**
   * used in converting the tag into a json for storage
   * 
   */
  Map<String, dynamic> toJson() => {
        'likeMultiplier': likeMultiplier,
        'dislikeMultiplier': dislikeMultiplier,
        'listIndexes': listIndexes,
        'rating': rating,
        'name': name,
        'type': type,
      };
/**
 * used in converting the tag from a json  from storage
 */
  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@JsonSerializable()
class SourceName {
  String source;
  String name;

  SourceName(this.name, this.source);

  Map<String, dynamic> toJson()=>{
    'source': source,
    'name': name,
  };

  factory SourceName.fromJson(Map<String, dynamic> json) => _$SourceNameFromJson(json);
}

/**
 * holds the available indexes in the taglist
 * that can be reassigned
 */
@JsonSerializable()
class Deficit {
  int def; //the size of the deficit
  List<int> places; //the indexes of the open places in the taglist

  Deficit(this.def, this.places);
/**
 * gives the given amount of indexes from the 
 * list of the places to be reassigned to another
 * tag
 * @param j amount of numbers to give to be reassigned
 */
  List<int> give(int j) {
    places.remove(null);
    def = places.length;
    if (def == 0) return null;
    int tempDef =
        def; //so the deficit can be used for the stop condition in the for loop
    List<int> numToGive = new List(); //list to store the given numbers
    for (int i = def; i > def - j && i > 1; i--) {
      //go through the list j times if possible
      if(places[i-1] != null){
      numToGive.add(places[i - 1]); //copy the number
      places.removeAt(i - 1); //get rid of that number
      tempDef -= 1; //update the tempdef
      }
    }
    def = tempDef; //put the tempdef as the deficit
    return numToGive;
  }

  /**
   * take the numbers given and add them to the
   * deficit/ places list
   * @param j the list of numbers to add to places
   */
  void take(List<int> j) {
    for (int i in j){ 
      places.add(i); //add all the new indeces
      if(i==null)
        print("inserting null");
    }
    def = places.length; //update the def
  }

  /**
   * used in storing the deficit in json form
   */
  Map<String, dynamic> toJson() => {
        'def': def,
        'places': places,
      };
  /**
   * used in remaking the deficit after its been 
   * recovered from storage
   */
  factory Deficit.fromJson(Map<String, dynamic> json) =>
      _$DeficitFromJson(json);
}

@JsonSerializable()
class TagList {
  List<SourceName> list; //the list of names that will be randomly selected from
  List<Tag> allTags; //all of the tags in the list with their ratings
  Deficit def; //the def where the available indeces will be stored
  SourceName lastTag;
/**
 * creates a new taglist filled with the reddit popular tag
 * and assigning 80% of them as available
 */
  TagList() {
    allTags = new List(); //initialize the lists
    list = new List(10000);
    Tag popular = new Tag("popular", "reddit"); //create a new popular tag
    SourceName popularsn = new SourceName("popular", "reddit");

    for (int i = 0; i < 10000; i++) {
      //fill the list with popular
      list[i] = popularsn;
    }
    allTags.add(popular); //add it to alltags
    List<int> defList =
        new List(); //make 80% available by adding 8000 numbers to the deficit
    for (int i = 0; i < 8000; i++) {
      defList.add(i);
    }
    def = new Deficit(8000, defList); //make a new deficit
  }
  /**
   * likes the tag with the given name, reassigns numbers
   * in the list to add more instances of the given name
   * @param tag the tag that is being liked
   */
  void like(String tag, String source) {
    if (tag == null) return;
    int raise = 0; //initialize the raise
    int allTagsPlace = -1; //the place in alltags where the tag is if its there
    bool alreadyIn = false; //whether the tag is already in the list
    for (Tag t in allTags) {
      //go through alltags to see if its already in the list
      if (t.name == tag && t.type == source) {
        //if it is already in set alltagsplace and alreadyin
        allTagsPlace = allTags.indexOf(t);
        alreadyIn = true;
        break;
      }
    }
    print(tag);
    //if already in get the raise by liking it
    if (alreadyIn) {
      raise = allTags[allTagsPlace].like();
    }
    //otherwise create a new tag and add it to alltags
    else {
      Tag t = new Tag(tag, source);
      raise = t.firstLike();
      allTags.add(t);
      allTagsPlace = allTags.length - 1;
    }
    //if numbers are available to add
    SourceName theTag = new SourceName(tag, source);
    if (def.def > 0) {
      if (raise < def.def) {//if it can give the amount given by raise, have the deficit give the numbers then add them to the tag
        List<int> numbers = def.give(raise);
        allTags[allTagsPlace].addNumbers(numbers, alreadyIn);
        for (int i in numbers) {
          list[i] = theTag;
        }
      } else {//otherwise just add all the deficit
        int newRaise = def.def;
        List<int> numbers = def.give(newRaise);
        allTags[allTagsPlace].addNumbers(numbers, alreadyIn);
        for (int i in numbers) {
          list[i] = theTag;
        }
      }
    }
  }
  /**
   * dislikes the given tag, adds it to the alltags list if
   * it wasn't already in, takes numbers from the tag and 
   * adds them to the deficit to make it available for 
   * other tags
   * @param tag the name of the tag that is being disliked
   */
  void dislike(String tag, String source) {
    if (tag == null) return;
    int allTagsPlace = -1;//the index of the tag within alltags
    bool alreadyIn = false;//whether the tag is already in the alltags list
    for (Tag t in allTags) {//go through the alltags list to check if the tag is already in
      if (t.name == tag&& t.type == source) {//if it is set the alltagsplace and alreadyin
        allTagsPlace = allTags.indexOf(t);
        alreadyIn = true;
        break;
      }
    }

    int deficit;
    if (alreadyIn) {//if its already in it might have numbers to give
      deficit = allTags[allTagsPlace].dislike();//dislike it to see how many numbers to take

      if (allTags[allTagsPlace].isNegative())//if its negative there are no numbers to take
        return;
      else {//otherwise it has numbers that can be taken
        if (def.def + deficit < 10000) {//se if adding to it will send it over 10000
          List<int> nums = allTags[allTagsPlace].takeNumbers(deficit);
          def.take(nums);
        } else {
          int newDeficit = 10000 - def.def;
          def.take(allTags[allTagsPlace].takeNumbers(newDeficit));
        }
      }
    } else {//if its not already in then give it first dislike then add it to alltags
      Tag t = new Tag(tag, source);
      t.firstDislike();
      allTags.add(t);
    }
  }
  /**
   * randomly selects a tag from the list, makes sure
   * it is not null then returns it
   */
  SourceName getTag() {
    Random generator = new Random.secure();
    int number = generator.nextInt(10000);
    while (list[number] == null) {//check if its null then replace that null with a popular
      list[number] = new SourceName("popular", "reddit");
      number = generator.nextInt(10000);
      List<int> nullNumber = [number];
      def.take(nullNumber);
    }
    while(lastTag!=null && lastTag.name==list[number].name && getPercent("popular", "reddit")<99)
     number = generator.nextInt(10000);
    lastTag = list[number];
    return list[number];
  }
  /**
   * removes a given tag from the list as well
   * ass the all tags list
   * @param tag the name of the tag to be removed
   */
  void removeTag(SourceName sourceName){
    List<int> removed = new List();
    SourceName tag = new SourceName(sourceName.name, sourceName.source);
    for(int i = 0; i<10000;i++){
      if(list[i].name == tag.name && list[i].source == tag.source){
        list[i] = new SourceName("popular", "reddit");
        removed.add(i);
        
      }
    }
  
    def.take(removed);
    for(Tag t in allTags){
      if(t.name == tag)
        allTags.remove(t);
    }
  }
  /**
   * gets the percent a certain tag posses in the list
   * @param name the name of the tag
   * @param source the source/type of tag it is
   */
  double getPercent(String name, String source) {
    double percent = 0.0;
    for (SourceName s in list) {
      if (s.name == name && s.source == source) percent += 0.01;
    }
    return percent;
  }
  /**
   * tostring method that gives the alltags list one
   * line at a time with name and ratings
   */
  String toString() {
    String s;
    for (Tag t in allTags) {
      s += (t.toString() + "\n");
    }
    return s;
  }
  //used in storing the taglist in json format
  Map<String, dynamic> toJson() => {
        'list': list,
        'allTags': allTags,
        'def': def,
      };
  //used in restoring the taglist from a saved json
  factory TagList.fromJson(Map<String, dynamic> json) => _$TagListFromJson(json);

}
