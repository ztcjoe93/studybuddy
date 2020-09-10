import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/DecksState.dart';
import '../objects.dart';


class AddDeck extends StatefulWidget {
  @override
  _AddDeckState createState() => _AddDeckState();
}

class _AddDeckState extends State<AddDeck> {
  final textController = TextEditingController();
  final tagController = TextEditingController();
  String _tag ;

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
        onTap: () => FocusManager.instance.primaryFocus.unfocus(),
        // FocusScope.of(context).requestFocus(FocusNode()), <-- deprecated
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
                    Row(
                      children: [
                        Text("Existing tags: "),
                        Consumer<DecksState>(
                          builder: (context, deckState, child) => DropdownButton(
                            value: _tag,
                            icon: Icon(Icons.arrow_drop_down),
                            underline: SizedBox(),
                            onChanged: (val){
                              tagController.text = val;
                              setState(() {
                                _tag = val;
                              });
                            },
                            items: deckState.tagFilters,
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