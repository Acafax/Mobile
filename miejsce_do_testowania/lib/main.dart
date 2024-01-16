import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> loadedList = [];

  @override
  void initState() {
    super.initState();
    loadListFromSharedPreferences();
  }

  void loadListFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("klucz");

    if (jsonString != null) {
      setState(() {
        loadedList = json.decode(jsonString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zawartość SharedPreferences'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Zawartość zapisanej listy:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              loadedList.toString(),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
