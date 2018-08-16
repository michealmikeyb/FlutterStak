import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

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
                      Image.network(data[index]["link"]),
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