import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Providers/ResultsState.dart';
import 'package:studybuddy/Widgets/SplashScreen.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'Database.dart';
import 'Deck/DeckManagement.dart';
import 'HomePage.dart';
import 'LDTheme.dart';
import 'Options/Options.dart';
import 'Providers/DecksState.dart';
import 'Revision/Revision.dart';
import 'Stats/Stats.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
  BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
  BehaviorSubject<String>();

const MethodChannel platform =
  MethodChannel('ztcjoe93.studybuddy');

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var p = await SharedPreferences.getInstance();
  var x = p.getBool('darkMode') ?? false;
  await _configureLocalTimeZone();

  final NotificationAppLaunchDetails notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
        selectNotificationSubject.add(payload);
      });
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

    Provider.of<OverallState>(context, listen: false).getValuesFromPreferences();
    Provider.of<OverallState>(context, listen: false).setOptions();

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
            ? Provider.of<OverallState>(context, listen: true).darkMode
              ? ThemeMode.dark : ThemeMode.light
            : widget.t
              ? ThemeMode.dark : ThemeMode.light,
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
              Options(flutterLocalNotificationsPlugin),
            ],
            index: _selectedIdx,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
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