import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Charts/CardPerformance.dart';
import 'package:studybuddy/Charts/DeckPerformance.dart';
import 'package:studybuddy/Providers/DecksState.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Providers/ResultsState.dart';

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
      print("Debug :: widget state reset.");
      Provider.of<OverallState>(context, listen: false).updateDeckHasChanged();
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
          vertical: MediaQuery
              .of(context)
              .size
              .height * 0.025,
          horizontal: MediaQuery
              .of(context)
              .size
              .width * 0.05,
        ),
        child: PageView(
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          pageSnapping: true,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Card performance"),
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
                  child: CardPerformance(
                    Provider
                        .of<ResultsState>(context, listen: true)
                        .results
                        .where((d) => d.deckId == _selectedDeck)
                        .toList(),
                    "chart",
                  ),
                ),
                Expanded(
                  child: Consumer<ResultsState>(
                    builder: (context, provider, child) =>
                        CardPerformance(
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
                      FlatButton(
                        onPressed: () =>
                            pageController.animateToPage(2,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                            ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0),
                              child: Icon(Icons.show_chart),
                            ),
                            Text("Deck performances"),
                          ],
                        ),
                      ),
                      FlatButton(
                        onPressed: () =>
                            pageController.animateToPage(1,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                            ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0),
                              child: Icon(Icons.layers),
                            ),
                            Text("Deck selection"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery
                          .of(context)
                          .size
                          .height * 0.05,
                      maxHeight: MediaQuery
                          .of(context)
                          .size
                          .height * 0.065,
                    ),
                    child: Consumer<ResultsState>(
                      builder: (context, provider, child) {
                        String _selection = _selectedDeck == null
                            ? "No deck"
                            : Provider
                            .of<DecksState>(context, listen: true)
                            .getDeckFromId(_selectedDeck)
                            .name;
                        return Center(
                          child: Text(
                            "$_selection is selected",
                            style: Theme
                                .of(context)
                                .textTheme
                                .headline5,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
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
                                Container(
                                  decoration: BoxDecoration(
                                    color: resultSet[index] == _selectedDeck
                                        ? Colors.lightBlueAccent : Colors
                                        .transparent,
                                  ),
                                  child: ListTile(
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
                                          color: _selectedDeck ==
                                              resultSet[index]
                                              ? Colors.white : Colors.black
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
                      FlatButton(
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
                            Text("Card performances"),
                          ],
                        ),
                      ),
                      FlatButton(
                        onPressed: (){
                          print("${widget.state}");
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            Text("Check values"),
                          ],
                        ),
                      ),
                      FlatButton(
                        onPressed: _selectedDeck == null ? null
                            : () =>
                            pageController.animateToPage(2,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                            ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0),
                              child: Icon(Icons.show_chart),
                            ),
                            Text("Deck performances"),
                          ],
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
                      FlatButton(
                        onPressed: () =>
                            pageController.animateToPage(1,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                            ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0),
                              child: Icon(Icons.layers),
                            ),
                            Text("Return to deck selection"),
                          ],
                        ),
                      ),
                      FlatButton(
                        onPressed: () =>
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
                            Text("Card performance"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }
}
