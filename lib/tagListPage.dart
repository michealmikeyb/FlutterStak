/**
 * displays a page that contains all the users
 * tags as well as their corresponding percentage in the list
 */
import 'tag.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class TagPage extends StatelessWidget{
  TagPage({Key key, this.list}): super(key: key);
  TagList list;//the taglist taken from previous page

  Widget build(BuildContext context){
    return new Scaffold(
      appBar: AppBar(
        title: Text("Tag List "),
      ),
      body:ListView.builder(//make a list of length of alltags
      itemCount: list.allTags.length,
      itemBuilder: (BuildContext context, int index){
        int percent = list.getPercent(list.allTags[index].name, list.allTags[index].type).round();//get the percent in the list
        if(percent>0){//if it has places in the list display a list tile
        return ListTile(
          title: Text(list.allTags[index].name),
          subtitle: Text("Percent: ${percent}"),);
      }
      //else return an empty container
        return Container();
      },
      ),
    );
  }
}