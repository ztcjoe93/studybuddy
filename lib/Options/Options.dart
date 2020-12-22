import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bounce/flutter_bounce.dart';

import '../LDTheme.dart';

class Options extends StatefulWidget {
  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  bool _darkMode;
  double _upperLimit, _lowerLimit;
  int _page = 0;

  @override
  void dispose(){
    super.dispose();
  }

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            CarouselSlider(
              items: [
                Bounce(
                  duration: Duration(milliseconds: 50),
                  onPressed: (){
                    setState(() {
                      Provider.of<OverallState>(context, listen: false).changeBrightness();
                      _darkMode = !_darkMode;
                    });
                  },
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                            _darkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.6),
                            BlendMode.dstATop,
                          ),
                          image: AssetImage(
                            _darkMode
                              ? "assets/night.jpg"
                              : "assets/day.png",
                          ),
                          fit: BoxFit.cover,
                        )
                      ),
                      height: 400,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "DARK MODE",
                                style: TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text("Tap here to toggle!"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Bounce(
                  duration: Duration(milliseconds: 50),
                  onPressed: (){
                    // https://stackoverflow.com/questions/51271061/flutter-why-slider-doesnt-update-in-alertdialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        // https://api.flutter.dev/flutter/widgets/StatefulBuilder-class.html
                        return StatefulBuilder(
                          builder: (context, state) => SimpleDialog(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(children: [
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
                                                values: RangeValues(_lowerLimit, _upperLimit),
                                                min: 0,
                                                max: 100,
                                                onChanged: (RangeValues values){
                                                  if(values.start <= _upperLimit &&
                                                      values.end >= _lowerLimit){
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
                                                onChanged: (newValue){
                                                  if (newValue < _upperLimit){
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
                      }
                    );
                  },
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            colorFilter: ColorFilter.mode(
                              _darkMode
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.6),
                              BlendMode.dstATop,
                            ),
                            image: AssetImage("assets/performance.jpg"),
                            fit: BoxFit.cover,
                          )
                      ),
                      height: 400,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "PERFORMANCE SETTINGS",
                                style: TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text("Tap here to toggle!"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              options: CarouselOptions(
                height: 400,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason){
                  setState(() {
                    _page = index;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i=0; i < 2; i++)
                  Container(
                    width: 6.0,
                    height: 6.0,
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).brightness == Brightness.light
                        ? _page == i ? Colors.blueGrey[100] : Colors.grey
                        : _page == i ? Colors.white : Colors.grey
                    ),
                  )
              ]
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
      ],
    );
  }
}

