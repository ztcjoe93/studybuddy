import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'Providers/DecksState.dart';

class Revision extends StatefulWidget {
  @override
  _RevisionState createState() => _RevisionState();
}

class _RevisionState extends State<Revision> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
          ),
        ),
        child: Consumer<DecksState>(
            builder: (context, decks, child) {
              return decks.revisionView;
            }
        ),
      );
  }
}
