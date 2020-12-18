import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Deck/CardsManagement.dart';
import 'package:studybuddy/Objects/objects.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Providers/ResultsState.dart';

import '../Providers/DecksState.dart';
import 'AddDeck.dart';

class DeckManagement extends StatefulWidget {
  @override
  _DeckManagementState createState() => _DeckManagementState();
}

class _DeckManagementState extends State<DeckManagement> {
  String _filter = "All";
  final _scrollController = ScrollController();

  addDeck(BuildContext context) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddDeck(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.easeOutQuint;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 200),
      ),
    );

    // display snackbar if valid deck was added
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 6.0,
            behavior: SnackBarBehavior.floating,
            content: Text("$result has been added to the deck list!"),
            duration: Duration(seconds: 1),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.05,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => addDeck(context),
                icon: Icon(Icons.library_add),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Consumer<DecksState>(
                  builder: (context, deckState, child){
                    return DropdownButton(
                      isExpanded: true,
                      value: _filter,
                      icon: Icon(Icons.arrow_drop_down),
                      underline: SizedBox(),
                      onChanged: (val){
                        setState(() {
                          _filter = val;
                        });
                      },
                      items: [DropdownMenuItem(
                        value: "All",
                        child: Text("All"),
                      ), ...deckState.tagFilters(emptyIncluded: true),
                      DropdownMenuItem(
                        value: "None",
                        child: Text("None")
                      )],
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0x7Acfd8dc),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0x7Acfd8dc),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Consumer<DecksState>(
                builder: (context, provider, child) {
                  if (_filter == "All"){
                    return Scrollbar(
                      isAlwaysShown: true,
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: provider.decks.length,
                        itemBuilder: (BuildContext context, int index) {
                          Deck targetDeck = provider.decks[index];
                          return Card(
                            margin: EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                              left: 5.0,
                              right: 15.0,
                            ),
                            child: ListTile(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        CardsManagement(targetDeck.id),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      var begin = Offset(1.0, 0.0);
                                      var end = Offset.zero;
                                      var curve = Curves.ease;

                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: Duration(milliseconds: 200),
                                  ),
                                );

                                if (result == false) {
                                  // prevent CardsManagement widget from being deleted before transition is complete
                                  Future.delayed(Duration(milliseconds: 350), (){
                                    Provider.of<OverallState>(context, listen: false)
                                        .deckHasBeenChanged(false);
                                    Provider.of<DecksState>(context, listen: false)
                                        .remove(targetDeck.id);
                                    Provider.of<ResultsState>(context, listen: false)
                                        .remove(targetDeck.id);
                                    print("Deletion complete");
                                  });
                                }
                              },
                              title: Text(
                                "${targetDeck.name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("${targetDeck.tag}"),
                            ),
                          );
                        },
                        //separatorBuilder: (BuildContext context, int index) => Divider(),
                      ),
                    );
                  } else {
                    String _selectedFilter = _filter == "None" ? "" : _filter;
                    List<Deck> filtered = provider.decks.where((deck) => deck.tag == _selectedFilter).toList();
                    return Container(
                      child: Scrollbar(
                        isAlwaysShown: true,
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (BuildContext context, int index) => Card(
                            margin: EdgeInsets.only(
                              top: 5.0,
                              bottom: 5.0,
                              left: 5.0,
                              right: 15.0,
                            ),
                            child: ListTile(
                              onTap: () async {
                                _filter = 'All';
                                final result = await Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => CardsManagement(filtered[index].id),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      var begin = Offset(1.0, 0.0);
                                      var end = Offset.zero;
                                      var curve = Curves.ease;

                                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                    transitionDuration: Duration(milliseconds: 200),
                                  ),
                                );

                                if (result == false){
                                  Future.delayed(Duration(milliseconds: 350), (){
                                    Provider.of<OverallState>(context, listen: false)
                                        .deckHasBeenChanged(false);
                                    Provider.of<DecksState>(context, listen: false)
                                        .remove(filtered[index].id);
                                    Provider.of<ResultsState>(context, listen: false)
                                        .remove(filtered[index].id);
                                    print("Deletion complete");
                                  });
                                }
                              },
                              title: Text(
                                "${filtered[index].name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("${filtered[index].tag}"),
                            ),
                          ),
                          //separatorBuilder: (BuildContext context, int index) => Divider(),
                          itemCount: filtered.length,
                        ),
                      ),
                    );
                  }
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}


