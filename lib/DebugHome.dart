import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Database.dart';
import 'package:studybuddy/Providers/DecksState.dart';
import 'package:studybuddy/Providers/ResultsState.dart';
import 'package:faker/faker.dart';

import 'Objects/objects.dart';

class DebugHome extends StatefulWidget {
  @override
  _DebugHomeState createState() => _DebugHomeState();
}

class _DebugHomeState extends State<DebugHome> {
  int _selection;

  Random rand = Random();
  Faker faker = Faker();

  Map<int, dynamic> dataProvider = {
    0: DBProvider.db.decks,
    1: DBProvider.db.cards,
    2: DBProvider.db.results,
    3: DBProvider.db.cardresults,
  };

  @override
  void initState() {
    super.initState();
    _selection = 0;
  }

  deleteDummyData() async {
    DBProvider.db.delete('deck', 'deck_id >= ?', [1]);
    DBProvider.db.delete('card', 'card_id >= ?', [1]);
    DBProvider.db.delete('result', 'result_id >= ?', [1]);
    DBProvider.db.delete('cardresult', 'cr_id >= ?', [1]);

    print("Dummy data deletion done.");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async => await deleteDummyData(),
              icon: Icon(Icons.accessible),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RaisedButton(
              onPressed: (){
                setState(() {
                  _selection = 0;
                });
              },
              child: Text("Decks"),
            ),
            RaisedButton(
              onPressed: (){
                setState(() {
                  _selection = 1;
                });
              },
              child: Text("Cards"),
            ),
            RaisedButton(
              onPressed: (){
                setState(() {
                  _selection = 2;
                });
              },
              child: Text("Results"),
            ),
            RaisedButton(
              onPressed: (){
                setState(() {
                  _selection = 3;
                });
              },
              child: Text("CardResults"),
            ),
          ],
        ),
        FutureBuilder(
          future: dataProvider[_selection],
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.hasData){
              return Flexible(
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.05,
                        maxHeight: MediaQuery.of(context).size.height * 0.05,
                      ),
                      child: Row(
                        children: [
                          for(var i in snapshot.data[index].keys)
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 32.0),
                                child: Container(
                                  child: Text(
                                    "${snapshot.data[index][i]}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ],
    );
  }
}
