import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Providers/DeckProvider.dart';
import 'objects.dart';

class CardsManagement extends StatefulWidget {
  @required Deck deck;

  CardsManagement(this.deck);

  @override
  _CardsManagementState createState() => _CardsManagementState();
}

class _CardsManagementState extends State<CardsManagement> {

  TextEditingController frontTextController = TextEditingController();
  TextEditingController backTextController = TextEditingController();

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
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                  ],
                                )
                              ),
                            )
                          );
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
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Scrollbar(
                  child: Consumer<DecksState>(
                  builder: (context, decks, child) =>
                    decks.cardManagementView(context, widget.deck)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
