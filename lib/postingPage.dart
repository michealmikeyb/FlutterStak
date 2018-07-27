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
  String title;
    String link;
    String tag;
  final String stakServerUrl = "http://10.0.0.169/stakSwipe/postListing.php";

  void initState(){
    
  }

  void Post()async{
    var response = await http.post(stakServerUrl, body: {"tag": tag, "link": link, "title": title, "author": widget.username });
    print(response.body);
  }
 
  Widget build(BuildContext context){
    
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
            onChanged: (text){
              setState(() {title = text;});},
          ),
          Text(
            "Link"
          ),
          new TextField(
            onChanged: (text){
            setState(() {link = text;});
            },
          ),
          Text(
            "Tag"
          ),
          new TextField(
            onChanged: (text){
            setState(() {tag = text;});
            },
          ),
          FlatButton(
            child: Text("Submit"),
            onPressed:(){
              print("tag: $tag link: $link title: $title name ${widget.username}");
              Post();
              Navigator.pop(context);} ,
          )
        ],
      ),
    );
  }
}