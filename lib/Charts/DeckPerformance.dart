import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
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
  bool _chartGenerated = false;

  consolidate(String type) async {
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

    return type == "chart"
        ? generateChart(dateList)
        : generateListTable();
  }

  generateListTable(){
    return ListView.separated(
      itemCount: consolidatedList.length,
      itemBuilder: (BuildContext context, int index){
        return InkWell(
          onTap: (){
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                SimpleDialog(
                  title: Text("${DateFormat.yMd().add_jm().format(consolidatedList[index].session)}"),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Performance: ${consolidatedList[index].performance.toStringAsFixed(2)}%"),
                          Text("No. of Cards: ${consolidatedList[index].totalCards}"),
                          SizedBox(height: 16.0),
                          for (var c in consolidatedList[index].cards)
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
                ));
            },
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                            "${DateFormat.yMd()
                                .add_jm()
                                .format(consolidatedList[index].session)
                            }"
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("${consolidatedList[index].performance.toStringAsFixed(2)}"),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text("${consolidatedList[index].totalCards}"),
                      ),
                    ],
                  ),
                  //const Divider(height: 16.0, thickness: 1.0),
                ],
              ),
            ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  generateChart(dynamic data){
    setState(() {
      _chartGenerated = true;
    });
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
      return FutureBuilder(
        future: consolidate("chart"),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return snapshot.hasData
            ?  charts.TimeSeriesChart(
                snapshot.data,
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
              )
            : Center(
                child: CircularProgressIndicator(),
              );
        }
      );
    } else {
      return FutureBuilder(
        future: consolidate("list"),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return snapshot.hasData
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text("Date/time"),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text("Performance (%)"),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text("Cards"),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
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
                            child: snapshot.data,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator());
        },
      );
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
