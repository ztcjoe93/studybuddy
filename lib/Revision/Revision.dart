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
          FittedBox(
            child: Text(
              "Select a deck to start the revision",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Revision mode: "
                  "${firstUpper(Provider.of<OverallState>(context, listen: true).revisionStyle)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
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
                      var additionalItems = deckState.tagFilters(emptyIncluded: false)
                        .map<DropdownMenuItem<String>>((String val) =>
                          DropdownMenuItem(
                            value: val,
                            child: Text(val),
                          )
                      ).toList();
                      var prov = Provider.of<OverallState>(context, listen: true);
                      return DropdownButton(
                        isExpanded: true,
                        value: prov.revisionFilter,
                        icon: Icon(Icons.arrow_drop_down),
                        underline: SizedBox(),
                        onChanged: (val){
                          setState(() {
                            prov.revisionFilter= val;
                          });
                        },
                        items: [
                          DropdownMenuItem(
                            value: "All",
                            child: Text("All"),
                          ),
                          ...additionalItems,
                          DropdownMenuItem(
                              value: "None",
                              child: Text("None")
                          )
                        ],
                      );
                    },
                  ),
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

                      var prov = Provider.of<OverallState>(context, listen: true);
                      if(prov.revisionFilter == "All") {
                        availableDecks = provider.decks
                            .where((d) => d.cards.length != 0)
                            .toList();
                      } else if (prov.revisionFilter == "None"){
                        availableDecks = provider.decks
                            .where((d) => d.tag == "" && d.cards.length > 0)
                            .toList();
                      } else {
                        availableDecks = provider.decks
                            .where((d) => d.tag == prov.revisionFilter && d.cards.length>0)
                            .toList();
                      }
                      if(availableDecks.isEmpty){
                        return Center(
                          child: Text("Empty"),
                        );
                      } else {
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
                        );
                      }
                    }),
              ),
            )
            ),
        ],
      ),
    );
  }
}
