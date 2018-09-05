/**
 * this holds the placelist class and the placeholders for each of the tags.
 * it holds the place in the list of a tag so the user will iterate through 
 * the tag one by one.
 */
import 'package:json_annotation/json_annotation.dart';

part 'placeList.g.dart';

/**
 * the list holding all the placeholders for each of the tags
 */
@JsonSerializable()
class PlaceList {
  List<PlaceHolder> list;
  DateTime lastReset;
  PlaceList() {
    list = new List();
    lastReset = DateTime.now();
  }
  /**
   * looks through the list to see if it has a place
   * if it doesn't returns not in
   * @param tag the name of the tag that is being searched for
   * @param source the source of the tat that is being seached for
   */
  String getPlace(String tag, String source) {
    checkReset();
    for (PlaceHolder p in list) {
      if (p.name == tag && p.source == source) return p.place;
    }
    list.add(new PlaceHolder(tag, "not in", source));
    if(source == "reddit")
    return "not in";
    else
    return "100000000";
  }
  /**
   * sets the place of the specified tag
   * @param tag the name of the tag that is being changed
   * @param source the source of the tat that is being changed
   * @param place the place to be assigned
   */
  void setPlace(String tag, String source, String place) {
    for (PlaceHolder p in list) {
      if (p.name == tag && p.source == source)
      p.place = place;
    }
  }

  void checkReset(){
    if(lastReset.difference(DateTime.now()).inHours>8)
    list = new List();
    lastReset = DateTime.now();
  }
  /**
   * tostring function giving the places and names of each tag in the list
   */
  String toString(){
    String s = "";
    for(PlaceHolder p in list)
      s+=p.toString();
    return s;
  }
  //used in storing the placelist as a json
  Map<String, dynamic> toJson()=>{
  'list':list,
  'lastReset':lastReset?.toIso8601String()
  };
  //used in restoring the list from a json
  factory PlaceList.fromJson(Map<String, dynamic> json)=> _$PlaceListFromJson(json);

  
}
/**
 * the placeholder for a certain tag
 */
class PlaceHolder {
  String _place;//the place in the tag
  String _source;//the source of the tag
  String _name;//the name of the tag

  PlaceHolder(this._name, this._place, this._source);
  //getter functions
  String get place => _place;
  String get source => _source;
  String get name => _name;
  set place(p) => _place = p;
  /**
   * to string function given in the format "name: name place: place surce: source"
   */
  String toString(){
    return "name: $_name place: $_place source: $_source";
  }
  //used in storing the placeholder in a json
  Map<String, dynamic> toJson()=>{
    'place': _place,
    'source': _source,
    'name': _name,
  };
  //used in restoring the placeholder from a json
  PlaceHolder.fromJson(Map<String, dynamic> json)
    :_place = json['place'],
    _source = json['source'],
    _name = json['name'];
}
