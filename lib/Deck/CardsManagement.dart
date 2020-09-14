
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/DecksState.dart';
import '../objects.dart';
import 'AddCard.dart';

class CardsManagement extends StatefulWidget {
  @required Deck deck;

  CardsManagement(this.deck);

  @override
  _CardsManagementState createState() => _CardsManagementState();
}

class _CardsManagementState extends State<CardsManagement> {
  TextEditingController frontTextController = TextEditingController();
  TextEditingController backTextController = TextEditingController();

  addCard(BuildContext context) async {
    final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AddCard(),
          transitionDuration: Duration(seconds: 0),
        )
    );

    if (result != null) {
      widget.deck.cards.add(result);
      Provider.of<DecksState>(context, listen: false).update(widget.deck);
      Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text("Card ${result.front} has been added to the deck!"),
            duration: Duration(seconds: 1),
          ));
    }
  }

  @override
  void dispose() {
    frontTextController.dispose();
    backTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // use builder to ensure that nested scaffolds correctly display snackbar
        body: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: ListView( // prevent renderflex error when popping from AddCard()
              physics: NeverScrollableScrollPhysics(),
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.deck.name}",
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(
                              "${widget.deck.tag}",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: (){
                                addCard(context);
                              },
                              icon: Icon(Icons.library_add),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                            IconButton(
                              onPressed: (){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          content: Text("Do you wish to delete this deck?"),
                                          actions: [
                                            FlatButton(
                                                child: Text("Yes"),
                                                onPressed: (){
                                                  // return false to provider to delete deck
                                                  Navigator.of(context)
                                                    ..pop()
                                                    ..pop(false);
                                                }
                                            ),
                                            FlatButton(
                                              child: Text("No"),
                                              onPressed: (){
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        )
                                );
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.65,
                        maxHeight: MediaQuery.of(context).size.height * 0.65,
                      ),
                      child: Consumer<DecksState>(
                          builder: (context, decks, child) =>
                              decks.cardManagementView(context, widget.deck)
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text("Return to Main Menu")
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


