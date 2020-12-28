import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/main.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PushNotification extends StatefulWidget {
  @override
  _PushNotificationState createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {
  String timing;

  tz.TZDateTime _nextTimeInstance(selectedHour, selectedMinute, chosenDayOfWeek){
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      selectedHour,
      selectedMinute,
    );

    while(scheduledDate.weekday != chosenDayOfWeek){
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if(scheduledDate.isBefore(now)){
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    print(scheduledDate.toString());

    return scheduledDate;
  }

  Future<void> _zonedScheduleNotification() async {
    var prov = Provider.of<OverallState>(context, listen: false);

    List<bool> weekdays = [
      prov.monday,
      prov.tuesday,
      prov.wednesday,
      prov.thursday,
      prov.friday,
      prov.saturday,
      prov.sunday,
    ];

    int cur = 0;
    for(final i in weekdays){
      if (i){
        var chosenDay;
        switch(cur){
          case 0:
            chosenDay = DateTime.monday;
            break;
          case 1:
            chosenDay = DateTime.tuesday;
            break;
          case 2:
            chosenDay = DateTime.wednesday;
            break;
          case 3:
            chosenDay = DateTime.thursday;
            break;
          case 4:
            chosenDay = DateTime.friday;
            break;
          case 5:
            chosenDay = DateTime.saturday;
            break;
          case 6:
            chosenDay = DateTime.sunday;
            break;
        }
        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Reminder for revision',
          'Let\'s start our revision today!',
          _nextTimeInstance(prov.scheduledHour, prov.scheduledMin, chosenDay),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                'sb_sr001',
                'Revision scheduler',
                'Scheduled reminder for revision session.',
              )
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      cur++;
    }
  }

  Widget timingToCards(int hour, int min){
    Row row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [],
    );

    for (final i in [hour, min]){
      var formatted;
      if(i < 10){
        formatted = "0$i";
      } else {
        formatted = i;
      }
      for(final j in formatted.toString().characters) {
        row.children.add(ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 80,
            minWidth: 50,
          ),
          child: Card(
            child: Center(
              child: Text(
                j,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ));
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: row,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //https://stackoverflow.com/questions/53913192/flutter-change-the-width-of-an-alertdialog
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      children: [
        Builder(
          builder: (context){
            var prov = Provider.of<OverallState>(context, listen: true);
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                children: [
                  Text(
                    "Revision Scheduler",
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "Set a reminder on a specific day and time for a revision below."
                  ),
                  SizedBox(height: 28.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Select the day/s of the week: "),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Checkbox(
                                value: prov.monday,
                                tristate: false,
                                onChanged: (val){
                                  setState(() {
                                    prov.monday = val;
                                  });
                                },
                              ),
                              Text("Mon"),
                            ],
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: prov.tuesday,
                                tristate: false,
                                onChanged: (val){
                                  setState(() {
                                    prov.tuesday = val;
                                  });
                                },
                              ),
                              Text("Tue"),
                            ],
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: prov.wednesday,
                                tristate: false,
                                onChanged: (val){
                                  setState(() {
                                    prov.wednesday = val;
                                  });
                                },
                              ),
                              Text("Wed"),
                            ],
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: prov.thursday,
                                tristate: false,
                                onChanged: (val){
                                  setState(() {
                                    prov.thursday = val;
                                  });
                                },
                              ),
                              Text("Thu"),
                            ],
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: prov.friday,
                                tristate: false,
                                onChanged: (val){
                                  setState(() {
                                    prov.friday = val;
                                  });
                                },
                              ),
                              Text("Fri"),
                            ],
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: prov.saturday,
                                tristate: false,
                                onChanged: (val){
                                  setState(() {
                                    prov.saturday = val;
                                  });
                                },
                              ),
                              Text("Sat"),
                            ],
                          ),
                          Column(
                            children: [
                              Checkbox(
                                value: prov.sunday,
                                tristate: false,
                                onChanged: (val){
                                  setState(() {
                                    prov.sunday = val;
                                  });
                                },
                              ),
                              Text("Sun"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 28.0),
                  Column(
                    children: [
                      Text("Select a time to set the reminder at:"),
                      IconButton(
                          icon: Icon(
                            Icons.timer_rounded,
                          ),
                          iconSize: 50.0,
                          onPressed: () async {
                            var time = await showTimePicker(context: context,
                                initialTime: TimeOfDay(
                                    hour: prov.scheduledHour,
                                    minute: prov.scheduledMin,
                                ),
                                builder: (BuildContext context, Widget child){
                                  return MediaQuery(
                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                    child: child,
                                  );
                                }
                            );
                            if (time != null){
                              setState(() {
                                prov.scheduledHour = time.hour;
                                prov.scheduledMin = time.minute;
                              });
                            }
                          }),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  timingToCards(prov.scheduledHour, prov.scheduledMin),
                  SizedBox(height: 20.0),
                  RaisedButton(
                    onPressed: (){
                      _zonedScheduleNotification();
                      Navigator.of(context).pop();
                    },
                    child: Text("Save"),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
