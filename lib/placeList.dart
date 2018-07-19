import 'package:json_annotation/json_annotation.dart';

part 'placeList.g.dart';

@JsonSerializable()
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

  String toString(){
    String s = "";
    for(PlaceHolder p in list)
      s+=p.toString();
    return s;
  }
  Map<String, dynamic> toJson()=>{
  'list':list
  };

  factory PlaceList.fromJson(Map<String, dynamic> json)=> _$PlaceListFromJson(json);

  
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

  String toString(){
    return "name: $_name place: $_place source: $_source";
  }

  Map<String, dynamic> toJson()=>{
    'place': _place,
    'source': _source,
    'name': _name,
  };

  PlaceHolder.fromJson(Map<String, dynamic> json)
    :_place = json['place'],
    _source = json['source'],
    _name = json['name'];
}
