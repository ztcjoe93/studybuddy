import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Objects/objects.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Utilities.dart';

class CardPerformance extends StatefulWidget {
  List<Result> results;
  String data;

  CardPerformance(this.results, this.data);

  @override
  _CardPerformanceState createState() => _CardPerformanceState();
}

class _CardPerformanceState extends State<CardPerformance> {
  List<dynamic> consolidatedList = [];
  var consolidatedResults = Map();

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

    if (consolidatedList.length >= 0) {
      setState(() {
        consolidatedList = consolidatedResults.entries.map((r) =>
        {
          'front': r.key,
          'back': r.value['back'],
          '%': r.value['%'],
          'score': r.value['score'],
          'tries': r.value['count'],
        }
        ).toList();
      });
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
              ? Colors.lightGreen[300]
              : datum['domain'] == "Good"
                ? Colors.amber[300]
                : Colors.red[300]
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
  void didUpdateWidget(covariant CardPerformance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.results.length != oldWidget.results.length){
      setState(() {
        oldWidget.results = widget.results;
        consolidate(context);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    consolidate(context);
  }

  @override
  Widget build(BuildContext context) {
    // https://github.com/google/charts/issues/277
    // check charts_flutter/base_chart_state.dart line 72
    if (widget.data == "chart") {
      return charts.PieChart(
        generateChart(consolidatedResults),
        animate: true,
        // https://google.github.io/charts/flutter/example/legends/datum_legend_options
        behaviors: [
          charts.DatumLegend(
            position: charts.BehaviorPosition.end,
            insideJustification: charts.InsideJustification.topEnd,
            horizontalFirst: false,
            desiredMaxRows: 3,
            cellPadding: EdgeInsets.all(2.0),
            entryTextStyle: charts.TextStyleSpec(
              fontSize: mqsWidth(context, 0.035).toInt(),
            )
          ),
        ],
        //defaultInteractions: true,
        defaultRenderer: charts.ArcRendererConfig(
          arcRendererDecorators: [
            charts.ArcLabelDecorator(
              outsideLabelStyleSpec: charts.TextStyleSpec(
                color: charts.ColorUtil.fromDartColor(
                  Provider.of<OverallState>(context, listen:false).darkMode
                    ? Colors.white : Colors.black,
                ),
                //resize chart labels to cater to smaller screen sized devices
                fontSize: mqsWidth(context, 0.025).toInt(),
              ),
            )
          ],
          arcWidth: mqsWidth(context, 0.04).toInt(),
        ),
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
                  for(final i in [
                    ['front', 0],
                    ['back', 1],
                    ['%', 2],
                    ['score', 3],
                    ['tries', 4],
                  ])
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () => sortFunction(_sorted, i[0], i[1]),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: FittedBox(
                                  child: Text(
                                    firstUpper(i[0]),
                                    style: TextStyle(
                                      fontSize: mqsWidth(context, 0.035)
                                    )
                                  ),
                                ),
                              ),
                              if(_selectedCol == i[1])
                                FittedBox(
                                  child: Icon(
                                    _sorted
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                  )
                                )
                            ],
                          )
                        )
                      )
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
               child: ListView.builder(
                 itemCount: consolidatedList.length,
                 itemBuilder: (context, index){
                   return Padding(
                     padding: EdgeInsets.symmetric(vertical: 16.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         for(final s in [
                           "${consolidatedList[index]['front']}",
                           "${consolidatedList[index]['back']}",
                           "${consolidatedList[index]['%'].toStringAsFixed(2)}",
                           "${consolidatedList[index]['score']}",
                           "${consolidatedList[index]['tries']}",
                         ])
                           Expanded(
                             flex: 1,
                             child: Padding(
                               padding: EdgeInsets.only(right: 10.0),
                               child: Center(
                                 child: Text(
                                   s,
                                   textAlign: TextAlign.center,
                                   style: TextStyle(fontSize: mqsWidth(context, 0.035)),
                                 ),
                               ),
                             ),
                           ),
                       ],
                     )
                   );
                 }
               ),
              ),
            ),
          ),
        ],
      );
    }
  }
}