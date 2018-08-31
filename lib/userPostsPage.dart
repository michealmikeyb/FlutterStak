import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'userPostsPage.g.dart';

class PostsPage extends StatefulWidget {
  PostsPage({Key key, this.username}) : super(key: key);
  String username;

  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final String stakServerUrl = "68.42.250.122";
  String name;
  JsonDecoder decoder;
  void initState() {
    name = widget.username;
    decoder = new JsonDecoder();
  }

  Future<String> getData() async {
    var response = await http.get(
        "http://$stakServerUrl/stakSwipe/getUserPosts.php?author=$name",
        headers: {"Accept": "applications/json"});
    return response.body;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("$name's Posts"),
      ),
      body: new Center(
        child: new StreamBuilder(
          stream: Firestore.instance.collection("listings").where("author", isEqualTo: name).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(!snapshot.hasData)
              return CircularProgressIndicator();
            var data = snapshot.data.documents;
            return new ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                print(data[index].data["link"]);
                return new Card(
                  child: Column(
                    children: <Widget>[
                      Text("Posted on: ${data[index].data["tag"]}"),
                      Text("Score: ${data[index].data["score"]}"),
                      Text(data[index].data["title"], style: new TextStyle(fontSize: 25.0, color: Colors.black),),
                      Image.network(data[index].data["link"]),
                      Text(data[index].data["text"]??""),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

@JsonSerializable()
class Post {
  String title;
  String score;
  String link;
  String tag;

  Post(this.title, this.score, this.link, this.tag);

  Map<String, dynamic> toJson() => {
        "title": title,
        "score": score,
        "link": link,
        "tag": tag,
      };
  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
