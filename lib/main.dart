import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Providers/ResultsState.dart';

import 'Database.dart';
import 'DebugHome.dart';
import 'Deck/DeckManagement.dart';
import 'LDTheme.dart';
import 'Options/Options.dart';
import 'Providers/DecksState.dart';
import 'Revision/Revision.dart';
import 'Stats/Stats.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DecksState()),
        ChangeNotifierProvider(create: (context) => ResultsState()),
        ChangeNotifierProvider(create: (context) => OverallState()),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  bool _ready = false;
  int _selectedIdx = 0;

  List<String> categories = ["Home", "Deck Management", "Revision", "Stats", "Options"];
  List<Widget> _widgetOptions = [];

  initializeAll() async{
    final prefs = await SharedPreferences.getInstance();
    final _darkMode = prefs.getBool('darkMode') ?? false;
    final _lowerLimit = prefs.getInt('lowerLimit') ?? 50;
    final _upperLimit = prefs.getInt('upperLimit') ?? 75;

    Provider.of<OverallState>(context, listen: false).setOptions(_darkMode, _lowerLimit, _upperLimit);

    await DBProvider.db.initializeDatabase();
    Provider.of<DecksState>(context, listen:false).loadFromDatabase();
    Provider.of<ResultsState>(context, listen:false).loadFromDatabase();

    // set state for darkMode to prevent flicker if there's a change
    setState(() {
      _ready = true;
    });

    print("Completed initialization.");
  }

  @override
  void initState() {
    super.initState();

    _widgetOptions = [
      DebugHome(),
      DeckManagement(),
      Revision(),
      Stats(),
      Options(),
    ];

    initializeAll();

    _selectedIdx = 0; //debugging purposes
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
            body: //_widgetOptions[_selectedIdx],
            Center(child: AnimatedSwitcher(
              duration: Duration(milliseconds: 125),
              child: _widgetOptions[_selectedIdx],
            )),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text("Home"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.layers),
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
              selectedIconTheme: IconThemeData(size: 30.0),
              selectedItemColor: Colors.white,
              onTap: (ind) => setState((){
                _selectedIdx = ind;
                }
              ),
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