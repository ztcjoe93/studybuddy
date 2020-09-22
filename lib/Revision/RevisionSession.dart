import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_cards/Providers/ResultsState.dart';
import 'package:provider/provider.dart';

import '../Objects/objects.dart';

class RevisionSession extends StatefulWidget {
  @required Deck deck;

  RevisionSession(this.deck);

  @override
  _RevisionSessionState createState() => _RevisionSessionState();
}

class _RevisionSessionState extends State<RevisionSession> {
  List<FlashCard> cards = [];
  List<CardResult> cardResults = [];

  int _index = 0;
  bool _revealed = false;

  // for debugging purposes
  var ran = Random();
  List<Result> debugResults = [];

  @override
  void initState() {
    super.initState();

    // for debugging purposes
    for (int j=1; j < ran.nextInt(120)+50; j++)
    debugResults.add(
        Result(
            DateTime(
              2020,
              ran.nextInt(12)+1,
              ran.nextInt(25)+1,
            ).toIso8601String(),
            "test",
            "knn",
            [
              for(int i = 1; i < ran.nextInt(12)+2; i++)
                CardResult(
                  FlashCard("front", "back"),
                  ran.nextBool(),
                ),
            ]
        )
    );

    print("debugResults.length = ${debugResults.length}");
    // shuffle cards for deck
    cards = widget.deck.cards;
    cards.shuffle();
  }

  Widget session(List<FlashCard> cards, int index, List<CardResult> cardResults,
      Deck deck){
    if (index == cards.length){
      int score = 0;
      for (var cr in cardResults){
        score += cr.score ? 1 : 0;
      }
      Result finalResult = Result(
        DateTime.now().toIso8601String(),
        deck.name,
        deck.tag,
        cardResults
      );
      return Column(
        children: [
          Text(
            "You have finished the revision session!",
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            "Score: $score / ${cardResults.length}",
            style: Theme.of(context).textTheme.headline4,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              child: Text("Return to Revision list"),
              onPressed: (){
                Provider.of<ResultsState>(context, listen: false).add(finalResult);
                Navigator.of(context).pop();
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              child: Text("Debug for LineChart"),
              onPressed: (){
                for (var i in debugResults){
                  Provider.of<ResultsState>(context, listen: false).add(i);
                }
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      );
    } else {
      return Column(
        children: [
          Text(
            "Card ${_index + 1}/${cards.length}",
            style: Theme.of(context).textTheme.headline4,
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Center(child: Text(cards[_index].front)),
                ),
                FlatButton(
                  onPressed: (){
                    setState(() {
                      _revealed = true;
                    });
                  },
                  child: Text("Reveal"),
                ),
              ],
            ),
          ),
          if (_revealed)
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Center(child: Text(cards[_index].back)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: Colors.lightGreenAccent,
                        icon: Icon(Icons.check),
                        onPressed: (){
                          cardResults.add(CardResult(
                            cards[_index],
                            true,
                          ));
                          setState(() {
                            _revealed = false;
                            _index += 1;
                          });
                        },
                      ),
                      IconButton(
                        color: Colors.redAccent,
                        icon: Icon(Icons.close),
                        onPressed: (){
                          cardResults.add(CardResult(
                            cards[_index],
                            false,
                          ));
                          setState(() {
                            _revealed = false;
                            _index += 1;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          RaisedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Cancel revision")
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // prevent back button when starting revision session
    // https://api.flutter.dev/flutter/widgets/WillPopScope-class.html
    // https://stackoverflow.com/questions/45916658/how-to-deactivate-or-override-the-android-back-button-in-flutter
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: session(cards, _index, cardResults, widget.deck),
          ),
        ),
      ),
    );
  }
}
