import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

import '../Objects/objects.dart';

class DeckPerformance extends StatefulWidget {
  final List<Result> results;
  String data;

  DeckPerformance(this.results, this.data);

  @override
  _DeckPerformanceState createState() => _DeckPerformanceState();
}

class _DeckPerformanceState extends State<DeckPerformance> {
  List<dynamic> consolidatedList = [];
  // function measuring purposes
  // https://api.dart.dev/stable/2.9.3/dart-core/Stopwatch-class.html
  Stopwatch sw = Stopwatch();

  consolidate(){
    sw.start();
    consolidatedList = [];

    widget.results.forEach((result) {
      int totalScore = result.results.where((cr) => cr.score).length;
      var cdate = DateTime.parse(result.isoTimestamp);

      consolidatedList.add(
        LineSeriesData(
          DateTime(cdate.year, cdate.month, cdate.day),
          cdate,
          (100 * totalScore/result.results.length),
          result.results.length,
          result.results,
        )
      );
    });

    var dateList = [];
    consolidatedList.forEach((lsd){
      var compareList = dateList.map((e)=> e['session']).toList();
      if (!compareList.contains(lsd.chartUse)){
        dateList.add(
          {
            "session": lsd.chartUse,
            "performance": lsd.performance,
            "count": 1,
          }
        );
      } else {
        var ind = dateList.indexWhere((e) =>
          e["session"] == lsd.chartUse);
        dateList[ind]['performance'] += lsd.performance;
        dateList[ind]['count']++;
      }
    });

    // average performance in each day
    dateList.forEach((element) {
      element['performance'] /= element['count'];
    });

    return generateChart(dateList);
  }

  generateListTable(){
    return ListView.builder(
      itemCount: consolidatedList.length,
      itemBuilder: (BuildContext context, int index){
        return InkWell(
          onTap: (){},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                      "${DateFormat.yMd()
                          .add_jm()
                          .format(consolidatedList[index].session)
                      }"
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text("${consolidatedList[index].performance.toStringAsFixed(2)}"),
                ),
                Expanded(
                  flex: 1,
                  child: Text("${consolidatedList[index].totalCards}"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  generateTable(){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: MediaQuery.of(context).size.width * 0.085,
        showCheckboxColumn: false,
        columns: [
          DataColumn(
            label: Text("Session"),
          ),
          DataColumn(
            label: Text("Performance"),
          ),
          DataColumn(
            label: Text("Cards"),
          ),
        ],
        rows: consolidatedList.map((res) =>
            DataRow(
              onSelectChanged: (bool selected){
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text("${DateFormat.yMd().add_jm().format(res.session)}"),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text("Performance: ${res.performance.toStringAsFixed(2)}%"),
                               Text("No. of Cards: ${res.totalCards}"),
                               SizedBox(height: 16.0),
                               for (var c in res.cards)
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Expanded(child: Text("${c.card.front}")),
                                     Text(c.score ? "◎" : "✘"),
                                   ],
                                 ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                );
              },
              cells: [
                DataCell(
                  Container(
                    child: Text("${DateFormat.yMd().add_jm().format(res.session)}"),
                    width: MediaQuery.of(context).size.width * 0.25,
                  ),
                ),
                DataCell(
                  Container(
                    child: Text("${res.performance.toStringAsFixed(2)}%"),
                    width: MediaQuery.of(context).size.width * 0.25,
                  ),
                ),
                DataCell(
                  Container(
                    child: Text("${res.totalCards}"),
                    width: MediaQuery.of(context).size.width * 0.25,
                  ),
                ),
              ]
            )
        ).toList(),
      ),
    );

  }

  generateChart(dynamic data){
    return [
      charts.Series<dynamic, DateTime>(
        id: 'Deck Performance',
        domainFn: (dynamic datum, _) => datum["session"],
        measureFn: (dynamic datum, _) => datum["performance"],
        data: data,
      )
    ];
  }

  @override
  void initState() {
    super.initState();
    widget.results.sort((a, b) => a.isoTimestamp.compareTo(b.isoTimestamp));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == "chart") {
      return charts.TimeSeriesChart(
        consolidate(),
        animate: false,

        behaviors: [
          // setting axis labels using charttitle
          charts.ChartTitle(
            "%",
            behaviorPosition: charts.BehaviorPosition.top,
            titleOutsideJustification: charts.OutsideJustification.start,
          ),
          charts.ChartTitle(
            "Date",
            behaviorPosition: charts.BehaviorPosition.bottom,
            titleOutsideJustification: charts.OutsideJustification.endDrawArea,
          ),
        ],

        // y-axis formatting
        primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec: charts.StaticNumericTickProviderSpec(
                [
                  charts.TickSpec(0),
                  charts.TickSpec(25),
                  charts.TickSpec(50),
                  charts.TickSpec(75),
                  charts.TickSpec(100),
                ]
            )
        ),

        //custom measure axis (increment by day)
        domainAxis: charts.EndPointsTimeAxisSpec(
          tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
            day: charts.TimeFormatterSpec(
                format: 'dd/MM', transitionFormat: 'dd/MM'
            ),
          ),
          showAxisLine: false,
        ),
      );
    } else {
      consolidate();
      return generateListTable();
    }
  }
}

class LineSeriesData {
  final DateTime chartUse;
  final DateTime session;
  final double performance;
  final int totalCards;
  final List<CardResult> cards;

  LineSeriesData(this.chartUse, this.session, this.performance, this.totalCards, this.cards);
}
