import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Providers/OverallState.dart';
//import 'package:carousel_slider/carousel_slider.dart';
//import 'package:flutter_bounce/flutter_bounce.dart';

import '../LDTheme.dart';

class Options extends StatefulWidget {
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
    _darkMode = prefs.brightness;
    _upperLimit = prefs.upperLimit.toDouble();
    _lowerLimit = prefs.lowerLimit.toDouble();
    _revisionStyle = prefs.revision;
  }

  void updatePreferences(){
    setState(() {
      Provider.of<OverallState>(context, listen: false).setOptions(
        _darkMode,
        _lowerLimit.round().toInt(),
        _upperLimit.round().toInt(),
        _revisionStyle,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            SwitchListTile(
              title: Text("Dark mode"),
              subtitle: Text("Toggle between light and dark mode"),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                  Provider.of<OverallState>(context, listen: false).changeBrightness();
                  updatePreferences();
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
                              padding: const EdgeInsets.all(8.0),
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
                      updatePreferences();
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
                     return StatefulBuilder(
                       builder: (context, state) => SimpleDialog(
                         children: [
                           Column(
                            children: [
                              RadioListTile<String>(
                                title: Text('Standard'),
                                value: "standard",
                                groupValue: _revisionStyle,
                                onChanged: (String value){
                                  setState(() {
                                    _revisionStyle = value;
                                    updatePreferences();
                                  });
                                },
                              ),
                              RadioListTile<String>(
                                title: Text('Input-based'),
                                value: "input",
                                groupValue: _revisionStyle,
                                onChanged: (String value){
                                  setState(() {
                                    _revisionStyle = value;
                                    updatePreferences();
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
