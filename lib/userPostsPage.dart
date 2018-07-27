import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
part 'userPostsPage.g.dart';

class PostsPage extends StatefulWidget {
  PostsPage({Key key, this.username}) : super(key: key);
  String username;

  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final String stakServerUrl = "10.0.0.169";
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
        child: new FutureBuilder(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            var data = decoder.convert(snapshot.data);
            return new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if(index>=data.length)
                return Text("");
                return new Card(
                  child: Column(
                    children: <Widget>[
                      Text("Posted on: ${data[index]["tag"]}"),
                      Text("Score: ${data[index]["score"]}"),
                      Text(data[index]["title"], style: new TextStyle(fontSize: 25.0, color: Colors.black),),
                      Image.network("https://i.redd.it/x1l4g1t1xa911.jpg"),
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
