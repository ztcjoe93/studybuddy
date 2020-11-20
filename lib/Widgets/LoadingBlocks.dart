import 'package:flutter/material.dart';
import '../FadeIn.dart';


class LoadingBlocks extends StatefulWidget {
  List<int> rawScore;

  LoadingBlocks({@required this.rawScore});

  @override
  _LoadingBlocksState createState() => _LoadingBlocksState();
}

class _LoadingBlocksState extends State<LoadingBlocks> with SingleTickerProviderStateMixin{
  int score;
  bool _results = false;
  List<List<Widget>> data = [
    List<Widget>(),
    List<Widget>(),
    List<Widget>(),
    List<Widget>(),
  ];

  final List<GlobalKey<AnimatedListState>> _listKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  void initState() {
    super.initState();
    score = ((widget.rawScore[0]/widget.rawScore[1])*100).round();
    initializeSquares();
  }

  initializeSquares() {
    int x = 0;

    List<Widget> row = [];

    for (int i = 0; i < 100; i++) {
      if (x < score) {
        row.add(
            Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
              ),
            )
        );
      } else {
        row.add(
            Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
            )
        );
      }
      x++;
    }

    var future = Future((){});
    for(int i = 0; i < 4; i++){
      for(int j = 0; j < 25; j++){
        future = future.then((_){
          if(i == 3 && j == 24){
            setState(() {
              _results = true;
            });
            Future.delayed(Duration(seconds: 3), () {
              Navigator.of(context).pop();
            });
          }
          return Future.delayed(Duration(milliseconds: 10), (){
            print("[${DateTime.now()}] adding...");
            data[i].add(row[25*i+j]);
            _listKeys[i].currentState.insertItem(data[i].length-1);
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            for(int i=0; i < 4; i++)
              Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: AnimatedList(
                    scrollDirection: Axis.horizontal,
                    key: _listKeys[i],
                    initialItemCount: data[i].length,
                    itemBuilder: (context, index, animation){
                      return FadeIn(
                        duration: 300,
                        child: data[i][index],
                      );
                    },
                  ),
                ),
              ),
            AnimatedOpacity(
              opacity: _results ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Text(
                "Your score is: ${widget.rawScore[0]}/${widget.rawScore[1]}",
                style: Theme.of(context).textTheme.headline2,
              ),
            )
          ],
        ),
      ],
    );
  }
}
