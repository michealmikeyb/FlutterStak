import 'package:flutter/material.dart';
import 'listing.dart';
import 'comments.dart';

class ContentCard extends StatelessWidget{
  Listing listing;
  ContentCard({Key key, this.listing}):super(key: key);

  Widget build(BuildContext context){
    return Card(
                //the card
                elevation: 50.0,
                child: new ListView(
                  children: <Widget>[
                    new Text(
                      "Posted on: ${listing.tag} \n By: ${listing.author}", //where it came from
                      style: new TextStyle(fontSize: 15.0, color: Colors.grey),
                      textAlign: TextAlign.left,
                    ),
                    new Text(
                      //the title
                      listing.title,
                      style: new TextStyle(fontSize: 25.0, color: Colors.black),
                    ),
                    new Image.network(listing.imgLink), //the corresponding picture
                    new Text("${listing.text} \nComments:"),
                    new Comment(
                      url: "https://www.reddit.com${listing.commentLink}.json",
                    )
                  ],
                ),
              );
  }

}