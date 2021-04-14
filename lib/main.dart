import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';

import 'components/ListItem.dart';

import 'pages/AddFeed.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('savedFeeds');
  runApp(MyApp());
}

Future getData(String url) async {
  var res = await http.get(Uri.parse(url));

  if (res.statusCode == 200) {
    var channel = null;
    if (url.contains(".rss")) {
      channel = RssFeed.parse(res.body);
    } /*else if (url.contains(".rtf")) {
      channel = Rss1Feed.parse(res.body);
    }*/
    else if (url.contains(".xml")) {
      channel = AtomFeed.parse(res.body);
    } else {
      channel = null;
    }
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

  final String feedSource = "https://www.spiegel.de/schlagzeilen/index.rss";

  @override
  void initState() {
    super.initState();
    feedData = getData(feedSource);
  }

  @override
  void refresh() {
    super.setState(() {});
    feedData = getData(feedSource);
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
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 1),
        child: FutureBuilder(
          future: feedData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (feedSource.contains(".xml")) {
                return ListView(
                  children: <Widget>[
                    /*Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints:
                            BoxConstraints(minWidth: 100, maxWidth: 150),
                        padding: EdgeInsets.all(10),
                        child:
                            Image(image: NetworkImage(snapshot.data.logo.url)),
                      ),
                    ],
                  ),*/
                    for (var item in snapshot.data.items)
                      ListItem(
                          title: item.title.toString(),
                          description: item.content,
                          url: item.id)
                  ],
                );
              } else if (feedSource.contains(".rss")) {
                return ListView(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          constraints:
                              BoxConstraints(minWidth: 100, maxWidth: 150),
                          padding: EdgeInsets.all(10),
                          child: Image(
                            image: NetworkImage(snapshot.data.image.url),
                          ),
                        ),
                      ],
                    ),
                    for (var item in snapshot.data.items)
                      ListItem(
                          title: item.title.toString(),
                          description: item.description,
                          url: item.link)
                  ],
                );
              }
            } else if (snapshot.hasError) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Text("Something is gone wrong: \n ${snapshot.error}"),
              );
            }

            // By default, show a loading spinner.
            return Center(
              child: CircularProgressIndicator(),
            );
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
