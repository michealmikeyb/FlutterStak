import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Comment extends StatefulWidget {
  Comment({Key key, this.map, this.indent, this.url}) : super(key: key);
  Map<String, dynamic> map;
  final int indent;
  String url;
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  Future<List<dynamic>> fromUrl() async {
    JsonDecoder decoder = new JsonDecoder();
    var response = await http.get(Uri.encodeFull(widget.url),
        headers: {"Accept": "applications/json"});
    var mapjson = decoder.convert(response.body);
    return mapjson[1]["data"]["children"];
  }

  List<Widget> getComments(List<dynamic> list, int i) {
    List<Widget> endList = new List();
    for (var c in list) {
      if (c["data"]["body"] != null)
        endList.add(Comment(
          map: c,
          indent: i,
        ));
    }
    return endList;
  }

  Widget build(BuildContext context) {
    if (widget.url != null) {
      return FutureBuilder(
          future: fromUrl(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            var list = snapshot.data;
            List<Widget> widgetList = getComments(list, 0);
            return Column(
              children: widgetList,
            );
          });
    } else {
      String indent ="";
      for(int i = 0; i< widget.indent; i++){
        indent+="  ";
      }
      if (widget.map["data"]["replies"] != "") {
        return Column(
          children: <Widget>[ListTile(
                    title: Text(
                      (indent+widget.map["data"]["body"]),
                      textAlign: TextAlign.left,
                    ),
                  ),
              ] +
              getComments(
                  widget.map["data"]["replies"]["data"]["children"], widget.indent+1),
        );
      } else {
        return ListTile(
            title: Text(
              (indent+widget.map["data"]["body"]),
              textAlign: TextAlign.left,
            ),
        );
      }
    }
    /** 
          return ListView.builder(
            itemCount: 6,
            itemBuilder: (BuildContext context, int index) {
              print("comment body: ${map[index]["data"]["body"]}");
              if (map[index]["data"]["replies"] == "") {
                return new ListTile(
                  title: new Text(map[index]["data"]["body"]),
                );
              } else {
                return new Column(
                  children: <Widget>[
                    new Text(map[index]["data"]["body"]),
                    new Comments(
                      map: map[index]["data"]["replies"]["data"]["children"],
                      indent: indent++,
                    )
                  ],
                );
              }
            },
          );
        },
      );
    }
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (BuildContext context, int index) {
        print("comment body: ${map[index]["data"]["body"]}");
        if (map[index]["data"]["replies"] == "") {
          return new ListTile(
            title: new Text(map[index]["data"]["body"]),
          );
        } else {
          return new Column(
            children: <Widget>[
              new Text(map[index]["data"]["body"]),
              new Comments(
                map: map[index]["data"]["replies"]["data"]["children"],
                indent: indent++,
              )
            ],
          );
        }**/
  }
}
