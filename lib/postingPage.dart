import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'name.dart';


class PostingPage extends StatefulWidget{
  PostingPage({Key key, this.username}): super(key: key);
  String username;
  _PostingPageState createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage>{
  JsonDecoder decoder;
  final String stakServerUrl = "127.0.0.1/stakSwipe/postListing.php";

  void initState(){
    
  }

  
 
  Widget build(BuildContext context){
    String title;
    String link;
    String tag;
    return new Scaffold(
      appBar: AppBar(
        title: Text("Post to StakSwipe"),
      ),
      body: Column(
        children: <Widget>[
          new Text(
            "Title"
          ),
          new TextField(
            onSubmitted: (text){
              setState(() {title = text;});},
          ),
          Text(
            "Link"
          ),
          new TextField(
            onSubmitted: (text){
            setState(() {link = text;});
            },
          ),
          Text(
            "Tag"
          ),
          new TextField(
            onSubmitted: (text){
            setState(() {tag = text;});
            },
          ),
          FlatButton(
            child: Text("Submit"),
            onPressed:(){http.post(stakServerUrl, body: {"tag": tag, "link": link, "title": title, "author": widget.username });} ,
          )
        ],
      ),
    );
  }
}