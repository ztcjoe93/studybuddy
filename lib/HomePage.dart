import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Image.asset(
                'assets/logo.png',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              Text(
                "StudyBuddy",
                style: TextStyle(
                  fontFamily: 'Langar',
                  fontSize: 30.0,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
