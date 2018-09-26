import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'tag.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'name.dart';

enum contentSource { reddit, stakswipe, stakuser }

class AddDialog extends StatefulWidget {
  AddDialog({Key key}) : super(key: key);

  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  String tag;
  contentSource source;
  Widget build(BuildContext context) {
    return SimpleDialog(
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
          //radio tiles to decide what source its from
          title: const Text("Follow a name"),
          value: contentSource.stakuser,
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
          child: Text("Add"),
          onPressed: () {
            String stringSource;
            switch (source) {
              case contentSource.reddit:
                stringSource = "reddit";
                break;
              case contentSource.stakswipe:
                stringSource = "stakswipe";
                break;
              case contentSource.stakuser:
                stringSource = "stakuser";
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
    );
  }
}

class RemoveDialog extends StatefulWidget {
  RemoveDialog({Key key}) : super(key: key);

  _RemoveDialogState createState() => _RemoveDialogState();
}

class _RemoveDialogState extends State<RemoveDialog> {
  String tag;
  contentSource source;
  Widget build(BuildContext context) {
    return new SimpleDialog(
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
          //radio tiles to decide what source its from
          title: const Text("Unfollow a name"),
          value: contentSource.stakuser,
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
          child: Text("remove"),
          onPressed: () {
            String stringSource;
            switch (source) {
              case contentSource.reddit:
                stringSource = "reddit";
                break;
              case contentSource.stakswipe:
                stringSource = "stakswipe";
                break;
              case contentSource.stakuser:
                stringSource = "stakuser";
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
    );
  }
}

class AccountDialog extends StatefulWidget{
  AccountDialog({Key key, this.userNames}): super(key: key);
  List<UserName> userNames;

  _AccountDialogState createState() => _AccountDialogState();
}

class _AccountDialogState extends State<AccountDialog>{
   bool checked;
   List<String> names;
  List<UserName> userNames;
  JsonEncoder encoder;
  String buttonText;

   void initState(){
     buttonText = "submit";
     userNames = widget.userNames;
     checked = false;
     encoder = new JsonEncoder();
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
        .where("name", isEqualTo: name)
        .getDocuments();
    print(response.documents.isEmpty);
    return response.documents.isEmpty;
  }

  /**
   * checks the name given before adding it to 
   * both the database and the username list
   * @param the name that is attempting to be added
   */
  Future<bool> addName(String name) async {
    checked = await checkName(name); //check the name
    if (await checkName(name)) {
      UserName newUser = new UserName(name.toLowerCase()); //create a new username
      userNames.add(newUser); //add it to the username list
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
            Firestore.instance.collection("users").document(),
            {"name": name.toLowerCase(), "number": newUser.id});
      });
      String currentUser = name; //set the current user to the one that was just added
      var prefs =
          await SharedPreferences.getInstance(); //get the shared preferences
      String userNamesJson = encoder.convert(userNames);
      prefs.setString('names', userNamesJson); //save the usernames
      return true;
    }
  }
  Widget build (BuildContext context){
        
        return SimpleDialog(
          title: Text("Create Account"),
          children: <Widget>[
            Text("Desired Name (press enter to check availability)"),
            TextField(
              onSubmitted: (text) {
                setState(()async {
                  await addName(
                     text.toLowerCase()); //check the name to see if it is available, add it if it is
                  if(checked)
                    buttonText = "Submit";
                  else
                      buttonText = "Name Taken";
                });
              },
            ),
            FlatButton(
              onPressed: () {
                if (checked) //if its checked and added, exit
                  Navigator.pop(context, userNames);
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
                Navigator.pop(context, widget.userNames);
              },
            )
          ],
        );
  }
}
