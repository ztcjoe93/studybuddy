import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Deck/CardsManagement.dart';
import 'package:studybuddy/Objects/objects.dart';
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

    // display snackbar if valid deck was added
    if (result != null)
    Scaffold.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
        SnackBar(
          elevation: 6.0,
          behavior: SnackBarBehavior.floating,
          content: Text("[$result] has been added to the list!"),
          duration: Duration(seconds: 1),
        ),
    );
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
              Consumer<DecksState>(
                builder: (context, deckState, child){
                  return DropdownButton(
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
                    ), ...deckState.tagFilters,
                    DropdownMenuItem(
                      value: "None",
                      child: Text("None")
                    )],
                  );
                },
              ),
            ],
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Consumer<DecksState>(
              builder: (context, provider, child) {
                if (_filter == "All"){
                  return Scrollbar(
                    isAlwaysShown: true,
                    controller: _scrollController,
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: provider.decks.length,
                      itemBuilder: (BuildContext context, int index) {
                        Deck targetDeck = provider.decks[index];
                        return ListTile(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    CardsManagement(targetDeck.id),
                                transitionDuration: Duration(seconds: 0),
                              ),
                            );

                            if (result == false) {
                              Provider.of<ResultsState>(context, listen: false)
                                  .remove(targetDeck.id);
                            }
                          },
                          title: Text("${targetDeck.name}"),
                          subtitle: Text("${targetDeck.tag}"),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => Divider(),
                    ),
                  );
                } else {
                  List<Deck> filtered = provider.decks.where((deck) => deck.tag == _filter).toList();
                  return Container(
                    child: Scrollbar(
                      isAlwaysShown: true,
                      controller: _scrollController,
                      child: ListView.separated(
                        controller: _scrollController,
                        itemBuilder: (BuildContext context, int index) => ListTile(
                          onTap: () async {
                            _filter = 'All';
                            final result = await Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => CardsManagement(filtered[index].id),
                                transitionDuration: Duration(seconds: 0),
                              ),
                            );

                            if (result == false){
                              Provider.of<ResultsState>(context, listen: false)
                                  .remove(filtered[index].id);
                            }
                          },
                          title: Text("${filtered[index].name}"),
                          subtitle: Text("${filtered[index].tag}"),
                        ),
                        separatorBuilder: (BuildContext context, int index) => Divider(),
                        itemCount: filtered.length,
                      ),
                    ),
                  );
                }
              }
            ),
          ),
        ],
      ),
    );
  }
}


