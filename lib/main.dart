import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'tag.dart';

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
  TagList tagList;
  PlaceList placeList;
  int index;
  void initState() {
    index = 0;
    super.initState();
    tagList = new TagList();
    placeList = new PlaceList();
    String tag = tagList.getTag();
    String place = placeList.getPlace(tag, "reddit");
    card1 = newCard(tag,"reddit", place,  (tag=="popular"));
    tag = tagList.getTag();
    place = placeList.getPlace(tag, "reddit");
    card2 = newCard(tag, "reddit", place,  (tag=="popular"));
    tag = tagList.getTag();
    place = placeList.getPlace(tag, "reddit", );
    Widget card3 = newCard(tag,"reddit", place,  (tag=="popular"));
    cardStack = new Queue();
    setState(() {
      cardStack.add(card1);
      cardStack.add(card2);
      cardStack.add(card3);
      cardList = cardStack.toList();
    });
  }

  Future<String> getData(String tag, String place, String source, ) async {
    if (source == "reddit") {
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
    }
  }

  void removeCard() {
    
      String tag = tagList.getTag();
      String place = placeList.getPlace(tag, "reddit");
      print("tag: $tag place: $place");
      cardStack.removeLast();
      cardStack.addFirst(newCard(tag, "reddit", place, (tag=="popular")));
      
    setState(() {
      
      cardList = cardStack.toList();
    });
  }

  Widget newCard(String tag, String source, String place, bool isPopular) {
    return new FutureBuilder(
        future: getData(tag, place, source),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var data = JSON.decode(snapshot.data);
          String title = data["data"]["children"][0]["data"]["title"];
          String url = data["data"]["children"][0]["data"]["url"];
          String sub = data["data"]["children"][0]["data"]["subreddit"];
          if(isPopular)
            placeList.setPlace("popular", source, data["data"]["after"]);
          placeList.setPlace(sub, source, data["data"]["after"]);
          print(" after tag: $sub place: ${placeList.getPlace(tag, "reddit")}");
          return new Container(
            height: 500.0,
            width: 350.0,
            child: new Dismissible(
              key: Key("${index++}"),
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
                print(direction);
                removeCard();
              },
              child: Card(
                elevation: 50.0,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(title),
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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new GestureDetector(
          onTap: () {
            setState(() {});
          },
          onDoubleTap: () {
            setState(() {});
          },
          child: new Stack(
            children: cardList,
          ),
        ),
      ),
    );
  }
}
