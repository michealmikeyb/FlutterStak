import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SharesPage extends StatefulWidget {
  SharesPage({Key key, this.username}) : super(key: key);
  String username;

  _SharesPageState createState() => _SharesPageState();
}

class _SharesPageState extends State<SharesPage> {
  final String stakServerUrl = "68.42.250.122";
  String name;
  JsonDecoder decoder;
  void initState() {
    name = widget.username;
    decoder = new JsonDecoder();
  }

  Future<String> getData() async {
    var response = await http.get(
        "http://$stakServerUrl/stakSwipe/getUserShares.php?name=$name",
        headers: {"Accept": "applications/json"});
    return response.body;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("$name's Shares"),
      ),
      body: new Center(
        child: new StreamBuilder(
          stream: Firestore.instance.collection("listings").where("shared_by", isEqualTo: name).snapshots(),
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
                      new Text(
                      "Posted on: ${data[index].data["tag"]} \n By: ${data[index].data["author"]}", //where it came from
                      style: new TextStyle(fontSize: 15.0, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
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