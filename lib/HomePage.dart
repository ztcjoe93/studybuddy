import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Main Page",
            style: Theme.of(context).textTheme.headline2,
          ),
          Row(
            children: [
              Text(
                "Changelog",
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
          ),
          RaisedButton(
            onPressed: (){
            },
            child: Text(
              "Tutorial"
            ),
          ),
        ],
      ),
    );
  }
}
