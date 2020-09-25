import 'package:flutter/material.dart';
import 'package:memory_cards/Providers/OverallState.dart';
import 'package:provider/provider.dart';

import '../LDTheme.dart';

class Options extends StatefulWidget {
  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  bool _darkMode;
  double _upperLimit, _lowerLimit;

  @override
  void initState() {
    super.initState();
    final prefs = Provider.of<OverallState>(context, listen: false);
    _darkMode = prefs.brightness;
    _upperLimit = prefs.upperLimit.toDouble();
    _lowerLimit = prefs.lowerLimit.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15),
      child: Container(
        color: Colors.red[200],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.brightness_6),
                    Text("Dark Mode"),
                  ],
                ),
                Switch(
                  value: _darkMode,
                  onChanged: (value){
                    setState(() {
                      Provider.of<OverallState>(context, listen: false).changeBrightness();
                      _darkMode = !_darkMode;
                    });
                  }
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Performance settings"),
                  ),
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
                            onChanged: (newValue){
                              // prevent slider from sliding if <= minvalue
                              if (newValue > _lowerLimit){
                                setState(() {
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
                            values: RangeValues(_lowerLimit, _upperLimit),
                            min: 0,
                            max: 100,
                            onChanged: (RangeValues values){
                              if(values.start <= _upperLimit &&
                              values.end >= _lowerLimit){
                                setState(() {
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
                            onChanged: (newValue){
                              if (newValue < _upperLimit){
                                setState(() {
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
                  RaisedButton(
                    onPressed: (){
                      Provider.of<OverallState>(context, listen: false).
                        setOptions(
                          _darkMode,
                          _lowerLimit.round().toInt(),
                          _upperLimit.round().toInt(),
                        );

                      Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                          SnackBar(
                            content: const Text("Preferences saved!"),
                            duration: Duration(seconds: 1),
                          ),
                      );
                    },
                    child: Text("Update preferences"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

