import 'package:flutter/material.dart';
import 'package:studybuddy/Database.dart';

class DebugHome extends StatefulWidget {
  @override
  _DebugHomeState createState() => _DebugHomeState();
}

class _DebugHomeState extends State<DebugHome> {
  int _selection;

  @override
  void initState() {
    super.initState();
    _selection = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RaisedButton(
              onPressed: (){
                setState(() {
                  _selection = 0;
                });
              },
              child: Text("Decks"),
            ),
            RaisedButton(
              onPressed: (){
                setState(() {
                  _selection = 1;
                });
              },
              child: Text("Cards"),
            ),
            RaisedButton(
              onPressed: (){
                setState(() {
                  _selection = 2;
                });
              },
              child: Text("Results"),
            ),
          ],
        ),
        FutureBuilder(
          future: _selection == 0
              ? DBProvider.db.decks
              : _selection == 1
                ? DBProvider.db.cards
                : DBProvider.db.results,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            var children;
            if (snapshot.hasData){
              return Flexible(
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.05,
                        maxHeight: MediaQuery.of(context).size.height * 0.05,
                      ),
                      child: Card(
                        child: Row(
                          children: [
                            for(var i in snapshot.data[index].keys)
                              Expanded(
                                flex: 1,
                                child: Text("${snapshot.data[index][i]}"),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Icon(Icons.camera_alt);
            }
          },
        ),
      ],
    );
  }
}
