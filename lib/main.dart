import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'tag.dart';
import 'placeList.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'StakSwipe',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Stak Swipe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Queue<Widget> cardStack;
  List<Widget> cardList;
  Widget card1;
  Widget card2;
  Widget card3;
  TagList tagList;
  PlaceList placeList;
  int index;
  JsonEncoder encoder;

  void initState() {
    encoder = new JsonEncoder();
    index = 0;
    super.initState();
    tagList = new TagList();
    placeList = new PlaceList();
    restore();
    String tag = tagList.getTag();
    String place = placeList.getPlace(tag, "reddit");
    card1 = newCard(tag, "reddit", place, (tag == "popular"));
    tag = tagList.getTag();
    place = placeList.getPlace(tag, "reddit");
    card2 = newCard(tag, "reddit", place, (tag == "popular"));
    tag = tagList.getTag();
    place = placeList.getPlace(
      tag,
      "reddit",
    );
    card3 = newCard(tag, "reddit", place, (tag == "popular"));
    cardStack = new Queue();
    setState(() {
      /**cardStack.add(card1);
      cardStack.add(card2);
      cardStack.add(card3);
      cardList = cardStack.toList();**/
    });
  }

  void save() async {
    var prefs = await SharedPreferences.getInstance();
    
    String taglistJson = encoder.convert(tagList);
    String placeJson = encoder.convert(placeList);
    prefs.setString('place', placeJson);
    prefs.setString('taglist', taglistJson);
  }

  void restore() async {
    var prefs = await SharedPreferences.getInstance();
    String tagJson = prefs.getString('taglist') ?? "0";
    String placeJson = prefs.getString('place') ?? "0";
    if (tagJson == "0") {
      return;
    }
    Map tagmap = JSON.decode(tagJson);
    Map placemap = JSON.decode(placeJson);
    tagList = new TagList.fromJson(tagmap);
    placeList = new PlaceList.fromJson(placemap);
    print(placeList);
  }

  Future<String> getData(
    String tag,
    String place,
    String source,
  ) async {
    //setState(() {});
    //if (source == "reddit") {
      
    
    var response;
    if (place == "not in") {
      response = await http.get(
          Uri.encodeFull("https://www.reddit.com/r/$tag.json?limit=1;"),
          headers: {"Accept": "applications/json"});
      print("https://www.reddit.com/r/$tag.json?limit=1;");
    } else {
      response = await http.get(
          Uri.encodeFull(
              "https://www.reddit.com/r/$tag.json?limit=1;after=$place;"),
          headers: {"Accept": "applications/json"});
      print("https://www.reddit.com/r/$tag.json?limit=1;after=$place;");
    }

    return response.body;
    //}
  }

  void removeCard() {
    /** cardList[2] = cardList[1];
      cardList[1] = cardList[0];
      
      cardList[0] = newCard(tag, "reddit", place, (tag=="popular"));**/

    
                save();
    String tag = tagList.getTag();
    String place = placeList.getPlace(tag, "reddit");
    card3 = card2;
    card2 = card1;
    card1 = newCard(tag, "reddit", place, (tag == "popular"));

    setState(() {});
  }

  Widget newCard(String tag, String source, String place, bool isPopular) {
    index++;
    bool firstRender = true;
    Key i = Key("$index");
    int thisIndex = index;
    return new FutureBuilder(
        future: getData(tag, place, source),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var data = JSON.decode(snapshot.data);
          String title = data["data"]["children"][0]["data"]["title"];
          String url = data["data"]["children"][0]["data"]["url"];
          String sub = data["data"]["children"][0]["data"]["subreddit"];
          String author = data["data"]["children"][0]["data"]["author"];
          if (isPopular)
            placeList.setPlace("popular", source, data["data"]["after"]);
          placeList.setPlace(sub, source, data["data"]["after"]);
          //print(" after tag: $sub place: ${placeList.getPlace(tag, "reddit")}");
          if ((index - thisIndex) == 2) {
            if (firstRender) {
              firstRender = false;
              return new Text("");
            } else
              firstRender = true;
          }
          return new Container(
            height: 500.0,
            width: 350.0,
            child: new Dismissible(
              key: Key("$index"),
              onDismissed: (direction) {
                switch (direction) {
                  case DismissDirection.startToEnd:
                    tagList.like(sub);
                    print("right");
                    break;
                  case DismissDirection.endToStart:
                    print("left");
                    tagList.dislike(sub);
                    break;
                  default:
                    break;
                }
                removeCard();

              },
              child: Card(
                elevation: 50.0,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "Posted on: $sub \n By: $author",
                      style: new TextStyle(fontSize: 15.0, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                    new Text(
                      title,
                      style: new TextStyle(fontSize: 25.0, color: Colors.black),
                    ),
                    new Image.network(url),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    cardList = [card1, card2, card3];
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new GestureDetector(
          child: new Stack(
            children: cardList,
          ),
        ),
      ),
    );
  }
}
