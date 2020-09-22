import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memory_cards/Providers/OverallState.dart';
import 'package:memory_cards/Providers/ResultsState.dart';
import 'package:memory_cards/Objects/objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Deck/DeckManagement.dart';
import 'LDTheme.dart';
import 'Revision/Revision.dart';
import 'Stats/Stats.dart';
import 'Providers/DecksState.dart';
import 'Options/Options.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DecksState(),
        ),
        ChangeNotifierProvider(
          create: (context) => ResultsState(),
        ),
        ChangeNotifierProvider(
          create: (context) => OverallState(),
        ),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _ready = false;
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
    Stats(),
    Options(),
  ];

  initializeAll() async{
    final prefs = await SharedPreferences.getInstance();
    final _darkMode = prefs.getBool('darkMode') ?? false;
    final _lowerLimit = prefs.getInt('lowerLimit') ?? 50;
    final _upperLimit = prefs.getInt('upperLimit') ?? 75;

    Provider.of<OverallState>(context, listen: false)
        .setOptions(_darkMode, _lowerLimit, _upperLimit);

    final directory = await getApplicationDocumentsDirectory();
    // create `decks` directory if not found
    if (Directory('${directory.path}/decks').existsSync() == false) {
      Directory('${directory.path}/decks').create(recursive: true);
    }
    // create `results` directory if not found
    if (Directory('${directory.path}/results').existsSync() == false) {
      Directory('${directory.path}/results').create(recursive: true);
    }

    print("Checking /decks/...");
    Directory('${directory.path}/decks')
        .list(recursive: true)
        .listen((e){
          Provider.of<DecksState>(context, listen: false).loadFromFile(
            Deck.fromJson(jsonDecode(File(e.path).readAsStringSync()))
          );
    });

    print("Checking /results/...");
    Directory('${directory.path}/results')
        .list(recursive: true)
        .listen((e){
          for (var result in jsonDecode(File(e.path).readAsStringSync())){
            Provider.of<ResultsState>(context, listen: false).loadFromFile(
              Result.fromJson(result)
            );
          }
          /*
      Provider.of<ResultsState>(context, listen: false).loadFromFile(
          Result.fromJson(jsonDecode(File(e.path).readAsStringSync()))
      );
           */
    });

    setState(() {
      // set state for darkmode to prevent flicker
      _ready = true;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeAll();
    _selectedIdx = 3; //debugging purposes
  }

  @override
  Widget build(BuildContext context) {
    return _ready
      ? MaterialApp(
          debugShowCheckedModeBanner: false,
          //showPerformanceOverlay: true,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: Provider.of<OverallState>(context, listen: true).brightness
              ? ThemeMode.dark : ThemeMode.light,
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
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              onTap: (_) => setState(() => _selectedIdx = _),
            ),
          ),
        )
      : Column(
          children: [
            Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 100,
              ),
            )
          ],
        );
  }
}