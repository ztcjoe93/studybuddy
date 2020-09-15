import 'package:flutter/material.dart';
import 'package:memory_cards/Providers/ResultsState.dart';
import 'package:provider/provider.dart';

class Stats extends StatefulWidget {
  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  PageController pageController = PageController(
    initialPage: 1,
  );

  pageNavigation(BuildContext context, int pageIndex){
    if (Provider.of<ResultsState>(context, listen: true).deckIndex == null) {
      return null;
    } else {
      return (){
        pageController.animateToPage(
          pageIndex,
          duration: Duration(milliseconds: 150),
          curve: Curves.easeIn,
        );
      };
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.025,
        horizontal: MediaQuery.of(context).size.width * 0.05,
      ),
      child: PageView(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        pageSnapping: true,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Card performance"),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.25,
                  maxHeight: MediaQuery.of(context).size.height * 0.25,
                ),
                child: Consumer<ResultsState>(
                  builder: (context, results, child) => results.generateChart,
                ),
              ),
              Expanded(
                child: Consumer<ResultsState>(
                  builder: (context, results, child) => results.generateTable(context),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: (){
                      pageController.jumpToPage(2);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.show_chart),
                        Text("Deck performance"),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: (){
                      pageController.animateToPage(
                        1,
                        duration: Duration(milliseconds: 150),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.subdirectory_arrow_right),
                        Text("Return to deck selection"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.05,
                  maxHeight: MediaQuery.of(context).size.height * 0.05,
                ),
                child: Consumer<ResultsState>(
                  builder: (context, results, child) => results.selectedText(context),
                ),
              ),
              Consumer<ResultsState>(
                builder: (context, results, child) => results.selection(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    // disable navigation button if no deck is selected
                    onPressed: pageNavigation(context, 0),
                    child: Row(
                      children: [
                        Icon(Icons.subdirectory_arrow_left),
                        Text("Card performances"),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: pageNavigation(context, 2),
                    child: Row(
                      children: [
                        Icon(Icons.subdirectory_arrow_right),
                        Text("Deck performances"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Deck performance"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: (){
                      pageController.animateToPage(
                        1,
                        duration: Duration(milliseconds: 150),
                        curve: Curves.easeInCubic,
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.subdirectory_arrow_left),
                        Text("Return to deck selection"),
                      ],
                    ),
                  ),
                  FlatButton(
                    onPressed: (){
                      pageController.jumpToPage(0);
                    },
                    child: Row(
                      children: [
                        Text("Card performance"),
                        Icon(Icons.pie_chart),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
