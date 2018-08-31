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

class Listing {
  String _imgLink;
  String _author;
  String _text;
  String _tag;
  String _commentLink;
  String _title;
  String _source;
  String _id;

  Listing(this._imgLink, this._author, this._text, this._tag, this._commentLink,
      this._title, this._source, this._id);
  get imgLink => _imgLink;
  get author => _author;
  get text => _text;
  get tag => _tag;
  get commentLink => _commentLink;
  get title => _title;
  get source => _source;
  get id => _id;
}

class StakListing extends Listing{
  String _imgLink;
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

class ListingQueue {
  Queue<Listing> listingQ;
  String name;
  String source;
  JsonDecoder decoder;
  String place;

  ListingQueue(this.name, this.place, this.source) {
    decoder = new JsonDecoder();
    listingQ = new Queue();
  }
  
  Future<bool> updateTag(int percent) async {
    if (listingQ.length < percent / 2 && listingQ.length <= 5) {
      int numToAdd = min(percent-listingQ.length, 5);
      if (source == "reddit") {
        var response;
        if (place == "not in") {
          //if its not in gets the first one lin the list
          response = await http.get(
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
        var responseJson = decoder.convert(response.body);
        for (var l in responseJson["data"]["children"]) {
          Listing listing;
          if (l['data'] != null) {
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
            listing = new Listing(
                "https://i.imgur.com/yFW1GdD.png",
                "error loading",
                "error loading",
                "error loading",
                "error loading",
                "error loading",
                "error Loading",
                "error loading");
          }
          
          listingQ.addFirst(listing);
        }
        place = responseJson["data"]["after"];
        return true;
      } else if (source == "stakswipe") {
        var snapshot = Firestore.instance
            .collection('listings')
            .orderBy('adjusted_score')
            .where('tag', isEqualTo: name)
            .where('adjusted_score', isLessThan: place)
            .snapshots();
        var data = List();
        await for (var c in snapshot) {
          data.add(c);
          if (data.length > numToAdd) break;
        }
        for (var l in data) {
          String title = l['title'];
          String author = l['author'];
          String link = l['link'];
          String text = l['text'];
          String comments = l['comments'];
          String id = l.documentId();
          place = l['adjusted_score'];
          listingQ.add(new StakListing(
              link, author, text, name, comments, title, source, "", id));
        }
        return true;
      }
    }
  }

  Listing take() {
    return listingQ.removeFirst();
  }
}

class ListingList {
  TagList tagList;
  PlaceList placeList;
  List<ListingQueue> list;
  JsonDecoder decoder;
  JsonEncoder encoder;
  int introCardIndex;

  ListingList() {
    decoder = new JsonDecoder();
    encoder = new JsonEncoder();
    list = new List();
    tagList = new TagList();
    placeList = new PlaceList();
    introCardIndex = 3;
    restore();
    for (Tag t in tagList.allTags) {
      list.add(new ListingQueue(
          t.name,
          placeList.getPlace(t.name, t.type),
          t.type));
    }
  }

  Listing getListing() {
    bool isEmpty;
    if(introCardIndex<3){
      return introCards()[introCardIndex];
      introCardIndex++;
    }
    do {
      isEmpty = true;
      SourceName newTag = tagList.getTag();
      for (ListingQueue q in list) {
        if (q.name == newTag.name) {
          if (q.listingQ.isEmpty) {
            isEmpty = true;
            break;
          }
          else
            isEmpty = false;
          Listing listing = q.take();
          q.updateTag(tagList.getPercent(newTag.name, newTag.source).ceil());
          placeList.setPlace(newTag.name, newTag.source, q.place);
          return listing;
        }
      }
    } while (isEmpty);
  }

  void like({SourceName tag, String id}) {
    tagList.like(tag.name, tag.source);
    if (tag.source == "stakuser" || tag.source == "stakswipe")
      Firestore.instance.runTransaction((transaction) async{
        var freshSnap = await transaction.get(Firestore.instance.collection('listings').document(id));
        await transaction.update(freshSnap.reference, {
         'score': freshSnap.data['score']++
        });
      });
    save();
  }

  void dislike({SourceName tag, String id}) {
    tagList.dislike(tag.name, tag.source);
    if (tag.source == "stakuser" || tag.source == "stakswipe")
      Firestore.instance.runTransaction((transaction) async{
        var freshSnap = await transaction.get(Firestore.instance.collection('listings').document(id));
        await transaction.update(freshSnap.reference, {
         'score': freshSnap.data['score']--,
        });
      });
    save();
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
  Future<bool> update()async{
    for(Tag t in tagList.allTags){
      bool found = false;
      for(ListingQueue l in list){
        if(l.name == t.name && l.source == t.type){
          await l.updateTag(tagList.getPercent(t.name, t.type).ceil());
          found = true;
          break;
        }
      }
      if(!found){
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

  List<Listing> introCards(){
    List<Listing> introList = new List();
    introList.add(new Listing("", "Michael", "StakSwipe is a media aggregation app to view all of you favorite content. Using the app is simple jusr right swipe stuff that you like or want to see more of and left swipe stuff hat you want to see less, try it out swipe away this card", "Intro", "", "Welcome to Stakswipe", "reddit", ""));
    introList.add(new Listing("", "Michael", "Currently stakswipe takes from two sources reddit and its own server. If you want to Post to the stakswipe server press the button in the top right. You can also add or remove tags from your interests with the other two buttons to the left of the post button. In order to post You'll need a name swipe to see how to set that up", "Intro", "", "Other Features", "reddit", ""));
    introList.add(new Listing("", "Michael", "In the upper left is a button to open up the sidebar. In there you can navigate to your posts, your list which contains all your interests as well as their percentages and you can create a name. Names are completely optionial in stakswipe, you only need one if you want to post content. Creating a name in stakswipe is easy, just pick a name and hit enter if its available you can hit submit. No password is required and the name is tied to your device so no one else can impersonate you. Now your ready to start swipe on this to start going through content.", "Intro","", "The sidebar", "reddit", ""));
  }
}
