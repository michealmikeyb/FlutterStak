import 'package:flutter/material.dart';
import 'listing.dart';
import 'comments.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'tag.dart';

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

class CardStack extends StatefulWidget{
  CardStack({Key key, this.list }):super(key: key);
  ListingList list;
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack>{
  Queue<Widget> cardQ;
  ListingList list;
  int stackSize;
  int index;

  void initState() {
    cardQ = new Queue();
    
    list = widget.list;
    stackSize = 3;
    index = 0;
    
    fillQ();
  }

  void removeCard(){
    setState((){
    cardQ.removeLast();
    fillQ();
    });
  }

  void fillQ() async{
    await list.update();
    while(cardQ.length<=stackSize){
      Listing newListing = list.getListing();
      cardQ.addFirst(new Dismissible(
        key: new Key("$index"),
        onDismissed:(direction){
          removeCard();
          switch (direction) {
            case DismissDirection.startToEnd:
            list.like(tag: new SourceName(newListing.tag, newListing.source),id: newListing.id);
            break;
            case DismissDirection.endToStart:
            list.dislike(tag: new SourceName(newListing.tag, newListing.source), id: newListing.id);
            break;
            default:
            break;
          }
        } ,
        child: new ContentCard(listing: newListing),
      ));
      index++;
    }
    
    setState(() {
          
        });
  }

 
  Widget build(BuildContext context){
    List<Widget> cardList = cardQ.toList(); 
    if(cardQ == null || cardQ.isEmpty)
      return new ContentCard(listing: new Listing("https://i.imgur.com/yFW1GdD.png", "", "welcome to StakSwipe", "", "", "Loading", "", ""));
    return new Stack(children: cardList);
  }
}