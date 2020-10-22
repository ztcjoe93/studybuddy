
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Objects/objects.dart';
import '../Providers/DecksState.dart';
import 'AddCard.dart';

class CardsManagement extends StatefulWidget {
  @required int deckId;

  CardsManagement(this.deckId);

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
          pageBuilder: (_, __, ___) => AddCard(deckId: widget.deckId),
          transitionDuration: Duration(seconds: 0),
        )
    );

    if (result != null) {
      Provider.of<DecksState>(context, listen: false).addCard(
        deckId: widget.deckId,
        card: result,
      );
      Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            elevation: 6.0,
            behavior: SnackBarBehavior.floating,
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
        body: Consumer<DecksState>(
          builder: (context, provider, child) => Padding(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.getDeckFromId(widget.deckId).name,
                                  style: Theme.of(context).textTheme.headline4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  provider.getDeckFromId(widget.deckId).tag,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => addCard(context),
                                icon: Icon(Icons.library_add),
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                              IconButton(
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                      AlertDialog(
                                        content: RichText(
                                            text: TextSpan(
                                              text: "Do you wish to delete this deck?\n",
                                              style: TextStyle(color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: "* Note that all related results will be removed as well",
                                                  style: TextStyle(fontStyle: FontStyle.italic),
                                                ),
                                              ]
                                            )
                                        ),
                                        actions: [
                                          FlatButton(
                                            child: Text("Yes"),
                                            // return false to provider to delete deck
                                            onPressed: () => Navigator.of(context)
                                              ..pop()
                                              ..pop(false),
                                          ),
                                          FlatButton(
                                            child: Text("No"),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ],
                                      ),
                                ),
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
                        child: Scrollbar(
                          child: Consumer<DecksState>(
                            builder: (context, provider, child) {
                              List<FlashCard> cardList = provider.getDeckFromId(widget.deckId).cards;
                              return ListView.separated(
                                itemBuilder: (BuildContext context, int index) =>
                                    Card(
                                      child: ListTile(
                                        title: Text("${cardList[index].front}"),
                                        subtitle: Text("${cardList[index].back}"),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (BuildContext context) => AlertDialog(
                                              content: Text("Are you sure you wish to delete this card?"),
                                              actions: [
                                                FlatButton(
                                                  child: Text("Yes"),
                                                  onPressed: (){
                                                    provider.removeCardFromId(widget.deckId, cardList[index].id);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text("No"),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                separatorBuilder: (BuildContext context, int index) => Divider(),
                                itemCount: cardList.length,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RaisedButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text("Return to Main Menu")
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }
}


