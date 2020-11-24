import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Objects/objects.dart';
import 'package:studybuddy/Revision/RevisionSession.dart';

import '../Providers/DecksState.dart';

class Revision extends StatefulWidget {
  @override
  _RevisionState createState() => _RevisionState();
}

class _RevisionState extends State<Revision> {
  String _filter = "All";
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height * 0.025,
      ),
      child: Column(
        children: [
          Text(
            "Select a deck to start the revision",
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                    items: [
                      DropdownMenuItem(
                        value: "All",
                        child: Text("All"),
                      ),
                      ...deckState.tagFilters,
                      DropdownMenuItem(
                          value: "None",
                          child: Text("None")
                      )
                    ],
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: Consumer<DecksState>(
                builder: (context, provider, child) {
                  List<Deck> availableDecks = [];

                  if(_filter == "All") {
                    availableDecks = provider.decks
                        .where((d) => d.cards.length != 0)
                        .toList();
                  } else {
                    availableDecks = provider.decks
                        .where((d) => d.tag == _filter && d.cards.length>0)
                        .toList();
                  }
                  return Scrollbar(
                    isAlwaysShown: true,
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: availableDecks.length,
                      itemBuilder: (BuildContext context, int index) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: OpenContainer(
                            closedBuilder: (context, action){
                              return ListTile(
                                title: Text("${availableDecks[index].name}"),
                                subtitle: Text("${availableDecks[index].tag}"),
                              );
                            },
                            openBuilder: (context, action){
                              return RevisionSession(availableDecks[index]);
                            },
                          ),
                        ),
                        /*
                        Card(
                          child: ListTile(
                            onTap: () => Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_,__,___) => RevisionSession(availableDecks[index]),
                                transitionDuration: Duration(seconds: 0),
                              )
                            ),
                            title: Text("${availableDecks[index].name}"),
                            subtitle: Text("${availableDecks[index].tag}"),
                          ),
                               */
                        ),
                    );}
                  )
            ),
        ],
      ),
    );
  }
}
