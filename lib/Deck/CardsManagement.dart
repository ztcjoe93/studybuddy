
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
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.easeOutQuint;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 200),
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
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.headline4.fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  provider.getDeckFromId(widget.deckId).tag,
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
                                              text: "Do you wish to delete this deck?\n\n",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: Theme.of(context).textTheme.bodyText1.fontSize * 1.05,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "* Note that all related results will be removed",
                                                  style: TextStyle(fontStyle: FontStyle.italic),
                                                ),
                                              ]
                                            )
                                        ),
                                        actions: [
                                          FlatButton(
                                            child: Text("Yes"),
                                            // return false to provider to delete deck
                                            onPressed: (){
                                              Navigator.of(context)
                                                ..pop()
                                                ..pop(false);
                                            }
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
                    mainAxisAlignment: MainAxisAlignment.center,
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


