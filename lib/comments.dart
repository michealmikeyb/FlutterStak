/**
 * this handles the comments for reddit that are displayed below each 
 * of the card. it creates a tree of the comment widget where each is
 * held in a column where the replies to a comment are its children
 */
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Comment extends StatefulWidget {
  Comment({Key key, this.map, this.indent, this.url}) : super(key: key);
  Map<String, dynamic>
      map; //the map containing the body of the comment as well as the reply tree
  final int indent;
  String url;
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  /**
   * returns the list of comment maps from a url which
   * each of the comments initially starts off as
   */
  Future<List<dynamic>> fromUrl() async {
    JsonDecoder decoder = new JsonDecoder();
    var response = await http.get(Uri.encodeFull(widget.url), headers: {
      "Accept": "applications/json"
    }); //get the list from the server
    var mapjson = decoder.convert(response.body); //convert it to a list
    return mapjson[1]["data"][
        "children"]; //return the second one in the list, the first one is the content
  }

  /**
   * returns a list of widgets derived from a list of maps and converts
   * them each to a comment widget.
   * @param list the list of maps that contains each comments body and replies
   * @param i the indent/ level in the tree
   */
  List<Widget> getComments(List<dynamic> list, int i) {
    List<Widget> endList = new List(); //list to store the result in
    for (var c in list) {
      //go through the list given
      if (c["data"]["body"] != null) //skip if it doesn't have a body
        endList.add(Comment(
          //add it to the list
          map: c,
          indent: i,
        ));
    }
    return endList; //return the finished list
  }

  /**
   * build the comment tree
   */
  Widget build(BuildContext context) {
    if (widget.url != null) {
      //if a url was entered it becomes the root of a new tree
      return FutureBuilder(
          future: fromUrl(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) return Text("Loading Comments...");
            var list = snapshot.data; //get the list from the fromUrl method
            List<Widget> widgetList =
                getComments(list, 0); //make a list of comments from it
            return Column(
              //make a column of that list
              children: widgetList,
            );
          });
    } else {
      //else it is a non root node

      if (widget.map["data"]["replies"] != "") {
        //if it has replies append them to the end of the column
        return Column(
          children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.only(left: 20.0 * widget.indent),
                  title: Text(
                    (widget.map["data"]["body"]),
                    textAlign: TextAlign.left,
                  ),
                  subtitle: Text(
                      "Written by: ${widget.map["data"]["author"]} Score: ${widget.map["data"]["score"]}"),
                ),
              ] +
              getComments(
                  //add the replies below the parent comment and increment the indent
                  widget.map["data"]["replies"]["data"]["children"],
                  widget.indent + 1),
        );
      } else {
        //if it doesn't have any replies just return one of the list tiles
        return ListTile(
          contentPadding: EdgeInsets.only(left: 20.0 * widget.indent),
          title: Text(
            (widget.map["data"]["body"].replaceAll("&amp;", "&")),
            textAlign: TextAlign.left,
          ),
          subtitle: Text("written by: ${widget.map["data"]["author"]}"),
        );
      }
    }
  }
}
