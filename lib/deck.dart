import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Providers/DeckProvider.dart';
import 'objects.dart';

class DeckManagement extends StatefulWidget {
  @override
  _DeckManagementState createState() => _DeckManagementState();
}

class _DeckManagementState extends State<DeckManagement> {
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
            children: [
              RaisedButton(
                onPressed: () => addDeck(context),
                child: Text("Add"),
                color: Color.fromRGBO(255, 255, 255, 0.9),
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
                  return decks.deckManagementView;
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddDeck extends StatefulWidget {
  @override
  _AddDeckState createState() => _AddDeckState();
}

class _AddDeckState extends State<AddDeck> {
  final textController = TextEditingController();
  final tagController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        // FocusScope.of(context).unfocus() causes keyboard focus glitch
        child: Scaffold(
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.blueAccent,
                    splashColor: Colors.transparent, // hide splash
                    onPressed: (){
                      textController.text.isNotEmpty
                          ? showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  content: Text("Do you wish to return to the main menu?"),
                                  actions: [
                                    FlatButton(
                                      child: Text("Yes"),
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text("No"),
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              }
                            )
                          : Navigator.of(context).pop();
                      }
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    iconSize: 36.0,
                    color: Colors.blueAccent,
                    splashColor: Colors.transparent,
                    onPressed: textController.text.isEmpty ? null : (){
                      Provider.of<DecksState>(context, listen: false).add(
                        Deck(
                         textController.text,
                         tagController.text,
                         [FlashCard("front", "back")],
                        )
                      );
                      Navigator.of(context).pop("${textController.text}");
                    },
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Deck Name",
                          prefixIcon: Icon(Icons.list),
                        ),
                      ),
                    ),
                    TextField(
                      controller: tagController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Tag",
                          prefixIcon: Icon(Icons.label),
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

