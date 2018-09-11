/**
 * this contains the classes that support the listing list class. they keep a constante
 * queue of content in listqueues which are a queue of listings containing data on the title
 * author etc. of a listing from either reddit or stakswipe
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'tag.dart';
import 'placeList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/**
 * stores the data for a single listing
 */
class Listing {
  String _imgLink;//different attributes of a listing
  String _author;
  String _text;
  String _tag;
  String _commentLink;
  String _title;
  String _source;
  String _id;

  Listing(this._imgLink, this._author, this._text, this._tag, this._commentLink,
      this._title, this._source, this._id);
  //getters for the different attributes
  get imgLink => _imgLink;
  get author => _author;
  get text => _text;
  get tag => _tag;
  get commentLink => _commentLink;
  get title => _title;
  get source => _source;
  get id => _id;
}

/**
 * stores the data for a single stakswipe server listing
 */
class StakListing extends Listing{
  String _imgLink;//different attributes of listing
  String _author;
  String _text;
  String _tag;
  String _commentLink;
  String _title;
  String _source;
  String _sharedBy;
  String _id;

  StakListing(this._imgLink, this._author, this._text, this._tag, this._commentLink,
      this._title, this._source, this._sharedBy, this._id ): super(_imgLink, _author, _text, _tag, _commentLink, _title, _source, _id);
  //getter methods for the different attributes
  get imgLink => _imgLink;
  get author => _author;
  get text => _text;
  get tag => _tag;
  get commentLink => _commentLink;
  get title => _title;
  get source => _source;
  get sharedBy => _sharedBy;
  get id => _id;

}

/**
 * used to store a continuously updating queue of listings for a given 
 * tag and make sure that the queue is up to date
 */
class ListingQueue {
  Queue<Listing> listingQ;//the queue where the listings will be stored
  String name;//the name of the tag
  String source;//the source of the tag
  JsonDecoder decoder;
  String place;//the place where the tag is at

  ListingQueue(this.name, this.place, this.source) {
    decoder = new JsonDecoder();
    listingQ = new Queue();
  }
  
  /**
   * used to update the tag and make sure the queue doesn't drop below
   * half of its percentage in the taglist or 10 listings, whichever
   * is smaller
   * @param percent the percent in the taglist that the tag possesses
   */
  Future<bool> updateTag(int percent) async {
    if (listingQ.length < percent / 2 && listingQ.length <= 5) {//check if it needs to be updated
      int numToAdd = min(percent-listingQ.length, 5);//finds how much it needs to add
      if (source == "reddit") {//check source
        var response;
        if (place == "not in") {
          //if its not in gets the first one lin the list
          response = await http.get(//get the listings from the reddit api
              Uri.encodeFull(
                  "https://www.reddit.com/r/$name.json?limit=$numToAdd;"),
              headers: {"Accept": "applications/json"});
        } else {
          //else goes to the specified place in the tag
          response = await http.get(
              Uri.encodeFull(
                  "https://www.reddit.com/r/$name.json?limit=$numToAdd;after=$place;"),
              headers: {"Accept": "applications/json"});
        }
        var responseJson = decoder.convert(response.body);//convert the json of the listings
        for (var l in responseJson["data"]["children"]) {
          Listing listing;
          if (l['data'] != null) {//convert the dynamic map objecs obtained from the conversion and turn them into listings
            String imgLink = l["data"]["url"];
            String author = l["data"]["author"];
            String text = l["data"]["selftext"];
            String commentLink = l["data"]["permalink"];
            String title = l["data"]["title"];
            String tag;
            if(name=="popular")
              tag = l["data"]["subreddit"].toLowerCase();
            else tag = name;
            
            listing = new Listing(
                imgLink, author, text, tag, commentLink, title, source, place);
          } else {
            listing = new Listing(//if nothing is recieved give an error listing
                "https://i.imgur.com/yFW1GdD.png",
                "error loading",
                "error loading",
                "error loading",
                "error loading",
                "error loading",
                "error Loading",
                "error loading");
          }
          
          listingQ.addFirst(listing);//add the new listing in
        }
        place = responseJson["data"]["after"];//set the place using the after attribute
        return true;
      } else if (source == "stakswipe") {
        var snapshot = await Firestore.instance//pull a stream of listings from the firestore server
            .collection('listings')
            .orderBy('adjusted_score')
            .where('tag', isEqualTo: name)
            .where('adjusted_score', isLessThan: int.parse(place))
            .getDocuments();
        var data = snapshot.documents;
        if(data.isEmpty)
          return false;
        for (var l in data) {//convert the list of documents into a list of listings
          String title = l.data['title'];
          String author = l.data['author'];
          String link = l.data['link'];
          String text = l.data['text'];
          String comments = l.data['comments'];
          String id = l.documentID;
          place = l.data['adjusted_score'].toString();
          listingQ.add(new StakListing(
              link, author, text, name, comments, title, source, "", id));
        }
        return true;
      }
      else if(source == "stakuser"){
        //get both author and shared_by streams from the server
        var authorSnapshot;
        var sharedSnapshot;
        if(place == "not in"){
       authorSnapshot = await Firestore.instance.collection("listings").orderBy("adjusted_score").where("author", isEqualTo: name).limit(numToAdd).getDocuments();
        sharedSnapshot = await Firestore.instance.collection("listings").orderBy("adjusted_score").where("shared_by", isEqualTo: name).limit(numToAdd).getDocuments();
      }
      else{
        authorSnapshot = await Firestore.instance.collection("listings").orderBy("adjusted_score").where("author", isEqualTo: name).limit(numToAdd).where("adjusted_score", isLessThanOrEqualTo:  int.parse(place)).getDocuments();
        sharedSnapshot = await Firestore.instance.collection("listings").orderBy("adjusted_score").where("shared_by", isEqualTo: name).limit(numToAdd).where("adjusted_score", isLessThanOrEqualTo:  int.parse(place)).getDocuments();
      }
        var data = List();
        List authorList= authorSnapshot.documents;
        List sharedList = sharedSnapshot.documents;
        for(var c in sharedList){//add shared_by to the author part of the listing
          c.data['author']= "${c.data['author']} shared by: ${c.data['shared_by']}";
        }
        if(sharedList.isEmpty && authorList.isEmpty)
        return false;
        if(sharedList.isEmpty)
        data = authorList;
        else if(authorList.isEmpty)
        data = sharedList;
        else{
          int sharedIndex= 0;
        int authorIndex = 0;
        while(data.length<= numToAdd){//insert the documents into a combined list ordered by adjusted_score
          if(sharedList[sharedIndex]['adjusted_score']>authorList[authorIndex]['adjusted_score']){
            data.add(sharedList[sharedIndex]);
            sharedIndex++;
          }
          else{
            data.add(authorList[authorIndex]);
            authorIndex++;
          }
        }
        }
        for (var l in data) {//add the combined list to the queue
          String title = l.data['title'];
          String author = l.data['author'];
          String link = l.data['link'];
          String text = l.data['text'];
          String comments = l.data['comments'];
          String tag = l.data['tag'];
          String id = l.documentID;
          place = l.data['adjusted_score'].toString();
          listingQ.add(new StakListing(
              link, author, text, tag, comments, title, source, "", id));
        }
        return true;
      }
    }
  }

  /**
   * takes the first listing from the queue
   */
  Listing take() {
    return listingQ.removeFirst();
  }
}

/**
 * contains and updates listingqueues for all the tags in the taglist that
 * have a positive percentage. allows to pull a listing to create into a 
 * content card
 */
class ListingList {
  TagList tagList;//holds all the tag, rating and like information
  PlaceList placeList;//holds the place in each content source for each tag
  List<ListingQueue> list;//the list of listingqueues
  JsonDecoder decoder;
  JsonEncoder encoder;
  int introCardIndex;//used to determine if intro cards are needed

  ListingList() {
    decoder = new JsonDecoder();
    encoder = new JsonEncoder();
    list = new List();//initialize the lists
    tagList = new TagList();
    placeList = new PlaceList();
    introCardIndex = 3;
    restore();//restore the taglist and placelist from shared preferences
    for (Tag t in tagList.allTags) {//start adding to the list
      list.add(new ListingQueue(
          t.name,
          placeList.getPlace(t.name, t.type),
          t.type));
    }
  }

  /**
   * gets a listing from the list determined by a random tag gotten
   * from the taglist and then pops the first listing off of the corresponding
   * listing queue of the given tag
   */
  Listing getListing() {
    bool isEmpty;
    if(introCardIndex<3){//used to add introcards if needed
      List<Listing> intro = introCards();
      introCardIndex++;
      return intro[introCardIndex-1];
    }
    if(introCardIndex == 3)
      tagList.removeTag(new SourceName("Intro", "reddit"));
    do {
      isEmpty = true;
      SourceName newTag = tagList.getTag();//get the tag
      for (ListingQueue q in list) {//search through the list to find it
        if (q.name == newTag.name) {
          if (q.listingQ.isEmpty) {//if it is empty return
            isEmpty = true;
            break;
          }
          else
            isEmpty = false;
          Listing listing = q.take();//take from the corresponding q
          q.updateTag(tagList.getPercent(newTag.name, newTag.source).ceil());//update the given tag to make sure the queue is full
          placeList.setPlace(newTag.name, newTag.source, q.place);//st the place to save for later
          return listing;
        }
      }
    } while (isEmpty);
  }

  /**
   * used to adjust the score after liking or disliking a listing
   * from the stakswipe servers.
   * [score] the score of the listing
   *  [time] the time the listing was posted
   */
  num adjuster(int score, DateTime time){
    Duration age = time.difference(DateTime.now());
    num adjusted = score*(-pow((age.inHours-5), 0.333)+2);
    return adjusted;

  }

  /**
   * likes the given tag and increases the score of the corresponding
   * id of the tag
   * [tag] the tag to be liked
   * [id] the id of the listing that was liked
   */
  Future<bool> like({SourceName tag, String id}) async{
    tagList.like(tag.name, tag.source);//like the listing in the taglist
    if (tag.source == "stakuser" || tag.source == "stakswipe"){//if it is from stakswipe update its score and adjusted score
      /**await Firestore.instance.runTransaction((transaction) async{
        var freshSnap = await transaction.get(Firestore.instance.collection('listings').document(id));
        await transaction.update(freshSnap.reference, {
         'score': freshSnap.data['score']++,
         'adjusted_score': adjuster(freshSnap.data['score'], freshSnap.data['date_posted'])
        });
      }).whenComplete((){});**/
      var data = await Firestore.instance.collection("listings").document(id).get();
      int score =data["score"];
      DateTime posted = data["date_posted"];
      int newscore = score+1;
      double newAdjusted = adjuster(newscore, posted);
      await Firestore.instance.collection("listings").document(id).updateData({'score': newscore, 'adjusted_score': newAdjusted});

    }
    save();
    return true;
  }


  /**
   * dislikes the current tag and decreases the score of
   * stakswipe listings
   *  [tag] the tag to be disliked
   * [id] the id of the listing that was disliked
   */
  Future<bool> dislike({SourceName tag, String id})async {
    tagList.dislike(tag.name, tag.source);//dislike the listing in the taglist
    if (tag.source == "stakuser" || tag.source == "stakswipe"){//if its from stakswipe update the scores and adjusted scores
     /**await Firestore.instance.runTransaction((transaction) async{
        var freshSnap = await transaction.get(Firestore.instance.collection('listings').document(id));
        await transaction.update(freshSnap.reference, {
         'score': freshSnap.data['score']--,
         'adjusted_score': adjuster(freshSnap.data['score'], freshSnap.data['date_posted'])
        });
      }).whenComplete((){});**/
    var data = await Firestore.instance.collection("listings").document(id).get();
      int score =data["score"];
      DateTime posted = data["date_posted"];
      int newscore = score--;
      int newAdjusted = adjuster(newscore, posted);
      await Firestore.instance.collection("listings").document(id).updateData({'score': newscore, 'adjusted_score': newAdjusted});
  }
    save();
    return true;
  }

  /**
   * save the current taglist and placelist
   * in the sharedpreferences as a json
   */
  void save() async {
    var prefs =
        await SharedPreferences.getInstance(); //get the shared preferences
    //convert the taglist and placelist into jsons
    String taglistJson = encoder.convert(tagList);
    String placeJson = encoder.convert(placeList);
    //store those string in the preferences
    prefs.setString('place', placeJson);
    prefs.setString('taglist', taglistJson);
  }

  /**
   * restore the taglist and placelist from shared preferences 
   */
  void restore() async {
    var prefs =
        await SharedPreferences.getInstance(); //get the sharedpreferences
    //get the tagjson and placejson strings, if they aren't there return
    String tagJson = prefs.getString('taglist') ?? "0";
    String placeJson = prefs.getString('place') ?? "0";
    if (tagJson == "0") {
      introCardIndex = 0;
      return;
    }
    //convert them to a map
    Map tagmap = decoder.convert(tagJson);
    Map placemap = decoder.convert(placeJson);
    //convert that map into the taglist and placelist
    tagList = new TagList.fromJson(tagmap);
    placeList = new PlaceList.fromJson(placemap);
    
  }
  /**
   * updates the list to correspond to all the tags in the 
   * alltags list in the taglist and make sure each has
   * a listingQueue that is full
   */
  Future<bool> update()async{
    for(Tag t in tagList.allTags){//go through each tag in alltags
      bool found = false;
      for(ListingQueue l in list){//check if its already in the list
        if(l.name == t.name && l.source == t.type){
          await l.updateTag(tagList.getPercent(t.name, t.type).ceil());//if its in the list update it
          found = true;
          break;
        }
      }
      if(!found){//if its not in the list add a new listingqueue to the list
        ListingQueue newQ = new ListingQueue(
          t.name,
          placeList.getPlace(t.name, t.type),
          t.type);
        await newQ.updateTag(tagList.getPercent(t.name, t.type).ceil());
        list.add(newQ);

      }
    }
    return true;
  }

  /**
   * used to fill the queue with cards that explain the app the
   * first time someone runs it
   */
  List<Listing> introCards(){
    List<Listing> introList = new List();
    introList.add(new Listing("", "Michael", "StakSwipe is a media aggregation app to view all of you favorite content. Using the app is simple just right swipe stuff that you like or that you want to see more of and left swipe stuff that you want to see less, try it out swipe away this card", "Intro", "", "Welcome to Stakswipe", "reddit", ""));
    introList.add(new Listing("", "Michael", "Currently stakswipe takes from two sources reddit and its own server. If you want to Post to the stakswipe server press the button in the top right. You can also add or remove tags from your interests with the other two buttons to the left of the post button. In order to post You'll need a name swipe to see how to set that up", "Intro", "", "Other Features", "reddit", ""));
    introList.add(new Listing("", "Michael", "In the upper left is a button to open up the sidebar. In there you can navigate to your posts, your list which contains all your interests as well as their percentages and you can create a name. Names are completely optionial in stakswipe, you only need one if you want to post content. Creating a name in stakswipe is easy, just pick a name and hit enter if its available you can hit submit. No password is required and the name is tied to your device so no one else can impersonate you. Now your ready to start swipe on this to start going through content.", "Intro","", "The sidebar", "reddit", ""));
    return introList;
  }
}
