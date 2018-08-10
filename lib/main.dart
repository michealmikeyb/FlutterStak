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
import 'comments.dart';
import 'tagListPage.dart';

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

enum contentSource { reddit, stakswipe }

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> cardList; //the list of cards
  Queue<Widget> cardq;
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
    names = new List(); //the usernames of the current user
    userNames = new List();
    getNames(); //gets the names of the user from memory
    index = 0; //start the index
    super.initState();
    tagList = new TagList(); //initialize the lists
    placeList = new PlaceList();
    restore(); //restore the lists if they are in the phones memory
    //create three new cards

    setState(() {});
  }

  /**
   * gets the usernames of the user from the phones
   * sharedpreferences or apple equivalent
   */
  void getNames() async {
    var prefs =
        await SharedPreferences.getInstance(); //get the shared preferences
    String nameJson = prefs.getString('names') ?? "0";
    if (nameJson == "0") return; //if there is no name list just return back
    List nameMap = decoder.convert(nameJson); //convert it to a map
    for (Map m in nameMap) {
      //add all of the usernames to the list
      userNames.add(UserName.fromJson(m));
    }
    //userNames = usernames;
    for (UserName u in userNames) {
      //add the string version to the names list
      names.add(u.name);
    }
    currentUser = names[0]; //set the current user
    setState(() {});
  }

  /**
   * method used in adding a tag to the list
   */
  void addTag(SourceName answer) {
    if (answer.name == "cancel") return;
    setState(() {
      tagList.like(answer.name, answer.source);
    });
  }

  /**
   * creates the add tag dialog created when the plus button
   * in the upper right corner is pressed, will add the tag
   * to the taglist by liking it once.
   */
  Future<Null> addTagDialog() async {
    contentSource source = contentSource.reddit; //the enum to store the source
    String tag; //the tag that will be added
    addTag(await showDialog(
        context: context,
        child: new SimpleDialog(
          //inflate a dialog
          title: new Text("Add a tag"),
          children: <Widget>[
            new TextField(
              onChanged: (text) {
                //update the tag when the text is changed
                setState(() {
                  tag = text;
                });
              },
            ),
            new RadioListTile<contentSource>(
              //radio tiles to decide what source its from
              title: const Text("Reddit"),
              value: contentSource.reddit,
              groupValue: source,
              onChanged: (contentSource value) {
                setState(() {
                  source = value;
                });
              },
            ),
            new RadioListTile<contentSource>(
              title: const Text("StakSwipe"),
              value: contentSource.stakswipe,
              groupValue: source,
              onChanged: (contentSource value) {
                setState(() {
                  source = value;
                });
              },
            ),
            FlatButton(
              //submit button
              child: Text("Add $tag"),
              onPressed: () {
                String stringSource;
                switch (source) {
                  case contentSource.reddit:
                    stringSource = "reddit";
                    break;
                  case contentSource.stakswipe:
                    stringSource = "stakswipe";
                    break;
                }
                Navigator.pop(context, new SourceName(tag, stringSource));
              }, //after submitted pops it with a new sourcename
            ),
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(
                    context,
                    new SourceName("cancel",
                        "cancel")); //sets the sourcename to cancel so the addTag method can just return
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
    contentSource source = contentSource.reddit; //the enum to store the source
    String tag = "";
    tagList.removeTag(
      await showDialog(
          context: context,
          child: new SimpleDialog(
            title: new Text("Remove a tag"),
            children: <Widget>[
              new TextField(
                onChanged: (text) {
                  //update the tag when the text is changed
                  setState(() {
                    tag = text;
                  });
                },
              ),
              new RadioListTile(
                title: const Text("Reddit"),
                value: contentSource.reddit,
                groupValue: source,
                onChanged: (contentSource value) {
                  setState(() {
                    source = value;
                  });
                },
              ),
              new RadioListTile(
                title: const Text("StakSwipe"),
                value: contentSource.stakswipe,
                groupValue: source,
                onChanged: (contentSource value) {
                  setState(() {
                    source = value;
                  });
                },
              ),
              FlatButton(
                //submit button
                child: Text("Add $tag"),
                onPressed: () {
                  String stringSource;
                  switch (source) {
                    case contentSource.reddit:
                      stringSource = "reddit";
                      break;
                    case contentSource.stakswipe:
                      stringSource = "stakswipe";
                      break;
                  }
                  Navigator.pop(context, new SourceName(tag, stringSource));
                }, //after submitted pops it with a new sourcename
              ),
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(
                      context,
                      new SourceName("cancel",
                          "cancel")); //sets the sourcename to cancel so the addTag method can just return
                },
              )
            ],
          )),
    );
  }

  /**
   * dialog for the user to create a name so that they 
   * can post and share content
   */
  Future<Null> createAccountDialog() async {
    String buttonText = "submit";
    String name = "";
    await showDialog(
        context: context,
        child: SimpleDialog(
          title: Text("Create Account"),
          children: <Widget>[
            Text("Desired Name (press enter to check availability)"),
            TextField(
              onSubmitted: (text) {
                setState(() {
                  addName(
                      text); //check the name to see if it is available, add it if it is
                });
              },
            ),
            FlatButton(
              child: Text(buttonText),
              onPressed: () {
                if (checked) //if its checked and added, exit
                  Navigator.pop(context);
                else
                  buttonText = "Name Taken";
              },
            ),
            FlatButton(
              //cancel out if user wants to go back
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }

  /**
   * checks the given name to see if it is available on the
   * server, returns a bool, true if it is available false 
   * if its not.
   * @param name the name to check on the server
   */
  Future<bool> checkName(String name) async {
    //checks the name from the database
    var response = await http
        .get("http://$stakServerUrl/stakSwipe/checkName.php?name=$name");
    return response.body == "available";
  }

  /**
   * checks the name given before adding it to 
   * both the database and the username list
   * @param the name that is attempting to be added
   */
  void addName(String name) async {
    checked = await checkName(name); //check the name
    if (checked) {
      UserName newUser = new UserName(name); //create a new username
      names.add(name); //add it to the string list of names
      userNames.add(newUser); //add it to the username list
      var response = await http.post(
          //post it to the server
          "http://$stakServerUrl/stakSwipe/newUser.php",
          body: {'name': name, 'number': "${newUser.id}"});
      currentUser = name; //set the current user to the one that was just added
      var prefs =
          await SharedPreferences.getInstance(); //get the shared preferences
      String userNamesJson = encoder.convert(userNames);
      prefs.setString('names', userNamesJson); //save the usernames
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
      setState(() {
        cardq = introCard();
      });
      return;
    }
    //convert them to a map
    Map tagmap = decoder.convert(tagJson);
    Map placemap = decoder.convert(placeJson);
    //convert that map into the taglist and placelist
    tagList = new TagList.fromJson(tagmap);
    placeList = new PlaceList.fromJson(placemap);
    cardq = new Queue();
    setState(() {
      cardq.add(newCard());
      cardq.add(newCard());
      cardq.add(newCard());
    });
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
    cardq.removeLast();
    cardq.addFirst(newCard());

    setState(() {});
  }

  Queue<Widget> introCard() {
    Queue<Widget> queue = new Queue();
    Widget card1 = new Container(
      //the card widget
      padding: EdgeInsets.all(20.0),
      child: new Dismissible(
        key: new Key("-1"),
        child: new Card(
          child: Column(
            children: <Widget>[
              Text(
                "Welcome To StakSwipe",
                style: new TextStyle(fontSize: 25.0, color: Colors.black),
              ),
              Text(
                "StakSwipe is a media aggregation app to view all of you favorite content. Using the app is simple jusr right swipe stuff that you like or want to see more of and left swipe stuff hat you want to see less, try it out swipe away this card",
                style: new TextStyle(fontSize: 15.0, color: Colors.black),
              )
            ],
          ),
        ),
        onDismissed: (DismissDirection direction) {
          removeCard();
        },
      ),
    );
    Widget card2 = new Container(
        //the card widget
        padding: EdgeInsets.all(20.0),
        child: new Dismissible(
          key: new Key("-2"),
          child: new Card(
            child: Column(
              children: <Widget>[
                Text(
                  "Other Features",
                  style: new TextStyle(fontSize: 25.0, color: Colors.black),
                ),
                Text(
                  "Currently stakswipe takes from two sources reddit and its own server. If you want to Post to the stakswipe server press the button in the top right. You can also add or remove tags from your interests with the other two buttons to the left of the post button. In order to post You'll need a name swipe to see how to set that up",
                  style: new TextStyle(fontSize: 15.0, color: Colors.black),
                ),
              ],
            ),
          ),
          onDismissed: (DismissDirection direction) {
            removeCard();
          },
        ));
    Widget card3 = new Container(
        //the card widget
        padding: EdgeInsets.all(20.0),
        child: new Dismissible(
          key: new Key("-3"),
          child: new Card(
            child: Column(
              children: <Widget>[
                Text(
                  "The sidebar",
                  style: new TextStyle(fontSize: 25.0, color: Colors.black),
                ),
                Text(
                  "In the upper left is a button to open up the sidebar. In there you can navigate to your posts, your list which contains all your interests as well as their percentages and you can create a name. Names are completely optionial in stakswipe, you only need one if you want to post content. Creating a name in stakswipe is easy, just pick a name and hit enter if its available you can hit submit. No password is required and the name is tied to your device so no one else can impersonate you. Now your ready to start swipe on this to start going through content.",
                  style: new TextStyle(fontSize: 15.0, color: Colors.black),
                )
              ],
            ),
          ),
          onDismissed: (DismissDirection direction) {
            removeCard();
          },
        ));
    queue.add(card3);
    queue.add(card2);
    queue.add(card1);
    return queue;
  }

  /**
   * creates a new card to add to the stack of cards
   */
  Widget newCard() {
    //get the tag and source from the taglist then gets the place from the place list
    SourceName tag = tagList.getTag();
    print("tag: ${tag.name}");
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
          String comments;
          String text = "";
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
              text = data["data"]["children"][0]["data"]["selftext"];
              comments = data["data"]["children"][0]["data"]["permalink"];
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
          print(dataPlace);
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
                    new Text("$text \nComments:"),
                    new Comment(
                      url: "https://www.reddit.com$comments.json",
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    cardList = cardq.toList(); //makes the three cards into a list
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
                MaterialPageRoute(
                    builder: (context) => PostingPage(
                          username: currentUser,
                        )),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostsPage(
                              username: currentUser,
                            )));
              },
            ),
            new ListTile(
              title: Text("My Shares"),
              trailing: Icon(Icons.share),
            ),
            new ListTile(
              title: Text("My List"),
              trailing: Icon(Icons.list),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TagPage(list: tagList)));
              },
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
            ),
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
