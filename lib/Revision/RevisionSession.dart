import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Database.dart';
import 'package:studybuddy/Providers/ResultsState.dart';
import 'package:studybuddy/Widgets/LoadingBlocks.dart';

import '../Objects/objects.dart';

class RevisionSession extends StatefulWidget {
  @required Deck deck;
  @required String revisionStyle;

  RevisionSession(this.deck, this.revisionStyle);

  @override
  _RevisionSessionState createState() => _RevisionSessionState();
}

class _RevisionSessionState extends State<RevisionSession> with TickerProviderStateMixin {
  List<FlashCard> cards = [];
  List<CardResult> cardResults = [];
  AnimationController _controller;
  TextEditingController inputField = TextEditingController();
  Color fieldColor;

  String display = "";
  String topDisplay = "";

  int _index = 0;
  bool _flipped = false;
  bool _revealed = false;


  recordResult(bool correct) async {
    cardResults.add(CardResult(
      await DBProvider.db.getNewRow('result'),
      cards[_index],
      correct,
    ));

    setState(() {
      _flipped = false;
      _revealed = false;
      _index += 1;
      if(_index < cards.length){
        topDisplay = "FRONT";
        display = cards[_index].front;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    inputField.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      value: 1,
    );

    // shuffle cards for deck
    cards = widget.deck.cards;
    cards.shuffle();

    display = cards[_index].front;
    topDisplay = "FRONT";
  }

  Future<Widget> session(List<FlashCard> cards, int index, List<CardResult> cardResults,
      Deck deck) async {
    if (index == cards.length){
      int score = 0;

      for (var cr in cardResults){
        score += cr.score ? 1 : 0;
      }

      Result finalResult = Result(
        await DBProvider.db.getNewRow('result'),
        DateTime.now().toIso8601String(),
        deck.id,
        cardResults
      );

      return LoadingBlocks(rawScore: [score, cardResults.length], finalResult: finalResult);
    } else {
      if(widget.revisionStyle == "standard"){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 8,
              child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child){
                    return Transform(
                      transform: Matrix4.rotationY((1 - _controller.value) * pi / 2),
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) async {
                          if (details.primaryVelocity != 0){
                            if (!_flipped) {
                              await _controller.reverse();
                              setState(() {
                                display = cards[_index].back;
                                topDisplay = "BACK";
                              });
                              await _controller.forward();
                            } else {
                              await _controller.reverse();
                              setState(() {
                                display = cards[_index].front;
                                topDisplay = "FRONT";
                              });
                              await _controller.forward();
                            }
                            setState(() {
                              _flipped = !_flipped;
                              _revealed = true;
                            });
                          }
                        },
                        child: Center(
                          child: Card(
                            child: Container(
                              height: 400,
                              width: 300,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      topDisplay,
                                      style: Theme.of(context).textTheme.headline4,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        display,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline6,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                    Text("Swipe left or right to flip to the other side"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for(int i=0; i < cards.length; i++)
                    Container(
                      width: _index == i ? 10.0 : 6.0,
                      height: _index == i ? 10.0 : 6.0,
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _index == i ? Colors.blueGrey: Colors.grey,
                      ),
                    )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: _revealed
                  ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ClipOval(
                        child: Material(
                          color: Colors.lightGreenAccent,
                          child: InkWell(
                            splashColor: Colors.lightGreen[200],
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: MediaQuery.of(context).size.width * 0.15,
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () async => recordResult(true),
                          ),
                        ),
                      ),
                      ClipOval(
                        child: Material(
                          color: Colors.redAccent,
                          child: InkWell(
                            splashColor: Colors.redAccent[200],
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: MediaQuery.of(context).size.width * 0.15,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () async => recordResult(false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  : Container(),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel revision")
                ),
              ),
            ),
          ],
        );
      } else {
        // input-based revision
        fieldColor = Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade200 : Colors.grey.shade800;

        return Column(
          children: [
            Card(
              child: Container(
                height: 200,
                width: 400,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        topDisplay,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          display,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: inputField,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: fieldColor,
                hintText: "Enter your input here!",
              ),
              minLines: 2,
              maxLines: 2,
            ),
            RaisedButton(
              onPressed: () async {
                bool validity = inputField.text == cards[_index].back;
                /*
                fieldColor = validity
                    ? Colors.lightGreen.shade200 : Colors.redAccent.shade200;
                 */
                setState(() {
                  fieldColor = Colors.red;
                  Future.delayed(Duration(seconds: 1), (){
                    recordResult(validity);
                    inputField.clear();
                  });
                });
                // clear field for next card
              },
              child: Text("Next"),
            ),
            RaisedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Return"),
            ),
          ]
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // prevent back button when starting revision session
    // https://api.flutter.dev/flutter/widgets/WillPopScope-class.html
    // https://stackoverflow.com/questions/45916658/how-to-deactivate-or-override-the-android-back-button-in-flutter
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus.unfocus(),
      child: WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.05,
              ),
              child: FutureBuilder<Widget>(
                future: session(cards, _index, cardResults, widget.deck),
                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
                  if(snapshot.hasData){
                    return snapshot.data;
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}
