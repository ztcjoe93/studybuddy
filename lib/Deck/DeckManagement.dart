import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/DecksState.dart';
import 'AddDeck.dart';

class DeckManagement extends StatefulWidget {
  @override
  _DeckManagementState createState() => _DeckManagementState();
}

class _DeckManagementState extends State<DeckManagement> {
  String _filter = "None";

  @override
  void initState() {
    super.initState();
  }

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
          duration: Duration(seconds: 2),
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
                      value: "None",
                      child: Text("None"),
                    ), ...deckState.tagFilters],
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
                builder: (context, decks, child) {
                  return _filter == "None"
                      ? decks.deckManagementView
                      : decks.deckManagementViewFiltered(_filter);
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}


