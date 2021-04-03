import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class AddFeed extends StatefulWidget {
  @override
  _AddFeedState createState() => _AddFeedState();
}

class _AddFeedState extends State<AddFeed> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed Scout - Add Feed"),
      ),
      drawer: Drawer(
        child: ListView(
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
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Form(
              child: Column(
                key: _formKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter a name for your new feed',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a name for your feed';
                      }
                      return value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Enter the url of your new feed',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter the url of your feed';
                      }
                      return value;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState.validate()) {
                          print("validated");
                          _saveFeed();
                        }
                      },
                      child: Text('Safe feed'),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "Popular feeds",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Text(
                "This section is still in development progress. Here you will get some popular feeds to add in the future.")
            // TODO: Section with popular feeds so that less technical expirienced people can get some point to start.
          ],
        ),
      ),
    );
  }
}

_saveFeed() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'my_int_key';
  final value = 42;
  prefs.setInt(key, value);
  print('saved $value');
}
