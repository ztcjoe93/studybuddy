import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Database.dart';

import '../Objects/objects.dart';
import '../Providers/DecksState.dart';


class AddDeck extends StatefulWidget {
  @override
  _AddDeckState createState() => _AddDeckState();
}

class _AddDeckState extends State<AddDeck> {
  final textController = TextEditingController();
  final tagController = TextEditingController();
  final _scrollViewController = ScrollController();
  String _tag ;

  @override
  void dispose() {
    textController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
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
                                      Navigator.of(context)
                                        ..pop()
                                        ..pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("No"),
                                    onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: textController.text.isEmpty ? null : () async {
                      Provider.of<DecksState>(context, listen: false).addDeck(
                          Deck(
                            await DBProvider.db.getNewRow("deck"),
                            textController.text,
                            tagController.text,
                            [],
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
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "DECK NAME",
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextField(
                            controller: textController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.light
                                ? Colors.grey.shade200
                                : Colors.grey.shade800,
                              hintText: "Enter a name for your deck here!",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "TAG NAME (optional)",
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextField(
                            controller: tagController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade800,
                              hintText: "You can enter a tag to associate your deck here!",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "EXISTING TAGS",
                              style: TextStyle(
                                fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Consumer<DecksState>(
                            builder: (context, deckState, child) => Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey.shade200
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: Padding(
                                padding: EdgeInsets.only(left: 16.0, right: 8.0),
                                child: DropdownButton(
                                  isExpanded: true,
                                  value: _tag,
                                  icon: Icon(Icons.arrow_drop_down),
                                  underline: SizedBox(),
                                  onChanged: (val){
                                    tagController.text = val;
                                    setState(() {
                                      _tag = val;
                                    });
                                  },
                                  items: deckState.tagFilters(emptyIncluded: true),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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