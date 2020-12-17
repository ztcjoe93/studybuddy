import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Providers/DecksState.dart';

import '../Database.dart';
import '../Objects/objects.dart';

class AddCard extends StatefulWidget {
  @required int deckId;

  AddCard({this.deckId});

  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  List<FlashCard> fcList;
  final _formKey = GlobalKey<FormState>();
  TextEditingController frontTextController = TextEditingController();
  TextEditingController backTextController = TextEditingController();

  @override
  void dispose() {
    frontTextController.dispose();
    backTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fcList = Provider.of<DecksState>(context, listen: false).getDeckFromId(widget.deckId).cards;
    print(fcList);
  }

  _fieldValidator(String value, bool front){
    // check if it's empty, then check for duplicates
    if (value.isEmpty){
      return 'This field is empty, please enter something here.';
    } else if (value.isNotEmpty){
      if (front && fcList.firstWhere((e)=>e.front==frontTextController.text,orElse:()=>null) != null){
        return 'A card with this text exists, please use some other text.';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus.unfocus();
        },
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.05,
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Add a card",
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 24.0),
                        Divider(height: 2.0),
                        // alignment to prevent clipping of textfield label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "FRONT",
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                              ),
                              TextFormField(
                                controller: frontTextController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  hintText: "Enter text for the front side of your card here!",
                                ),
                                validator: (value) => _fieldValidator(value, true),
                                minLines: 5,
                                maxLines: 5,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                  "BACK",
                                  style: TextStyle(
                                    fontSize: Theme.of(context).textTheme.headline6.fontSize,
                                    fontWeight: FontWeight.bold,
                                  )
                              ),
                            ),
                            TextFormField(
                              controller: backTextController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                hintText: "Enter text for the back side of your card here!",
                              ),
                              validator: (value) => _fieldValidator(value, false),
                              minLines: 5,
                              maxLines: 5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 2.0),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()){
                          FlashCard card = FlashCard(
                            await DBProvider.db.getNewRow("card"),
                            frontTextController.text,
                            backTextController.text,
                          );
                          Navigator.of(context).pop(card);
                        }
                      },
                      child: Text("Add"),
                    ),
                    RaisedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}