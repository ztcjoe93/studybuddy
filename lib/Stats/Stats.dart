import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Charts/CardPerformance.dart';
import 'package:studybuddy/Charts/DeckPerformance.dart';
import 'package:studybuddy/Providers/DecksState.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Providers/ResultsState.dart';
import 'package:studybuddy/Utilities.dart';

class Stats extends StatefulWidget {
  bool state;

  Stats({@required this.state});

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  int _selectedDeck;
  PageController pageController = PageController(
    initialPage: 1,
  );

  @override
  void didUpdateWidget(covariant Stats oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state){
      // check for deck deletion changes
      pageController.jumpToPage(1);
      _selectedDeck = null;
      Provider.of<OverallState>(context, listen: false).deckHasBeenChanged(true);
      widget.state = Provider.of<OverallState>(context, listen: false).deckChange;
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
          vertical: mqsHeight(context, 0.025),
          horizontal: mqsWidth(context, 0.05),
        ),
        child: Consumer<ResultsState>(
          builder: (context, res, child) =>
              PageView(
                controller: pageController,
                physics: NeverScrollableScrollPhysics(),
                pageSnapping: true,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Card performance",
                        style: TextStyle(
                          fontSize: mqsWidth(context, 0.05),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: mqsHeight(context, 0.25),
                          maxHeight: mqsHeight(context, 0.25),
                        ),
                        child: CardPerformance(
                          res.results.where((d) => d.deckId == _selectedDeck).toList(),
                          "chart",
                        ),
                      ),
                      Expanded(
                        child: CardPerformance(
                          res.results.where((d) => d.deckId == _selectedDeck).toList(),
                          "list",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: FlatButton(
                                onPressed: () =>
                                    pageController.animateToPage(2,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn,
                                    ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Icon(Icons.show_chart),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "Deck performances",
                                        style: TextStyle(
                                          fontSize: mqsWidth(context, 0.035),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: () =>
                                    pageController.animateToPage(1,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn,
                                    ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Icon(Icons.layers),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "Deck selection",
                                        style: TextStyle(
                                          fontSize: mqsWidth(context, 0.035),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Consumer<ResultsState>(
                          builder: (context, provider, child) {
                            String _selection = _selectedDeck == null
                                ? "No deck"
                                : Provider
                                .of<DecksState>(context, listen: true)
                                .getDeckFromId(_selectedDeck)
                                .name;
                            return Center(
                              child: FittedBox(
                                child: Text(
                                  "$_selection is selected",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: mqsWidth(context, 0.07),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          //color: Colors.white.withOpacity(0.8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0x7Acfd8dc),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0x7Acfd8dc),
                          ),
                          child: Consumer<ResultsState>(
                            builder: (context, provider, child) {
                              if (provider.results.length == 0) {
                                return Center(child: Text("Empty"));
                              } else {
                                List resultSet = LinkedHashSet<int>.from(
                                    provider.results.map((r) => r.deckId)).toList();
                                return ListView.builder(
                                  itemCount: resultSet.length,
                                  itemBuilder: (BuildContext context, int index) =>
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: mqsHeight(context, 0.01),
                                          left: mqsWidth(context, 0.01),
                                          right: mqsWidth(context, 0.01),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: resultSet[index] == _selectedDeck
                                                ? Colors.blueGrey[300]
                                                : Colors.transparent,
                                          ),
                                          child: ListTile(
                                            dense: true,
                                            onTap: () {
                                              setState(() {
                                                _selectedDeck =
                                                _selectedDeck == resultSet[index]
                                                    ? null : resultSet[index];
                                              });
                                            },
                                            title: Text(
                                              Provider
                                                  .of<DecksState>(
                                                  context, listen: false)
                                                  .getDeckFromId(resultSet[index])
                                                  .name,
                                              style: TextStyle(
                                                  fontSize: mqsWidth(context, 0.035),
                                                  color: _selectedDeck ==
                                                      resultSet[index]
                                                      ? Colors.white : Colors.black
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FlatButton(
                                // disable navigation button if no deck is selected
                                onPressed: _selectedDeck == null ? null
                                    : () =>
                                    pageController.animateToPage(0,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn,
                                    ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Icon(Icons.pie_chart),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "Card performances",
                                        style: TextStyle(
                                          fontSize: mqsWidth(context, 0.035),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: _selectedDeck == null ? null
                                    : () =>
                                    pageController.animateToPage(2,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn,
                                    ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Icon(Icons.show_chart),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "Deck performances",
                                        style: TextStyle(
                                          fontSize: mqsWidth(context, 0.035),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Deck performance"),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery
                              .of(context)
                              .size
                              .height * 0.25,
                          maxHeight: MediaQuery
                              .of(context)
                              .size
                              .height * 0.25,
                        ),
                        child: Consumer<ResultsState>(
                          builder: (context, provider, child) =>
                              DeckPerformance(
                                provider.results.where((d) =>
                                d.deckId == _selectedDeck).toList(),
                                "chart",
                              ),
                        ),
                      ),
                      Expanded(
                        child: Consumer<ResultsState>(
                          builder: (context, provider, child) =>
                              DeckPerformance(
                                provider.results.where((d) =>
                                d.deckId == _selectedDeck).toList(),
                                "list",
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: FlatButton(
                                onPressed: () =>
                                    pageController.animateToPage(1,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn,
                                    ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Icon(Icons.layers),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "Return to deck selection",
                                        style: TextStyle(
                                          fontSize: mqsWidth(context, 0.035),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: () =>
                                    pageController.animateToPage(0,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn,
                                    ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Icon(Icons.pie_chart),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "Card performance",
                                        style: TextStyle(
                                          fontSize: mqsWidth(context, 0.035),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      );
  }
}
