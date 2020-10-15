import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:studybuddy/Objects/objects.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:provider/provider.dart';

class CardPerformance extends StatefulWidget {
  final List<Result> results;
  String data;

  CardPerformance(this.results, this.data);

  @override
  _CardPerformanceState createState() => _CardPerformanceState();
}

class _CardPerformanceState extends State<CardPerformance> {
  List<dynamic> consolidatedList = [];

  final consolidatedResults = Map();

  bool _sorted = false;
  int _selectedCol;

  consolidate(BuildContext context){
    // iterate over each card in result
    for (var result in widget.results){
      for (var card in result.results) {
        // add to map if not exists, +1 to count, +1 to score if true
        if (!consolidatedResults.containsKey(card.card.front)){
          consolidatedResults[card.card.front] = {
            'back': card.card.back,
            'count': 0,
            'score': 0,
          };
        }
        if (card.score) {
          consolidatedResults[card.card.front]['score']++;
        }
        consolidatedResults[card.card.front]['count']++;
      }
    }

    consolidatedResults.forEach((key, value) {
      consolidatedResults[key]['%'] = 100 * (value['score']/value['count']);
    });

    if (consolidatedList.length == 0) {
      consolidatedList = consolidatedResults.entries.map((r) =>
      {
        'front': r.key,
        'back': r.value['back'],
        '%': r.value['%'],
        'score': r.value['score'],
        'tries': r.value['count'],
      }
      ).toList();
    }
  }

  sortFunction(bool asc, String key, int colIndex){
    setState(() {
      // selected on a new column
      if (_selectedCol == colIndex){
        _sorted = !_sorted;
      } else {
        _selectedCol = colIndex;
        _sorted = true;
      }

      // true -> descending, false -> ascending
      if (_sorted) {
        consolidatedList.sort((a, b) => b[key].compareTo(a[key]));
      } else {
        consolidatedList.sort((a, b) => a[key].compareTo(b[key]));
      }
    });
  }

  generateListTable(context){
    //return Text("test");
    return ListView.builder(
      itemCount: consolidatedList.length,
      itemBuilder: (BuildContext context, int index){
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text("${consolidatedList[index]['front']}"),
              ),
              Expanded(
                flex: 1,
                child: Text("${consolidatedList[index]['back']}"),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    "${consolidatedList[index]['%'].toStringAsFixed(2)}",
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text("${consolidatedList[index]['score']}")),
              ),
              Expanded(
                flex: 1,
                child: Center(child: Text("${consolidatedList[index]['tries']}")),
              ),
             ],
          ),
        );
      },
    );
  }

  generateChart(data){
    final prefs = Provider.of<OverallState>(context, listen: true);
    final List<Map<String, dynamic>> chartData = [
      {'domain': "Great", 'count': 0},
      {'domain': "Good", 'count': 0},
      {'domain': "Poor", 'count': 0},
    ];
    int totalCount = 0;

    for (var key in data.keys){
      if(data[key]['%'] >= prefs.upperLimit){
        chartData[0]['count']++;
      } else if (data[key]['%'] < prefs.lowerLimit){
        chartData[2]['count']++;
      } else {
        chartData[1]['count']++;
      }
      totalCount++;
    }

    chartData.removeWhere((element) => element['count'] == 0);

    return [
      charts.Series<dynamic, dynamic>(
        id: 'Card Performance',
        colorFn: (dynamic datum, _) => charts.ColorUtil.fromDartColor(
          datum['domain'] == "Great"
              ? Colors.lightGreen.withOpacity(0.5)
              : datum['domain'] == "Good"
                ? Colors.yellow.withOpacity(0.5)
                : Colors.redAccent.withOpacity(0.5)
        ),
        domainFn: (dynamic datum, _) => datum['domain'],
        measureFn: (dynamic datum, _) => datum['count'],
        // https://google.github.io/charts/flutter/example/pie_charts/auto_label
        labelAccessorFn: (dynamic datum, _) =>
          // convert to 2 d.p string
          "${(100 * datum['count']/totalCount).toStringAsFixed(2)}%",
        data: chartData,
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    consolidate(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == "chart") {
      return charts.PieChart(
        generateChart(consolidatedResults),
        animate: false,
        // https://google.github.io/charts/flutter/example/legends/datum_legend_options
        behaviors: [
          charts.DatumLegend(
            position: charts.BehaviorPosition.end,
            insideJustification: charts.InsideJustification.topEnd,
            horizontalFirst: false,
            desiredMaxRows: 3,
            cellPadding: EdgeInsets.all(4.0),
          ),
        ],
        //defaultInteractions: true,
        defaultRenderer: charts.ArcRendererConfig(
            arcRendererDecorators: [charts.ArcLabelDecorator()]
        ),
        /* for interaction with PieChart
        selectionModels: [
          charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            // check for relevant `domain` key in selectedDatum to filter
            changedListener: (model){
              try {
                _selected = model.selectedDatum.first.datum['domain'];
                return _selected;
              } catch(e){
                print("Tapped on outside of pie chart range.");
              }
            },
          ),
        ],
         */
      );
    } else if (widget.data == "list") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        sortFunction(_sorted, "front", 0);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text("Front"),
                            if (_selectedCol == 0)
                              Icon(_sorted ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        sortFunction(_sorted, "back", 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text("Back"),
                            if (_selectedCol == 1)
                              Icon(_sorted ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: (){
                        sortFunction(_sorted, "%", 2);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text("Performance (%)"),
                            if (_selectedCol == 2)
                              Icon(
                                _sorted ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                        sortFunction(_sorted, "score", 3);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text("Score"),
                            if (_selectedCol == 3)
                              Icon(
                                _sorted ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: (){
                       sortFunction(_sorted, "tries", 4);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Text("Tries"),
                            if (_selectedCol == 4)
                              Icon(
                                _sorted ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
               child: generateListTable(context),
              ),
            ),
          ),
        ],
      );
    }
  }
}