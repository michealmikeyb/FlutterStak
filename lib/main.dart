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
import 'dialogs.dart';
import 'userShares.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'listing.dart';
import 'contentCard.dart';
import 'shareListPage.dart';

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
  ListingList list;
  int index; //the index of the current card/ the number of card
  JsonEncoder encoder; //json encoder used for saving the taglist and placelist
  JsonDecoder
      decoder; // json decoder used in restoring the taglist and placelist
  final String stakServerUrl = "68.42.250.122";
  List<String> names;
  List<UserName> userNames;
  String currentUser = "none";
  bool checked = false;
  CardStack stack;

  String currentTitle;
  String currentLink;
  String currentAuthor;
  String currentCommentLink;
  String currentSelfText;
  String currentTag;

  void initState() {
    encoder = new JsonEncoder(); //initialize the encoder and decoder
    decoder = new JsonDecoder();
    names = new List(); //the usernames of the current user
    userNames = new List();
    getNames(); //gets the names of the user from memory
    stack = new CardStack(
      list: new ListingList(),
    );
    super.initState();

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
    int i = 0;
    while (i < userNames.length) {
      if (await login(userNames[i].name, userNames[i].id)) {
        currentUser = names[i]; //set the current user
      } else
        i++;
    }
    setState(() {});
  }

  Future<bool> login(String name, int number) async {
    var response = await Firestore.instance
        .collection("users")
        .where("name", isEqualTo: name)
        .getDocuments();
    if (!response.documents.isEmpty)
      return response.documents[0]["number"] == number;
    else
      return false;
  }

  /**
   * method used in adding a tag to the list
   */
  void addTag(SourceName answer) {
    if (answer.name == "cancel") return;
    setState(() {
      stack.list.tagList.like(answer.name.toLowerCase(), answer.source);
    });
  }

  /**
   * creates the add tag dialog created when the plus button
   * in the upper right corner is pressed, will add the tag
   * to the taglist by liking it once.
   */
  Future<Null> addTagDialog() async {
    addTag(await showDialog(context: context, child: new AddDialog()));
  }

  /**
   * creates the remove tag dialog created when the  cancel button
   * in the upper right corner is pressed, will remove the tag
   * from the taglist.
   */
  Future<Null> removeTagDialog() async {
    stack.list.tagList.removeTag(
      await showDialog(context: context, child: new RemoveDialog()),
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
                  addName(text
                      .toLowerCase()); //check the name to see if it is available, add it if it is
                });
              },
            ),
            FlatButton(
              onPressed: () {
                if (checked) //if its checked and added, exit
                  Navigator.pop(context);
                else
                  setState(() {
                    buttonText = "Name Taken";
                  });
              },
              child: Text(buttonText),
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
    var response = await Firestore.instance
        .collection("users")
        .where(name, isEqualTo: name.toLowerCase())
        .getDocuments();
    print(response.documents.isEmpty);
    return response.documents.isEmpty;
  }

  /**
   * checks the name given before adding it to 
   * both the database and the username list
   * @param the name that is attempting to be added
   */
  void addName(String name) async {
    checked = await checkName(name); //check the name
    if (checked) {
      UserName newUser =
          new UserName(name.toLowerCase()); //create a new username
      names.add(name.toLowerCase()); //add it to the string list of names
      userNames.add(newUser); //add it to the username list
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(Firestore.instance.collection("users").document(),
            {"name": name.toLowerCase(), "number": newUser.id});
      });
      currentUser = name; //set the current user to the one that was just added
      var prefs =
          await SharedPreferences.getInstance(); //get the shared preferences
      String userNamesJson = encoder.convert(userNames);
      prefs.setString('names', userNamesJson); //save the usernames
    }
  }

  void share() async {
    Firestore.instance.runTransaction((transaction) async {
      await transaction
          .set(Firestore.instance.collection("listings").document(), {
        'title': stack.topListing.title,
        'text': stack.topListing.text,
        'link': stack.topListing.imgLink,
        'tag': stack.topListing.tag,
        'score': 0,
        'comments': stack.topListing.commentLink,
        'author': stack.topListing.author,
        'adjusted_score': 1,
        "shared_by": currentUser,
        'date_posted': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: new Icon(Icons.share),
            onPressed: () {
              share();
            },
          ),
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
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SharesPage(
                              username: currentUser,
                            )));
              },
            ),
            new ListTile(
              title: Text("My List"),
              trailing: Icon(Icons.list),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TagPage(list: stack.list.tagList)));
              },
            ),
            new ListTile(
              title: Text("Share Stak"),
              trailing: Icon(Icons.file_upload),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShareListPage(
                            list: stack.list.tagList, userName: currentUser)));
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
              onTap: () async {
                userNames = await showDialog(
                    context: context,
                    child: new AccountDialog(
                      userNames: userNames,
                    ));
                currentUser = userNames[userNames.length - 1].name;
              },
            ),
          ],
        ),
      ),
      body: new Center(child: stack),
    );
  }
}
