import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostingPage extends StatefulWidget {
  PostingPage({Key key, this.username}) : super(key: key);
  String username;
  _PostingPageState createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  JsonDecoder decoder;
  String title;
  String link;
  String tag;
  String text;
  String sampleImg;
  final String stakServerUrl = "http://68.42.250.122/stakSwipe/postListing.php";

  void initState() {
    title = "";
    sampleImg = "https://i.imgur.com/XuojtF6.png";
    tag = "";
  }

  void Post() async {
    Firestore.instance.runTransaction((transaction) async {
     await transaction
         .set(Firestore.instance.collection("listings").document(), {
       'title': title,
       'text': text,
       'link': link,
       'tag': tag,
       'score': 0,
       'comments': "",
       'author': widget.username,
       'adjusted_score': 1,
       'date_posted': DateTime.now(),
     });
   });

  }

  Future<String> _pickSaveImage(String imageId) async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    StorageReference ref =
    FirebaseStorage.instance.ref().child("images").child("$title.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
  return (await uploadTask.future).downloadUrl.toString();
}

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Post to StakSwipe"),
      ),
      body: ListView(
        children: <Widget>[
          new TextField(
            decoration: InputDecoration(
              labelText: "Title"
            ),
            onChanged: (text) {
              setState(() {
                title = text;
              });
            },
          ),
          Row(children:<Widget>[ 
            RaisedButton(
              child: Text("Pick a picture from your phone"),
              onPressed: ()async{
                link = await _pickSaveImage("newImage");
                setState(() { });
                sampleImg = link;
              },),]),
          new TextField(
            decoration: InputDecoration(
              labelText: "Image Link"
            ),
            onChanged: (text) {
              setState(() {
                link = text;
              });
            },
            onSubmitted: (text) {
              setState(() {
                sampleImg = text;
              });
            },
          ),
          new TextField(
            decoration: InputDecoration(
              labelText: "Tag"
            ),
            onChanged: (text) {
              setState(() {
                tag = text;
              });
            },
          ),
          new TextField(
            decoration: InputDecoration(
              labelText: "Text"
            ),
            onChanged: (enteredtext) {
              setState(() {
                text = enteredtext;
              });
            },
          ),
          RaisedButton(
            child: Text("Submit"),
            onPressed: () {
              print(
                  "tag: $tag link: $link title: $title name ${widget.username}");
              Post();
              Navigator.pop(context);
            },
          ),
          Center(
            child: Text(
              "Sample Card",
              style: new TextStyle(fontSize: 25.0, color: Colors.black),
            ),
          ),
          new Card(
              child: new Column(
            children: <Widget>[
              new Text(
                "Posted on: $tag \n By: ${widget.username}", //where it came from
                style: new TextStyle(fontSize: 15.0, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
              new Text(
                //the title
                title,
                style: new TextStyle(fontSize: 25.0, color: Colors.black),
              ),
              new Image.network(sampleImg),
            ],
          ))
        ],
      ),
    );
  }
}
