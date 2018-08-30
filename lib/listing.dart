import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  ListingQueue(this.name, int percent, this.place, this.source) {
    decoder = new JsonDecoder();

    updateTag(percent);
  }
  void updateTag(int percent) async {
    if (listingQ.length < percent / 2) {
      int numToAdd = percent - listingQ.length;
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
        for (var l in responseJson) {
          Listing listing;
          if (l['data'] != null) {
            String imgLink = l["data"]["children"][0]["data"]["url"];
            String author = l["data"]["children"][0]["data"]["author"];
            String text = l["data"]["children"][0]["data"]["selftext"];
            String tag = name;
            String commentLink = l["data"]["children"][0]["data"]["permalink"];
            String title = l["data"]["children"][0]["data"]["title"];
            place = l["data"]["after"];
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

  ListingList() {
    decoder = new JsonDecoder();
    encoder = new JsonEncoder();
    restore();
    for (Tag t in tagList.allTags) {
      list.add(new ListingQueue(
          t.name,
          tagList.getPercent(t.name, t.type).ceil(),
          placeList.getPlace(t.name, t.type),
          t.type));
    }
  }

  Listing getListing() {
    bool isEmpty;
    do {
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
          break;
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
      tagList = new TagList();
      placeList = new PlaceList();
      //setState(() {
      //cardq = introCard();
      //});
      return;
    }
    //convert them to a map
    Map tagmap = decoder.convert(tagJson);
    Map placemap = decoder.convert(placeJson);
    //convert that map into the taglist and placelist
    tagList = new TagList.fromJson(tagmap);
    placeList = new PlaceList.fromJson(placemap);
    /**cardq = new Queue();
    setState(() {
      cardq.add(newCard());
      cardq.add(newCard());
      cardq.add(newCard());
    });**/
  }
}
