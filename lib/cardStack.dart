import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'tag.dart';
import 'placeList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardStack extends StatelessWidget {
  CardStack({Key key, this.currentIndex}) : super(key: key);
  final int currentIndex;
  Widget build(BuildContext context) {
    CardHandler handler = CardHandler.of(context);
    return new Stack(
      children: handler.cardQueue.toList(),
    );
  }
}

class CardHandler extends InheritedWidget {
  final TagList list;
  final PlaceList place;
  final Queue<Widget> cardQueue;
  int index = 2;

  CardHandler({
    Key key,
    @required this.list,
    @required this.place,
    @required this.cardQueue,
    @required Widget child,
  })  : assert(list != null),
        assert(place != null),
        assert(cardQueue != null),
        super(key: key, child: child);
  static CardHandler of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CardHandler);
  }

  void removeCard() {
    cardQueue.removeLast();
    index++;
    cardQueue.addFirst(ContentCard(
      index: index,
    ));
    
    /**cardQueue.addFirst(new ContentCard(index: index,));
    for(ContentCard c in cardQueue.toList()){
      print(c.index);
    }**/
  }

  @override
  bool updateShouldNotify(CardHandler old) => index != old.index;
}

class ContentCard extends StatefulWidget {
  ContentCard({Key key, this.index, this.cardQueue}) : super(key: key);
  int index;
  Queue<ContentCard> cardQueue;
  TagList list;
  List<Widget> cardList;
  PlaceList place;

  _ContentCardState createState() => new _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  String title;
  String url;
  String author;
  String sub;
  void initState() {
    super.initState();
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
    var response; //variable to store the response
    if (place == "not in") {
      //if its not in gets the first one lin the list
      response = await http.get(
          Uri.encodeFull("https://www.reddit.com/r/$tag.json?limit=1;"),
          headers: {"Accept": "applications/json"});
    } else {
      //else goes to the specified place in the tag
      response = await http.get(
          Uri.encodeFull(
              "https://www.reddit.com/r/$tag.json?limit=1;after=$place;"),
          headers: {"Accept": "applications/json"});
    }

    return response.body;
  }

  Widget build(BuildContext context) {
    CardHandler cardHandler = CardHandler.of(context);
    SourceName tag = cardHandler.list.getTag();
    bool isPopular = (tag == "popular");
    String source = "reddit";
    String place = cardHandler.place.getPlace(tag.name, tag.source);
    bool firstRender =
        true; //checks if its first render, used to prevent a flashing bug
    int thisIndex = cardHandler.index;
    return new FutureBuilder(
        future: getData(tag.name, place,
            tag.source), //gets the json data from the getdata function
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var data = JSON.decode(snapshot.data); //format the data into a map
          //get all the data from the map and assign it to variables
          title = data["data"]["children"][0]["data"]["title"];
          url = data["data"]["children"][0]["data"]["url"];
          sub = data["data"]["children"][0]["data"]["subreddit"];
          author = data["data"]["children"][0]["data"]["author"];
          //print("title: $title index: ${widget.index}");
          //sets the place for the tag and the popular if it is popular
          if (isPopular)
            cardHandler.place
                .setPlace("popular", source, data["data"]["after"]);
          cardHandler.place.setPlace(sub, source, data["data"]["after"]);
          //prevents a bug where the top card is rendered briefly after it has been dismissed
          /**if ((cardHandler.index - thisIndex) == 3) {
            //if it it the top card
            if (firstRender) {
              //and it is the first time its been rendered this time around
              firstRender = false; //set first render back to false
              return new Text(
                  ""); //return a blank text so that nothing shows up instead of the card
            } else
              firstRender = true;
          }**/
          return new Container(
            //the card widget
            height: 500.0, //the size of the card
            width: 350.0,
            child: new Dismissible(
              //it is a dismissible which allows for easily handling the animation
              key: Key("$widget.index}"),
              onDismissed: (direction) {
                print(widget.index);
                cardHandler.removeCard();
                switch (direction) {
                  //checks which direction it went, if left it dislikes, if right it likes
                  case DismissDirection.startToEnd:
                    cardHandler.list.like(sub, "reddit");
                    break;
                  case DismissDirection.endToStart:
                    cardHandler.list.dislike(sub, "reddit");
                    
                    break;
                  default:
                    break;
                }
                //widget.cardQueue.removeLast();
                //widget.cardQueue.addFirst(new ContentCard(index: widget.index++, cardQueue: widget.cardQueue,));
                //cardHandler.removeCard(); //remove the top card
                setState(() {});
              },
              child: Card(
                //the card
                elevation: 50.0,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "Posted on: $sub \n By: $author", //where it came from
                      style: new TextStyle(fontSize: 15.0, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                    new Text(
                      //the title
                      title,
                      style: new TextStyle(fontSize: 25.0, color: Colors.black),
                    ),
                    new Image.network(url), //the corresponding picture
                  ],
                ),
              ),
            ),
          );
        });
  }
}
