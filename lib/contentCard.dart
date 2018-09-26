/**
 * this contains the widgets CardStack and ContentCard
 * the content card diplays a listing as a content card with formatting
 * the cardstack is a stack of dismissible ContentCard that handles the dismissle and rating adjustment for a listingQueue
 */
import 'package:flutter/material.dart';
import 'listing.dart';
import 'comments.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'tag.dart';

/**
 * the Content card takes a listing and 
 * displays it as a formatted card
 */
class ContentCard extends StatelessWidget{
  Listing listing;//the listing to be displayed
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
                    new Comment(//parses the json from the comment link and turns it into a widget
                      url: "https://www.reddit.com${listing.commentLink}.json",
                    )
                  ],
                ),
              );
  }

}

/**
 * a stack of cards in that handles the dissmissle of the card widget
 * and the following rating adjustment for the listinglist
 */
class CardStack extends StatefulWidget{
  CardStack({Key key, this.list }):super(key: key);
  ListingList list;//the listingList that will hold listing data
  Listing topListing;
  _CardStackState createState() => _CardStackState();
}

class _CardStackState extends State<CardStack>{
  Queue<Widget> cardQ;//the queue of cards to that will be converted into a stack of contentcards
  Queue<Listing> listingQ;//used to keep track of the listing at the top of the stack
  ListingList list;//the listingList that will hold listing data
  int stackSize;
  int index;

  void initState() {
    cardQ = new Queue();//initialize the queues
    listingQ = new Queue();
    list = widget.list;//bring the listinglist over from the widget parameters
    stackSize = 3;//number of cards in the stack
    index = 0;
    
    fillQ();//fill the cardQ and listingQ
  }

  /**
   * removes the topcard in the stack and adds a new card to
   * the stack
   */
  Future<bool> removeCard() async{
    listingQ.removeLast();//remove the top listing
    cardQ.removeLast();//remove the top card
    await fillQ();//fill the queues
    setState(() {});
    widget.topListing = listingQ.last;//reset the current toplisting
    return true;
  }

  /**
   * fills the listingq and cardq with listings gotten from the list
   */
  Future<bool> fillQ() async{
    await list.update();//update the listinglist so it can fill the listingqueues in the listinglist
    while(cardQ.length<=stackSize){//get it back up to the proper size
      Listing newListing = list.getListing();//get a listing from the list and add it to the listingq
      listingQ.addFirst(newListing);
      cardQ.addFirst(new Dismissible(//create a new dismissible that holds the contentcard made from the newlisting
        key: new Key("$index"),
        onDismissed:(direction)async{//assign the logic to left and right swipes
          await removeCard();
          switch (direction) {
            case DismissDirection.startToEnd:
            await list.like(tag: new SourceName(newListing.tag, newListing.source),id: newListing.id);
            break;
            case DismissDirection.endToStart:
            await list.dislike(tag: new SourceName(newListing.tag, newListing.source), id: newListing.id);
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
        return true;
  }

 
  Widget build(BuildContext context){
    List<Widget> cardList = cardQ.toList();//make the cardq into a list that can be put in a stack widget
    if(cardQ == null || cardQ.isEmpty)//while its loading show stakswipe logo
      return new ContentCard(listing: new Listing("https://i.imgur.com/yFW1GdD.png", "", "welcome to StakSwipe", "", "", "Loading", "", ""));
    return new Stack(children: cardList);
  }
}