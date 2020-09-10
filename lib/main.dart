import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memory_cards/objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'Deck/DeckManagement.dart';
import 'Revision.dart';
import 'Providers/DecksState.dart';

void main(){
  runApp(
    ChangeNotifierProvider(
      create: (context) => DecksState(),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIdx = 0;
  List<String> categories = [
    "Home", "Deck Management",
    "Revision", "Stats",
    "Options"
  ];

  static List<Widget> _widgetOptions = [
    Text('Home'),
    DeckManagement(),
    Revision(),
    Text('Stats'),
    Text('Options'),
  ];

  initializeDecks() async{
    final directory = await getApplicationDocumentsDirectory();
    // create `decks` directory if not found
    if (await Directory('${directory.path}/decks').exists() == false) {
      Directory('${directory.path}/decks').create(recursive: true);
    }

    print("Checking /decks/...");
    Directory('${directory.path}/decks')
        .list(recursive: true)
        .listen((e){
          print(e.path);
          Provider.of<DecksState>(context, listen: false).add(
            Deck.fromJson(jsonDecode(File(e.path).readAsStringSync()))
          );
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDecks();
    _selectedIdx = 1;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //showPerformanceOverlay: true,
      home: Scaffold(
        appBar: AppBar(
          title: Text(categories[_selectedIdx]),
        ),
        body: Center(child: _widgetOptions[_selectedIdx]),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text("Home"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.queue),
              title: Text("Deck"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              title: Text("Revision"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.equalizer),
              title: Text("Stats"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text("Options"),
            ),
          ],
          currentIndex: _selectedIdx,
          selectedItemColor: Colors.blueAccent,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.blue[900],
          onTap: (_) => setState(() => _selectedIdx = _),
        ),
      ),
    );
  }
}