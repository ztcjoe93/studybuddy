import 'package:flutter/material.dart';
import '../Objects/objects.dart';

class AddCard extends StatefulWidget {
  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  TextEditingController frontTextController = TextEditingController();
  TextEditingController backTextController = TextEditingController();

  FocusNode frontNode = FocusNode();
  FocusNode backNode= FocusNode();

  bool _emptyFront = false;
  bool _emptyBack= false;

  PageController pageController = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    frontTextController.dispose();
    backTextController.dispose();
    pageController.dispose();
    super.dispose();
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
            child: ListView(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.25,
                  ),
                  child: PageView(
                    controller: pageController,
                    pageSnapping: true,
                    onPageChanged: (int){
                      FocusManager.instance.primaryFocus.unfocus();
                    },
                    children: [
                      // alignment to prevent clipping of textfield label
                      Align(
                        alignment: Alignment.center,
                        child: TextField(
                          controller: frontTextController,
                          focusNode: frontNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Front",
                            errorText: _emptyFront ? "This field is empty" : null,
                          ),
                          minLines: 5,
                          maxLines: 5,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextField(
                          controller: backTextController,
                          focusNode: backNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Back",
                            errorText: _emptyBack ? "This field is empty" : null,
                          ),
                          minLines: 5,
                          maxLines: 5,
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_left),
                    Text(" Swipe to change side "),
                    Icon(Icons.arrow_right),
                  ],
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton(
                      onPressed: (){
                        _emptyFront = frontTextController.text.isEmpty
                            ? true : false;
                        _emptyBack= backTextController.text.isEmpty
                            ? true : false;
                        if (_emptyBack || _emptyFront) {
                          // jump to relevant side with focus
                          if(_emptyFront){
                            pageController.jumpToPage(0);
                            frontNode.requestFocus();
                          } else if (_emptyBack){
                            pageController.jumpToPage(1);
                            backNode.requestFocus();
                          }
                        } else {
                          FlashCard card = FlashCard(
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