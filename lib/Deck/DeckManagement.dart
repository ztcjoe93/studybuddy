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

  addDeck(BuildContext context) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddDeck(),
        transitionDuration: Duration(seconds: 0),
      ),
    );

    // display snackbar if valid deck was added
    if (result != null)
    Scaffold.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
        SnackBar(
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
              RaisedButton(
                onPressed: () => addDeck(context),
                child: Text("Add"),
                color: Color.fromRGBO(255, 255, 255, 0.9),
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
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                ),
              ),
              child: Consumer<DecksState>(
                builder: (context, provider, child) {
                  if (_filter == "All"){
                    return Scrollbar(
                      child: ListView.separated(
                        itemCount: provider.decks.length,
                        itemBuilder: (BuildContext context, int index) => ListTile(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => CardsManagement(provider.decks[index].id),
                                transitionDuration: Duration(seconds: 0),
                              ),
                            );

                            if (result == false){
                              Provider.of<ResultsState>(context, listen: false).remove(provider.decks[index].name);
                              Provider.of<DecksState>(context, listen: false).remove(provider.decks[index]);
                            }
                          },
                          title: Text("${provider.decks[index].name}"),
                          subtitle: Text("${provider.decks[index].tag}"),
                        ),
                        separatorBuilder: (BuildContext context, int index) => Divider(),
                      ),
                    );
                  } else {
                    List<Deck> filtered = provider.decks.where((deck) => deck.tag == _filter).toList();
                    return Scrollbar(
                      child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) => ListTile(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => CardsManagement(filtered[index].id),
                                transitionDuration: Duration(seconds: 0),
                              ),
                            );

                            if (result == false){
                              Provider.of<ResultsState>(context, listen: false).remove(filtered[index].name);
                              Provider.of<DecksState>(context, listen: false).remove(filtered[index]);
                            }

                          },
                          title: Text("${filtered[index].name}"),
                          subtitle: Text("${filtered[index].tag}"),
                        ),
                        separatorBuilder: (BuildContext context, int index) => Divider(),
                        itemCount: filtered.length,
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


