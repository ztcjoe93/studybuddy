import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studybuddy/Providers/OverallState.dart';
import 'package:studybuddy/Utilities.dart';

import '../Objects/objects.dart';

class DeckPerformance extends StatefulWidget {
  List<Result> results;
  String data;

  DeckPerformance(this.results, this.data);

  @override
  _DeckPerformanceState createState() => _DeckPerformanceState();
}

class _DeckPerformanceState extends State<DeckPerformance> {
  List<dynamic> consolidatedList = [];
  bool _chartGenerated = false;

  consolidate(String type) async {
    widget.results.sort((a, b) => a.isoTimestamp.compareTo(b.isoTimestamp));
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
                  title: Text(
                    "${DateFormat.yMd().add_jm().format(consolidatedList[index].session)}",
                    style: TextStyle(
                      fontSize: mqsWidth(context, 0.05),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Performance: ${consolidatedList[index].performance.toStringAsFixed(2)}%",
                            style: TextStyle(
                              fontSize: mqsWidth(context, 0.035),
                            ),
                          ),
                          Text(
                            "No. of Cards: ${consolidatedList[index].totalCards}",
                            style: TextStyle(
                              fontSize: mqsWidth(context, 0.035),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          for (var c in consolidatedList[index].cards)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${c.card.front}",
                                    style: TextStyle(
                                      fontSize: mqsWidth(context, 0.035),
                                    ),
                                  ),
                                ),
                                Text(
                                  c.score ? "◎" : "✘",
                                  style: TextStyle(
                                    fontSize: mqsWidth(context, 0.035),
                                  ),
                                ),
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
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${DateFormat.yMd()
                                .add_jm()
                                .format(consolidatedList[index].session)
                            }",
                            style: TextStyle(
                              fontSize: mqsWidth(context, 0.035),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "${consolidatedList[index].performance.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: mqsWidth(context, 0.035),
                            ),
                          ),
                        ),
                        Text(
                          "${consolidatedList[index].totalCards}",
                          style: TextStyle(
                            fontSize: mqsWidth(context, 0.035),
                          ),
                        ),
                      ],
                    ),
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
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.blueGrey[200]),
        domainFn: (dynamic datum, _) => datum["session"],
        measureFn: (dynamic datum, _) => datum["performance"],
        data: data,
      )
    ];
  }

  @override
  void initState() {
    super.initState();
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
                defaultInteractions: false,
                behaviors: [
                  // setting axis labels using charttitle
                  charts.ChartTitle(
                    "%",
                    behaviorPosition: charts.BehaviorPosition.top,
                    titleOutsideJustification: charts.OutsideJustification.start,
                    titleStyleSpec: charts.TextStyleSpec(
                      color: Provider.of<OverallState>(context, listen: false).darkMode
                          ? charts.MaterialPalette.white : charts.MaterialPalette.black,
                      fontSize: mqsWidth(context, 0.025).toInt(),
                    ),
                  ),
                  charts.ChartTitle(
                    "Date",
                    behaviorPosition: charts.BehaviorPosition.bottom,
                    titleOutsideJustification: charts.OutsideJustification.endDrawArea,
                    titleStyleSpec: charts.TextStyleSpec(
                      color: Provider.of<OverallState>(context, listen: false).darkMode
                          ? charts.MaterialPalette.white : charts.MaterialPalette.black,
                      fontSize: mqsWidth(context, 0.025).toInt(),
                    ),
                  ),
                ],
                // y-axis formatting
                primaryMeasureAxis: charts.NumericAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                    lineStyle: charts.LineStyleSpec(
                      color: Provider.of<OverallState>(context, listen: true).darkMode
                          ? charts.MaterialPalette.white.darker.darker.darker
                          : charts.MaterialPalette.gray.shade300,
                    ),
                    labelStyle: charts.TextStyleSpec(
                      fontSize: mqsWidth(context, 0.025).toInt(),
                      color: Provider.of<OverallState>(context, listen: false).darkMode
                          ? charts.MaterialPalette.white : charts.MaterialPalette.black,
                    ),
                  ),
                  tickProviderSpec: charts.StaticNumericTickProviderSpec(
                      [
                        charts.TickSpec(0),
                        charts.TickSpec(25),
                        charts.TickSpec(50),
                        charts.TickSpec(75),
                        charts.TickSpec(100),
                      ]
                  ),
                ),

                //custom measure axis (increment by day)
                domainAxis: charts.EndPointsTimeAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                    lineStyle: charts.LineStyleSpec(
                      color: Provider.of<OverallState>(context, listen: true).darkMode
                        ? charts.MaterialPalette.white.darker.darker.darker
                        : charts.MaterialPalette.gray.shade300,
                    ),
                    labelStyle: charts.TextStyleSpec(
                      fontSize: mqsWidth(context, 0.025).toInt(),
                      color: Provider.of<OverallState>(context, listen: false).darkMode
                        ? charts.MaterialPalette.white : charts.MaterialPalette.black,
                    ),
                  ),
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
          if (snapshot.hasData) {
            return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            child: Text(
                              "Date/time",
                              style: TextStyle(
                                fontSize: mqsWidth(context, 0.035)
                              ),
                            ),
                          ),
                          FittedBox(
                              child: Text(
                                "Performance (%)",
                                style: TextStyle(
                                    fontSize: mqsWidth(context, 0.035)
                                ),
                              )
                          ),
                          FittedBox(
                              child: Text(
                                "Cards",
                                style: TextStyle(
                                    fontSize: mqsWidth(context, 0.035)
                                ),
                              ),
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
                );
          } else {
            return Center(child: CircularProgressIndicator());
          }
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
