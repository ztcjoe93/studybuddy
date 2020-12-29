import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Options/Changelog.dart';
import 'package:studybuddy/Options/PushNotifications.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Utilities.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../LDTheme.dart';
import 'Licenses.dart';

class Options extends StatefulWidget {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Options(this.flutterLocalNotificationsPlugin);

  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  bool _darkMode;
  double _upperLimit, _lowerLimit;
  String _revisionStyle;
  int _page = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final prefs = Provider.of<OverallState>(context, listen: false);
    _darkMode = prefs.darkMode;
    _upperLimit = prefs.upperLimit.toDouble();
    _lowerLimit = prefs.lowerLimit.toDouble();
    _revisionStyle = prefs.revisionStyle;
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your channel id', 'your channel name', 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
    await widget.flutterLocalNotificationsPlugin.show(
        0,
        'Reminder for revision',
        'Let\'s start our revision today!',
        platformChannelSpecifics,
        payload: 'test');
  }

  Future<void> _zonedScheduleNotification() async {
    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder for revision',
        'Let\'s start our revision today!',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }


  void updatePreferences(){
    setState(() {
      Provider.of<OverallState>(context, listen: false).setOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            SizedBox(height: mqsHeight(context, 0.025)),
            SwitchListTile(
              title: Text("Dark mode"),
              subtitle: Text("Toggle between light and dark mode"),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                  var prov = Provider.of<OverallState>(context, listen: false);
                  prov.changeBrightness();
                  prov.setOptions();
                });
              },
            ),
            Divider(),
            ListTile(
              title: Text("Performance threshold"),
              subtitle: Text("Set performance indicators here"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // https://api.flutter.dev/flutter/widgets/StatefulBuilder-class.html
                      return StatefulBuilder(
                        builder: (context, state) => SimpleDialog(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                       Text("${_upperLimit.round().toString()}"),
                                      Expanded(
                                        child: SliderTheme(
                                          data: greatSlider,
                                          child: Slider(
                                            value: _upperLimit,
                                            min: 0,
                                            max: 100,
                                            label: _upperLimit.round().toString(),
                                            onChanged: (newValue) {
                                              // prevent slider from sliding if <= minvalue
                                              if (newValue > _lowerLimit) {
                                                state(() {
                                                  _upperLimit = newValue;
                                                });
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("${_lowerLimit.round().toString()}"),
                                      Expanded(
                                        child: SliderTheme(
                                          data: goodSlider,
                                          child: RangeSlider(
                                            values: RangeValues(
                                                _lowerLimit, _upperLimit),
                                            min: 0,
                                            max: 100,
                                            onChanged: (RangeValues values) {
                                              if (values.start <= _upperLimit &&
                                                  values.end >= _lowerLimit) {
                                                state(() {
                                                  _lowerLimit = values.start;
                                                  _upperLimit = values.end;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("${_lowerLimit.round().toString()}"),
                                      Expanded(
                                        child: SliderTheme(
                                          data: poorSlider,
                                          child: Slider(
                                            value: _lowerLimit,
                                            min: 0,
                                            max: 100,
                                            label: _lowerLimit.round().toString(),
                                            onChanged: (newValue) {
                                              if (newValue < _upperLimit) {
                                                state(() {
                                                  _lowerLimit = newValue;
                                                });
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }).then((_) {
                      var prov = Provider.of<OverallState>(context, listen:false);
                      prov.lowerLimit = _lowerLimit.round().toInt();
                      prov.upperLimit = _upperLimit.round().toInt();
                      prov.setOptions();
                });
              },
            ),
            Divider(),
            ListTile(
             title: Text('Revision mode'),
             subtitle: Text('Select preferred revision style'),
              onTap: (){
                 showDialog(
                   context: context,
                   builder: (BuildContext context) {
                     var prov = Provider.of<OverallState>(context, listen:true);
                     return StatefulBuilder(
                       builder: (context, state) => SimpleDialog(
                         children: [
                           Column(
                            children: [
                              RadioListTile<String>(
                                title: Text('Standard'),
                                value: "standard",
                                groupValue: prov.revisionStyle,
                                onChanged: (String value){
                                  setState(() {
                                    prov.revisionStyle = value;
                                    prov.setOptions();
                                  });
                                },
                              ),
                              RadioListTile<String>(
                                title: Text('Input-based'),
                                value: "input",
                                groupValue: prov.revisionStyle,
                                onChanged: (String value){
                                  setState(() {
                                    prov.revisionStyle = value;
                                    prov.setOptions();
                                  });
                                },
                              ),
                            ],
                           )
                         ],
                       ),
                     );
                   }
                 );
              },
            ),
            Divider(),
            ListTile(
              title: Text('Push notifications'),
              subtitle: Text('Set a reminder for a revision session'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return StatefulBuilder(
                      builder: (context, state) => PushNotification(),
                    );
                  }
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text("Changelog"),
              subtitle: Text("Check the latest changes to the application here"),
              onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => Changelog(),
                      transitionsBuilder: (ctx, anim, sAnim, child) {
                        var begin = Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(position: anim.drive(tween), child: child);
                      }
                  )
              ),
            ),
            Divider(),
            ListTile(
              title: Text("Licenses"),
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                    pageBuilder: (_, __, ___) => Licenses(),
                    transitionsBuilder: (ctx, anim, sAnim, child) {
                      var begin = Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(position: anim.drive(tween), child: child);
                    }
                )
              ),
            ),
            /*
            Divider(),
            ListTile(
              title: Text('debug'),
              onTap: (){
                var prov = Provider.of<OverallState>(context, listen: false);
                print(prov.darkMode);
                print(prov.lowerLimit);
                print(prov.upperLimit);
                print(prov.revisionStyle);
                print("mon: ${prov.monday}");
                print("tues: ${prov.tuesday}");
                print("wed: ${prov.wednesday}");
                print("thu: ${prov.thursday}");
                print("fri: ${prov.friday}");
                print("sat: ${prov.saturday}");
                print("sun: ${prov.sunday}");
                print(prov.scheduledHour);
                print(prov.scheduledMin);
              },
            ),
             */
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(26.0),
          child: Center(
              child: Text(
                  "StudyBuddy version 0.9.0",
                style: TextStyle(
                  color: Colors.blueGrey,
                )
              )
          ),
        ),
      ],
    );
  }
}
