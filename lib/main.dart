/**
 * this contains the main for an app that allows users to browse content
 * suited to their likes and interest. It operates on a very basic ui of
 * swiping left on content they dissaprove and right on content they 
 * approve of. Through the tag functions in tag.dart the liked contents
 * show up more and the disliked show up less.
 */
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
  List<Widget> cardList;//the list of cards
  Widget card1;//the cards in the list
  Widget card2;
  Widget card3;
  TagList tagList;//the taglist holding the users likes and interest
  PlaceList placeList;//holds the place in each tag so the user can continually go through
  int index;//the index of the current card/ the number of card
  JsonEncoder encoder;//json encoder used for saving the taglist and placelist
  JsonDecoder decoder;// json decoder used in restoring the taglist and placelist

  void initState() {
    encoder = new JsonEncoder();//initialize the encoder and decoder
    decoder = new JsonDecoder();
    index = 0;//start the index
    super.initState();
    tagList = new TagList();//initialize the lists
    placeList = new PlaceList();
    restore();//restore the lists if they are in the phones memory
    //create three new cards
     card1 = newCard();
    card2 = newCard();
    card3 = newCard();
    setState(() {
      
    });
  }
  /**
   * save the current taglist and placelist
   * in the sharedpreferences as a json
   */
  void save() async {
    var prefs = await SharedPreferences.getInstance();//get the shared preferences
    //convert the taglist and placelist into jsons
    String taglistJson = encoder.convert(tagList);
    String placeJson = encoder.convert(placeList);
    //store those string in the preferences
    prefs.setString('place', placeJson);
    prefs.setString('taglist', taglistJson);
  }
  /**
   * restore the taglist and placelist from shared preferences 
   */
  void restore() async {
    var prefs = await SharedPreferences.getInstance();//get the sharedpreferences
    //get the tagjson and placejson strings, if they aren't there return
    String tagJson = prefs.getString('taglist') ?? "0";
    String placeJson = prefs.getString('place') ?? "0";
    if (tagJson == "0") {
      return;
    }
    //convert them to a map
    Map tagmap = decoder.convert(tagJson);
    Map placemap = decoder.convert(placeJson);
    //convert that map into the taglist and placelist
    tagList = new TagList.fromJson(tagmap);
    placeList = new PlaceList.fromJson(placemap);
  }
  /**
   * gets the json information for a tag based on its place, source and the name 
   * of the tag
   * @param tag the name of the tag
   * @param place the place/ how far in the tag
   * @param source where the tag comes from
   */
  Future<String> getData(
    String tag,
    String place,
    String source,
  ) async {
      
    
    var response;//variable to store the response
    if (place == "not in") {//if its not in gets the first one lin the list
      response = await http.get(
          Uri.encodeFull("https://www.reddit.com/r/$tag.json?limit=1;"),
          headers: {"Accept": "applications/json"});
    } else {//else goes to the specified place in the tag
      response = await http.get(
          Uri.encodeFull(
              "https://www.reddit.com/r/$tag.json?limit=1;after=$place;"),
          headers: {"Accept": "applications/json"});
    }

    return response.body;
  }
  /**
   * removes the top card from the stack and moves each of the other
   * cards up one
   */
  void removeCard() {
    save();//save the placelist and taglist
    card3 = card2;//move each card up one and assign a new card to the bottom
    card2 = card1;
    card1 = newCard();
    
    setState(() {});
  }
  /**
   * creates a new card to add to the stack of cards
   */
  Widget newCard() {
    //get the tag and source from the taglist then gets the place from the place list
    String tag = tagList.getTag();
    bool isPopular = (tag=="popular");
    String source = "reddit";
    String place = placeList.getPlace(tag, source);

    index++;//iterate the index
    bool firstRender = true;//checks if its first render, used to prevent a flashing bug
    Key i = Key("$index");
    int thisIndex = index;
    return new FutureBuilder(
        future: getData(tag, place, source),//gets the json data from the getdata function
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var data = JSON.decode(snapshot.data);//format the data into a map
          //get all the data from the map and assign it to variables
          String title = data["data"]["children"][0]["data"]["title"];
          String url = data["data"]["children"][0]["data"]["url"];
          String sub = data["data"]["children"][0]["data"]["subreddit"];
          String author = data["data"]["children"][0]["data"]["author"];
          //sets the place for the tag and the popular if it is popular
          if (isPopular)
            placeList.setPlace("popular", source, data["data"]["after"]);
          placeList.setPlace(sub, source, data["data"]["after"]);
          //prevents a bug where the top card is rendered briefly after it has been dismissed 
          if ((index - thisIndex) == 2) {//if it it the top card
            if (firstRender) {//and it is the first time its been rendered this time around
              firstRender = false;//set first render back to false
              return new Text("");//return a blank text so that nothing shows up instead of the card
            } else
              firstRender = true;
          }
          return new Container(//the card widget
            height: 500.0,//the size of the card
            width: 350.0,
            child: new Dismissible(//it is a dismissible which allows for easily handling the animation
              key: Key("$index"),
              onDismissed: (direction) {
                
                switch (direction) {//checks which direction it went, if left it dislikes, if right it likes
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
                removeCard();//remove the top card

              },
              child: Card(//the card
                elevation: 50.0,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "Posted on: $sub \n By: $author",//where it came from
                      style: new TextStyle(fontSize: 15.0, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                    new Text(//the title
                      title,
                      style: new TextStyle(fontSize: 25.0, color: Colors.black),
                    ),
                    new Image.network(url),//the corresponding picture
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    cardList = [card1, card2, card3];//makes the three cards into a list
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new GestureDetector(
          child: new Stack(
            children: cardList,//renders the cardlist as a stack of cards
          ),
        ),
      ),
    );
  }
}
