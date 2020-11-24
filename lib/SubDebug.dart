import 'package:flutter/material.dart';

import 'FadeIn.dart';

class SubDebug extends StatefulWidget {
  @override
  _SubDebugState createState() => _SubDebugState();
}

class _SubDebugState extends State<SubDebug> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Test"),
      ],
    );
  }
}
