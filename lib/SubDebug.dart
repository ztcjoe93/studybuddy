import 'package:flutter/material.dart';
import 'dart:math';

class SubDebug extends StatefulWidget {
  @override
  _SubDebugState createState() => _SubDebugState();
}

class _SubDebugState extends State<SubDebug> with SingleTickerProviderStateMixin{
  int score;
  List<Widget> data;

  @override
  void initState() {
    super.initState();
    score = ((12/17)*100).round();
    data = scoreBlocks();
  }

  List<Widget> generateContainers(){
    List<Widget> listWidgets = [];
    for(int i = 0; i < 25; i++){
      print("debug: $score");
      if(score > 0) {
        listWidgets.add(
            Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
              ),
            )
        );
      } else {
        listWidgets.add(
            Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
            )
        );
      }
      setState(() {
        score = score - 1;
      });
    }
    return listWidgets;
  }

  List<Widget> scoreBlocks(){
    List<Widget> listWidgets = [];
    for(int i = 0; i < 4; i++){
      Widget row = Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: generateContainers()
        ),
      );
      listWidgets.add(row);
    }
    return listWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: data,
    );
  }
}
