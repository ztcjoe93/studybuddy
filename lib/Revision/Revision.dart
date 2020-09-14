import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../Providers/DecksState.dart';

class Revision extends StatefulWidget {
  @override
  _RevisionState createState() => _RevisionState();
}

class _RevisionState extends State<Revision> {
  String _filter = "All";

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
          Expanded(
            child: Consumer<DecksState>(
                builder: (context, decks, child) {
                  return _filter == "All"
                      ? decks.revisionView
                      : decks.revisionViewFiltered(_filter == "None" ? "" : _filter);
                }
            ),
          ),
        ],
      ),
    );
  }
}
