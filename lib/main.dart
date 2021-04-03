import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed/webfeed.dart';

import 'components/ListItem.dart';

import 'pages/AddFeed.dart';

void main() {
  runApp(MyApp());
}

Future getData(String url) async {
  var res = await http.get(Uri.parse(url));

  if (res.statusCode == 200) {
    var channel = RssFeed.parse(res.body);
    return channel;
  }

  return CircularProgressIndicator();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Feed Scout',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Feed Scout'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future feedData;

  @override
  void initState() {
    super.initState();
    feedData = getData("https://www.spiegel.de/schlagzeilen/index.rss");
  }

  @override
  void refresh() {
    super.setState(() {});
    feedData = getData("https://www.spiegel.de/schlagzeilen/index.rss");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed Scout"),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Icon(
                Icons.chrome_reader_mode_rounded,
                color: Colors.white,
                size: 72.0,
              ),
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
            ),
            ListTile(
              title: Text('Add feed'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddFeed()));
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        child: FutureBuilder(
          future: feedData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints:
                            BoxConstraints(minWidth: 100, maxWidth: 150),
                        padding: EdgeInsets.all(10),
                        child:
                            Image(image: NetworkImage(snapshot.data.image.url)),
                      ),
                    ],
                  ),
                  for (var item in snapshot.data.items)
                    ListItem(
                        title: item.title,
                        description: item.description,
                        url: item.link)
                ],
              );
            } else if (snapshot.hasError) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Text("Something is gone wrong: \n ${snapshot.error}"),
              );
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.autorenew),
        onPressed: refresh,
      ),
    );
  }
}
