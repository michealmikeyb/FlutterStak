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
import 'postingPage.dart';
import 'name.dart';
import 'userPostsPage.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> cardList; //the list of cards
  Widget card1; //the cards in the list
  Widget card2;
  Widget card3;
  TagList tagList; //the taglist holding the users likes and interest
  PlaceList
      placeList; //holds the place in each tag so the user can continually go through
  int index; //the index of the current card/ the number of card
  JsonEncoder encoder; //json encoder used for saving the taglist and placelist
  JsonDecoder
      decoder; // json decoder used in restoring the taglist and placelist
  final String stakServerUrl = "68.42.250.122";
  List<String> names;
  List<UserName> userNames;
  String currentUser = "none";
  bool checked = false;

  void initState() {
    encoder = new JsonEncoder(); //initialize the encoder and decoder
    decoder = new JsonDecoder();
    names = new List();
    userNames = new List();
    getNames();
    index = 0; //start the index
    super.initState();
    tagList = new TagList(); //initialize the lists
    placeList = new PlaceList();
    //restore(); //restore the lists if they are in the phones memory
    //create three new cards
    card1 = newCard();
    card2 = newCard();
    card3 = newCard();
    setState(() {});
  }

  void getNames() async {
    var prefs =
        await SharedPreferences.getInstance(); //get the shared preferences
    String nameJson = prefs.getString('names') ?? "0";
    if (nameJson == "0") return;
    List nameMap = decoder.convert(nameJson);
    print(nameMap[0]);
    for (Map m in nameMap) {
      userNames.add(UserName.fromJson(m));
    }
    //userNames = usernames;
    for (UserName u in userNames) {
      names.add(u.name);
    }
    currentUser = names[0];
    setState(() {});
  }

  /**
   * method used in adding a tag to the list
   */
  void addTag(SourceName answer) {
    setState(() {
      tagList.like(answer.name, answer.source);
      print(answer.source);
    });
  }

  /**
   * creates the add tag dialog created when the plus button
   * in the upper right corner is pressed, will add the tag
   * to the taglist by liking it once.
   */
  Future<Null> addTagDialog() async {
    String source = "";
    addTag(await showDialog(
        context: context,
        child: new SimpleDialog(
          title: new Text("Add a tag"),
          children: <Widget>[
            new TextField(
              onSubmitted: (text) {
                Navigator.pop(context, new SourceName(text, source));
              },
            ),
            new RadioListTile(
              title: const Text("Reddit"),
              value: "reddit",
              groupValue: source,
              onChanged: (String value) {
                setState(() {
                  source = value;
                });
              },
            ),
            new RadioListTile(
              title: const Text("StakSwipe"),
              value: "stakswipe",
              groupValue: source,
              onChanged: (String value) {
                setState(() {
                  source = value;
                });
              },
            )
          ],
        )));
  }

  /**
   * creates the remove tag dialog created when the  cancel button
   * in the upper right corner is pressed, will remove the tag
   * from the taglist.
   */
  Future<Null> removeTagDialog() async {
    String source = "";
    tagList.removeTag(
        await showDialog(
            context: context,
            child: new SimpleDialog(
              title: new Text("Remove a tag"),
              children: <Widget>[
                new TextField(
                  onSubmitted: (text) {
                    Navigator.pop(context, text);
                  },
                ),
                new RadioListTile(
                  title: const Text("Reddit"),
                  value: "reddit",
                  groupValue: source,
                  onChanged: (String value) {
                    setState(() {
                      source = value;
                    });
                  },
                ),
                new RadioListTile(
                  title: const Text("StakSwipe"),
                  value: "stakswipe",
                  groupValue: source,
                  onChanged: (String value) {
                    setState(() {
                      source = value;
                    });
                  },
                )
              ],
            )),
        source);
  }

  Future<Null> createAccountDialog() async {
    String buttonText = "submit";
    String name = "";
    await showDialog(
        context: context,
        child: SimpleDialog(
          title: Text("Create Account"),
          children: <Widget>[
            Text("Desired Name"),
            TextField(
              onSubmitted: (text) {
                setState(() {
                  addName(text);
                });
              },
            ),
            FlatButton(
              child: Text(buttonText),
              onPressed: () {
                if (checked)
                  Navigator.pop(context);
                else
                  buttonText = "Name Taken";
              },
            )
            /**FutureBuilder(
              future: isTaken,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data) {
                  return FlatButton(
                      child: Text("Submit"),
                      onPressed: () {
                        //addName(name);
                        Navigator.pop(context, name);
                      });
                } else
                  return new Text("Name Taken");
              },
            )**/
          ],
        ));
  }

  Future<bool> checkName(String name) async {
    var response = await http
        .get("http://$stakServerUrl/stakSwipe/checkName.php?name=$name");
    print(name);
    return response.body == "available";
  }

  void addName(String name) async {
    checked = await checkName(name);
    if (checked) {
      UserName newUser = new UserName(name);
      names.add(name);
      userNames.add(newUser);
      print(name);
      var response = await http.post(
          "http://$stakServerUrl/stakSwipe/newUser.php",
          body: {'name': name, 'number': "${newUser.id}"});
      print(response.body);
      currentUser = name;
      var prefs =
          await SharedPreferences.getInstance(); //get the shared preferences
      String userNamesJson = encoder.convert(userNames);
      prefs.setString('names', userNamesJson);
    }
  }

  /**
   * save the current taglist and placelist
   * in the sharedpreferences as a json
   */
  void save() async {
    var prefs =
        await SharedPreferences.getInstance(); //get the shared preferences
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
    var prefs =
        await SharedPreferences.getInstance(); //get the sharedpreferences
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
    var response; //variable to store the response
    if (source == "reddit") {
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
    } else if (source == "stakswipe") {
      if (place == "not in") {
        response = await http.get(
            Uri.encodeFull(
                "http://$stakServerUrl/stakSwipe/getListing.php?tag=$tag&place=0;"),
            headers: {"Accept": "applications/json"});
      } else {
        response = await http.get(
            Uri.encodeFull(
                "http://$stakServerUrl/stakSwipe/getListing.php?tag=$tag&place=$place;"),
            headers: {"Accept": "applications/json"});
      }
      return response.body;
    }
  }

  /**data
   * removes the top card from the stack and moves each of the other
   * cards up one
   */
  void removeCard() {
    save(); //save the placelist and taglist
    card3 = card2; //move each card up one and assign a new card to the bottom
    card2 = card1;
    card1 = newCard();

    setState(() {});
  }

  /**
   * creates a new card to add to the stack of cards
   */
  Widget newCard() {
    //get the tag and source from the taglist then gets the place from the place list
    SourceName tag = tagList.getTag();
    bool isPopular = (tag.name == "popular");
    String source = tag.source;
    String name = tag.name;
    String place = placeList.getPlace(tag.name, tag.source);

    index++; //iterate the index
    bool firstRender =
        true; //checks if its first render, used to prevent a flashing bug
    Key i = Key("$index");
    int thisIndex = index;
    return new FutureBuilder(
        future: getData(
            name, place, source), //gets the json data from the getdata function
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var data =
              decoder.convert(snapshot.data); //format the data into a map
          String dataSource;
          String title;
          String url;
          String sub;
          String author;
          String dataPlace;
          if (data["data"] != null) {
            dataSource = "reddit";
            var listing = data["data"]["children"];
            if (listing.length > 0) {
              //get all the data from the map and assign it to variables
              title = data["data"]["children"][0]["data"]["title"];
              url = data["data"]["children"][0]["data"]["url"];
              sub = data["data"]["children"][0]["data"]["subreddit"];
              author = data["data"]["children"][0]["data"]["author"];
              dataPlace = data["data"]["after"];
            } else
              return newCard();
          } else {
            dataSource = "stakswipe";
            title = data['title'];
            url = data['link'];
            sub = data['tag'];
            author = data['author'];
            dataPlace = data['place'];
          }
          //sets the place for the tag and the popular if it is popular
          if (isPopular) placeList.setPlace("popular", source, dataPlace);
          placeList.setPlace(sub, source, dataPlace);
          //prevents a bug where the top card is rendered briefly after it has been dismissed
          if ((index - thisIndex) == 2) {
            //if it it the top card
            if (firstRender) {
              //and it is the first time its been rendered this time around
              firstRender = false; //set first render back to false
              return new Text(
                  ""); //return a blank text so that nothing shows up instead of the card
            } else
              firstRender = true;
          }
          if ((index - thisIndex) == 1 && firstRender) {
            print(title);
          }
          return new Container(
            //the card widget
            padding: EdgeInsets.all(20.0),
            child: new Dismissible(
              //it is a dismissible which allows for easily handling the animation
              key: Key("$index"),
              onDismissed: (direction) {
                switch (direction) {
                  //checks which direction it went, if left it dislikes, if right it likes
                  case DismissDirection.startToEnd:
                    tagList.like(sub, dataSource);
                    if (source == "stakswipe")
                      http.post("http://$stakServerUrl/stakSwipe/like.php",
                          body: {'id': data["id"]});
                    break;
                  case DismissDirection.endToStart:
                    if (source == "stakswipe")
                      http.post("http://$stakServerUrl/stakSwipe/dislike.php",
                          body: {'id': data["id"]});
                    tagList.dislike(sub, dataSource);
                    break;
                  default:
                    break;
                }
                removeCard(); //remove the top card
              },
              child: Card(
                //the card
                elevation: 50.0,
                child: new ListView(
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

  @override
  Widget build(BuildContext context) {
    cardList = [card1, card2, card3]; //makes the three cards into a list
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: new Icon(Icons.add),
            onPressed: () {
              addTagDialog();
            },
          ),
          IconButton(
            icon: new Icon(Icons.block),
            onPressed: () {
              removeTagDialog();
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostingPage()),
              );
            },
            icon: new Icon(Icons.library_add),
          ),
        ],
      ),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: Text(currentUser),
              accountEmail: Text("posting as $currentUser"),
            ),
            new ListTile(
              title: Text("My Posts"),
              trailing: Icon(Icons.library_add),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PostsPage(username: currentUser,)));
              },
            ),
            new ListTile(
              title: Text("My Shares"),
              trailing: Icon(Icons.share),
            ),
            new Divider(),
            new ListTile(
              title: Text("Close"),
              trailing: Icon(Icons.cancel),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            new ListTile(
              title: Text("New Name"),
              trailing: Icon(Icons.add),
              onTap: () {
                createAccountDialog();
              },
            )
          ],
        ),
      ),
      body: new Center(
        child: new GestureDetector(
          child: new Stack(
            children: cardList, //renders the cardlist as a stack of cards
          ),
        ),
      ),
    );
  }
}
