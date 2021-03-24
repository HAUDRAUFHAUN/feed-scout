import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:url_launcher/url_launcher.dart';

class ListItem extends StatelessWidget {
  ListItem(
      {Key key,
      this.title: "false",
      this.description: "some description",
      this.url: "https://duckduckgo.com"})
      : super(key: key);

  final String title;
  final String description;

  final String url;

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Text(description),
          ],
        ),
      ),
    );
  }
}
