import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';

import 'components/ListItem.dart';

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
        primarySwatch: Colors.blue,
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
        title: Text(widget.title),
        leading: PopupMenuButton<MenuOption>(
          icon: Icon(Icons.menu),
          onSelected: (MenuOption option) {
            print(option.toString());
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<MenuOption>>[
              PopupMenuItem(child: Text("Add feed"), value: MenuOption.Add),
            ];
          },
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: feedData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(children: <Widget>[
                for (var item in snapshot.data.items)
                  ListItem(
                      title: item.title,
                      description: item.description,
                      url: item.link)
              ]);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
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

enum MenuOption { Add }
