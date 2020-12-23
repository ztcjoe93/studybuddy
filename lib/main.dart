import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Providers/ResultsState.dart';
import 'package:studybuddy/Widgets/SplashScreen.dart';

import 'Database.dart';
import 'Deck/DeckManagement.dart';
import 'HomePage.dart';
import 'LDTheme.dart';
import 'Options/Options.dart';
import 'Providers/DecksState.dart';
import 'Revision/Revision.dart';
import 'Stats/Stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var p = await SharedPreferences.getInstance();
  var x = p.getBool('darkMode');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DecksState()),
        ChangeNotifierProvider(create: (context) => ResultsState()),
        ChangeNotifierProvider(create: (context) => OverallState()),
      ],
      child: MainApp(t: x)
    ),
  );
}

class MainApp extends StatefulWidget {
  var t;

  MainApp({Key key, this.t});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  bool _ready = false;
  int _selectedIdx = 0;

  List<String> categories = [
    //"HOME",
    "DECK MANAGEMENT", "REVISION",
    "STATISTICS", "OPTIONS",
  ];

  initializeAll() async{
    final prefs = await SharedPreferences.getInstance();
    final _darkMode = prefs.getBool('darkMode') ?? false;
    final _lowerLimit = prefs.getInt('lowerLimit') ?? 50;
    final _upperLimit = prefs.getInt('upperLimit') ?? 75;
    final _revisionStyle = prefs.getString('revisionStyle') ?? 'flip';

    Provider.of<OverallState>(context, listen: false).setOptions(_darkMode, _lowerLimit, _upperLimit, _revisionStyle);

    await DBProvider.db.initializeDatabase();
    Provider.of<DecksState>(context, listen:false).loadFromDatabase();
    Provider.of<ResultsState>(context, listen:false).loadFromDatabase();

    // set state for darkMode to prevent flicker if there's a change
    print("Completed initialization.");
    Future.delayed(Duration(seconds: 2), (){
      setState(() {
        _ready = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initializeAll();
    _selectedIdx = 0; //debugging purposes
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        //showPerformanceOverlay: true,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _ready
            ? Provider.of<OverallState>(context, listen: false).brightness ? ThemeMode.dark : ThemeMode.light
            : widget.t ? ThemeMode.dark : ThemeMode.light,
        home: _ready
            ? Scaffold(
          appBar: AppBar(
            title: Text(
              categories[_selectedIdx],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: IndexedStack(
            children: [
              //HomePage(),
              DeckManagement(),
              Revision(),
              Stats(state: Provider.of<OverallState>(context, listen: true).deckChange),
              Options(),
            ],
            index: _selectedIdx,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              /*
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
               */
              BottomNavigationBarItem(
                icon: Icon(Icons.layers),
                label: "Decks",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: "Revision",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.equalizer),
                label: "Statistics",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Options",
              ),
            ],
            currentIndex: _selectedIdx,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: IconThemeData(size: 30.0),
            onTap: (ind) => setState((){
              _selectedIdx = ind;
            }
            ),
          ),
        )
            : Scaffold(
          body: Center(
            child: SplashScreen(),
          ),
        ),
      );
  }
}