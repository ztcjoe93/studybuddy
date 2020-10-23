import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Database.dart';
import 'package:studybuddy/Providers/DecksState.dart';
import 'package:studybuddy/Providers/ResultsState.dart';
import 'package:studybuddy/Utilities.dart';

import 'Objects/objects.dart';

class DebugHome extends StatefulWidget {
  @override
  _DebugHomeState createState() => _DebugHomeState();
}

class _DebugHomeState extends State<DebugHome> {
  int _selection;

  Random rand = Random();

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

  generateDummyData() async {
    int deckRow = await DBProvider.db.getNewRow('deck');
    int cardRow = await DBProvider.db.getNewRow('card');
    int resultRow = await DBProvider.db.getNewRow('result');
    int crRow = await DBProvider.db.getNewRow('cardresult');

    for(int i = 0; i < 100; i++){ // number of decks
      List<FlashCard> fcDebug = [];
      for(int j = 0; j < rand.nextInt(7)+5; j++){ // number of cards in a deck
        fcDebug.add(FlashCard(
          cardRow,
          ranStr(12),
          ranStr(12),
        ));
        cardRow++;
      }

      Deck generatedDeck = Deck(
        deckRow,
        ranStr(15),
        ranStr(7),
        fcDebug,
      );

      Provider.of<DecksState>(context, listen: false).addDeck(generatedDeck);


      for(int j = 0; j < 20; j++){ //number of results
        List<CardResult> crDebug = [];

        for(var fc in fcDebug){
          crDebug.add(CardResult(
            crRow,
            fc,
            rand.nextBool(),
          ));
          crRow++;
        }

        Provider.of<ResultsState>(context, listen: false).add(Result(
          resultRow,
          DateTime(
            2020,
            rand.nextInt(11)+1,
            rand.nextInt(27)+1,
            rand.nextInt(24),
            rand.nextInt(59),
            rand.nextInt(59),
          ).toIso8601String(),
          deckRow,
          crDebug,
        ));
        resultRow++;
      }
      deckRow++;

    }

    print("Dummy data generation done.");
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
              onPressed: () async => await generateDummyData(),
              icon: Icon(Icons.accessibility),
            ),
            IconButton(
              onPressed: () async => await deleteDummyData(),
              icon: Icon(Icons.accessible),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MaterialButton(
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for(var i in snapshot.data[index].keys)
                            Text("${snapshot.data[index][i]}"),
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
