import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'tag.dart';

enum contentSource { reddit, stakswipe, stakuser }

class AddDialog extends StatefulWidget {
  AddDialog({Key key}) : super(key: key);

  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  String tag;
  contentSource source;
  Widget build(BuildContext context) {
    return SimpleDialog(
      //inflate a dialog
      title: new Text("Add a tag"),
      children: <Widget>[
        new TextField(
          onChanged: (text) {
            //update the tag when the text is changed
            setState(() {
              tag = text;
            });
          },
        ),
        new RadioListTile<contentSource>(
          //radio tiles to decide what source its from
          title: const Text("Reddit"),
          value: contentSource.reddit,
          groupValue: source,
          onChanged: (contentSource value) {
            setState(() {
              source = value;
            });
          },
        ),
        new RadioListTile<contentSource>(
          //radio tiles to decide what source its from
          title: const Text("Follow a name"),
          value: contentSource.stakuser,
          groupValue: source,
          onChanged: (contentSource value) {
            setState(() {
              source = value;
            });
          },
        ),
        new RadioListTile<contentSource>(
          title: const Text("StakSwipe"),
          value: contentSource.stakswipe,
          groupValue: source,
          onChanged: (contentSource value) {
            setState(() {
              source = value;
            });
          },
        ),
        FlatButton(
          //submit button
          child: Text("Add"),
          onPressed: () {
            String stringSource;
            switch (source) {
              case contentSource.reddit:
                stringSource = "reddit";
                break;
              case contentSource.stakswipe:
                stringSource = "stakswipe";
                break;
              case contentSource.stakuser:
                stringSource = "stakuser";
                break;
            }
            Navigator.pop(context, new SourceName(tag, stringSource));
          }, //after submitted pops it with a new sourcename
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(
                context,
                new SourceName("cancel",
                    "cancel")); //sets the sourcename to cancel so the addTag method can just return
          },
        )
      ],
    );
  }
}

class RemoveDialog extends StatefulWidget {
  RemoveDialog({Key key}) : super(key: key);

  _RemoveDialogState createState() => _RemoveDialogState();
}

class _RemoveDialogState extends State<RemoveDialog> {
  String tag;
  contentSource source;
  Widget build(BuildContext context) {
    return new SimpleDialog(
      title: new Text("Remove a tag"),
      children: <Widget>[
        new TextField(
          onChanged: (text) {
            //update the tag when the text is changed
            setState(() {
              tag = text;
            });
          },
        ),
        new RadioListTile<contentSource>(
          //radio tiles to decide what source its from
          title: const Text("Reddit"),
          value: contentSource.reddit,
          groupValue: source,
          onChanged: (contentSource value) {
            setState(() {
              source = value;
            });
          },
        ),
        new RadioListTile<contentSource>(
          //radio tiles to decide what source its from
          title: const Text("Unfollow a name"),
          value: contentSource.stakuser,
          groupValue: source,
          onChanged: (contentSource value) {
            setState(() {
              source = value;
            });
          },
        ),
        new RadioListTile<contentSource>(
          title: const Text("StakSwipe"),
          value: contentSource.stakswipe,
          groupValue: source,
          onChanged: (contentSource value) {
            setState(() {
              source = value;
            });
          },
        ),
        FlatButton(
          //submit button
          child: Text("remove"),
          onPressed: () {
            String stringSource;
            switch (source) {
              case contentSource.reddit:
                stringSource = "reddit";
                break;
              case contentSource.stakswipe:
                stringSource = "stakswipe";
                break;
              case contentSource.stakuser:
                stringSource = "stakuser";
                break;
            }
            Navigator.pop(context, new SourceName(tag, stringSource));
          }, //after submitted pops it with a new sourcename
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(
                context,
                new SourceName("cancel",
                    "cancel")); //sets the sourcename to cancel so the addTag method can just return
          },
        )
      ],
    );
  }
}
