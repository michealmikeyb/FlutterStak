import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'tag.dart';
import 'placeList.dart';

class Listing{
  String _imgLink;
  String _author;
  String _text;
  String _tag;
  String _commentLink;
  String _title;
  String _sharedBy;

  Listing(this._imgLink, this._author, this._text, this._tag, this._commentLink, this._title);
  get imgLink => _imgLink;
  get author => _author;
  get text => _text;
  get tag => _tag;
  get commentLink => _commentLink;
  get title => _title;

}

class ListingQueue{
  Queue<Listing> listingQ;
  String name;
  JsonDecoder decoder;
  String place;

  ListingQueue(this.name, int percent, this.place){
    decoder = new JsonDecoder();
    
    updateTag(percent);
    
  }
  void updateTag(int percent)async{
    if(listingQ.length < percent/2){
      int numToAdd = percent- listingQ.length;
      var response;
       if (place == "not in") {
        //if its not in gets the first one lin the list
        response = await http.get(
            Uri.encodeFull("https://www.reddit.com/r/$name.json?limit=$numToAdd;"),
            headers: {"Accept": "applications/json"});
      } else {
        //else goes to the specified place in the tag
        response = await http.get(
            Uri.encodeFull(
                "https://www.reddit.com/r/$name.json?limit=$numToAdd;after=$place;"),
            headers: {"Accept": "applications/json"});
      }
      var responseJson = decoder.convert(response.body);
      for(var l in responseJson){
        Listing listing;
        if(l['data']!=null){
          String imgLink = l["data"]["children"][0]["data"]["url"];
          String author= l["data"]["children"][0]["data"]["author"];
          String text = l["data"]["children"][0]["data"]["selftext"];
          String tag = name;
          String commentLink = l["data"]["children"][0]["data"]["permalink"];
          String title = l["data"]["children"][0]["data"]["title"];
          place = l["data"]["after"];
          listing = new Listing(imgLink, author, text, tag, commentLink, title);
        }
        else{
          listing = new Listing("https://i.imgur.com/yFW1GdD.png", "error loading", "error loading", "error loading", "error loading", "error loading");
        }
        listingQ.addFirst(listing);
      }
    }
  }

  Listing take(){
    return listingQ.removeFirst();
  }

}

class ListingList{
  TagList tagList;
  PlaceList placeList;
  List<ListingQueue> list;

  ListingList(this.tagList, this.placeList){
    for(Tag t in tagList.allTags){
      list.add(new ListingQueue(t.name, tagList.getPercent(t.name, t.type).ceil(), placeList.getPlace(t.name, t.type)));
    }
  }

  Listing getListing(){
    SourceName newTag = tagList.getTag();
    for(ListingQueue q in list){
      if(q.name == newTag.name){
        Listing listing = q.take();
        q.updateTag(tagList.getPercent(newTag.name, newTag.source).ceil());
        placeList.setPlace(newTag.name, newTag.source, q.place);
      }
    }
  }

  void like(SourceName tag){
    tagList.like(tag.name, tag.source);
  }
  void dislike(SourceName tag){
    tagList.dislike(tag.name, tag.source);
  }

}