import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Objects/objects.dart';
import 'package:studybuddy/Providers/OverallState.dart';

import '../Utilities.dart';
import '../Providers/DecksState.dart';
import 'RevisionSession.dart';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  "Revision mode: "
                  "${firstUpper(Provider.of<OverallState>(context, listen: true).revisionStyle)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.grey.shade800,
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
                      items: [
                        DropdownMenuItem(
                          value: "All",
                          child: Text("All"),
                        ),
                        ...deckState.tagFilters(emptyIncluded: false),
                        DropdownMenuItem(
                            value: "None",
                            child: Text("None")
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0x7Acfd8dc),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0x7Acfd8dc),
                ),
                child: Consumer<DecksState>(
                    builder: (context, provider, child) {
                      List<Deck> availableDecks = [];

                      if(_filter == "All") {
                        availableDecks = provider.decks
                            .where((d) => d.cards.length != 0)
                            .toList();
                      } else if (_filter == "None"){
                        availableDecks = provider.decks
                            .where((d) => d.tag == "" && d.cards.length > 0)
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
                              padding: const EdgeInsets.only(
                                top: 5.0,
                                left: 5.0,
                                bottom: 8.0,
                                right: 15.0,
                              ),
                              child: OpenContainer(
                                closedColor: Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.grey.shade800,
                                closedBuilder: (context, action){
                                  return ListTile(
                                    title: Text(
                                      "${availableDecks[index].name}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text("${availableDecks[index].tag}"),
                                  );
                                },
                                openBuilder: (context, action){
                                  var revisionStyle = Provider.of<OverallState>(context, listen:true).revisionStyle;
                                  return RevisionSession(availableDecks[index], revisionStyle);
                                },
                              ),
                            ),
                          ),
                        );}
                      ),
              ),
            )
            ),
        ],
      ),
    );
  }
}
