/**
 * displays a page that contains all the users
 * tags as well as their corresponding percentage in the list
 */
import 'tag.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ShareListPage extends StatefulWidget {
  ShareListPage({Key key, this.list, this.userName}) : super(key: key);
  TagList list;
  String userName;
  _ShareListPageState createState() => new _ShareListPageState();
}

class _ShareListPageState extends State<ShareListPage> {
  TagList list; //the taglist taken from previous page
  String userName;
  String listName;
  bool nameChecked;

  void initState() {
    list = widget.list;
    userName = widget.userName;
    listName = "";
    nameChecked = false;
  }

  Future<bool> checkName(String name) async {
    var response = await Firestore.instance
        .collection("tag-lists")
        .where(name, isEqualTo: name.toLowerCase())
        .getDocuments();
    print(response.documents.isEmpty);
    return response.documents.isEmpty;
  }

  void submitList() {
    Firestore.instance.runTransaction((transaction) async {
      await transaction
          .set(Firestore.instance.collection("listings").document(), {
        'name': listName,
        'author': userName,
        'list': UploadableTagList(list).list,
      });
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("Tag List "),
        ),
        body: new Column(children: <Widget>[
          TextField(
            onSubmitted: (String text) async {
              if (await checkName(text)) {
                listName = text;
                nameChecked = true;
              } else {
                Scaffold.of(context).showSnackBar(new SnackBar(
                  duration: Duration(milliseconds: 500),
                  content: Text("Taglist name taken"),
                ));
              }
            },
          ),
          ListView.builder(
            //make a list of length of alltags
            itemCount: list.allTags.length,
            itemBuilder: (BuildContext context, int index) {
              int percent = list
                  .getPercent(
                      list.allTags[index].name, list.allTags[index].type)
                  .round(); //get the percent in the list
              if (percent > 0) {
                //if it has places in the list display a list tile
                return ListTile(
                  title: Text(list.allTags[index].name),
                  subtitle: Text("Percent: ${percent}"),
                );
              }
              //else return an empty container
              return Container();
            },
          ),
          RaisedButton(
            onPressed: () {
              if (nameChecked) {
                submitList();
                Navigator.pop(context);
              } else {
                Scaffold.of(context).showSnackBar(new SnackBar(
                  duration: Duration(milliseconds: 500),
                  content: Text("Pick a name thats not taken"),
                ));
              }
            },
          ),
        ]));
  }
}

class UploadableTagList {
  List<UploadableTag> list;
  TagList tagList;

  UploadableTagList(this.tagList) {
    list = new List();
    for (Tag t in tagList.allTags) {
      list.add(new UploadableTag(
          t.name, t.type, tagList.getPercent(t.name, t.type)));
    }
  }
}

class UploadableTag {
  String name;
  String source;
  double percent;

  UploadableTag(this.name, this.source, this.percent);
}
