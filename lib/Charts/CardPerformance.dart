import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:memory_cards/Objects/objects.dart';

class CardPerformance extends StatefulWidget {
  final List<Result> results;
  String data;

  CardPerformance(this.results, this.data);

  @override
  _CardPerformanceState createState() => _CardPerformanceState();
}

class _CardPerformanceState extends State<CardPerformance> {
  List<dynamic> consolidatedList = [];
  bool _sorted = false;
  int _colInd = 0;
  var listResults;

  consolidate(BuildContext context){
    final consolidatedResults = Map();
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


    if (widget.data == "chart"){
      return generateChart(consolidatedResults);
    } else {
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

      return generateTable(context);
    }
  }

  sortFunction(int columnIndex, bool asc, String key){
    setState(() {
      _sorted = !_sorted;
      _colInd = columnIndex;
      if (_sorted) {
        consolidatedList.sort((a, b) => a[key].compareTo(b[key]));
      } else {
        consolidatedList.sort((a, b) => b[key].compareTo(a[key]));
      }
    });
  }

  generateTable(context){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        sortAscending: _sorted,
        sortColumnIndex: _colInd,
        columnSpacing: MediaQuery.of(context).size.width * 0.085,
        columns: [
          DataColumn(
            onSort: (columnIndex, ascending) =>
                sortFunction(columnIndex, ascending, "front"),
            label: Text('Front'),
          ),
          DataColumn(
            onSort: (columnIndex, ascending) =>
                sortFunction(columnIndex, ascending, "back"),
            label: Text('Back'),
          ),
          DataColumn(
            onSort: (columnIndex, ascending) =>
                sortFunction(columnIndex, ascending, "%"),
            label: Text('%'),
          ),
          DataColumn(
            onSort: (columnIndex, ascending) =>
                sortFunction(columnIndex, ascending, "score"),
            label: Text('Score'),
          ),
          DataColumn(
            onSort: (columnIndex, ascending) =>
                sortFunction(columnIndex, ascending, "tries"),
            label: Text('Tries'),
          ),
        ],
        rows: consolidatedList.map((res) =>
            DataRow(
              cells: [
                DataCell(Container(
                  child: Text("${res['front']}"),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),
                DataCell(Container(
                  child: Text("${res['back']}"),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),
                DataCell(Container(
                  child: Text("${res['%'].toStringAsFixed(2)}"),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),
                DataCell(Container(
                  child: Text("${res['score']}"),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),
                DataCell(Container(
                  child: Text("${res['tries']}"),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),
              ]
            )
        ).toList(),
            /*
            color: MaterialStateProperty.resolveWith((states){
              if (datum['%'] >= 75.0){
               return Colors.lightGreen.withOpacity(0.5);
              } else if (datum['%'] < 50.0) {
                return Colors.redAccent.withOpacity(0.5);
              } else {
                return Colors.yellow.withOpacity(0.5);
              }
            }),
             */
      ),
    );
  }

  generateChart(data){
    final List<Map<String, dynamic>> chartData = [
      {'domain': "Great", 'count': 0},
      {'domain': "Good", 'count': 0},
      {'domain': "Poor", 'count': 0},
    ];
    int totalCount = 0;

    for (var key in data.keys){
      if(data[key]['%'] >= 75.0) {
        chartData[0]['count']++;
      } else if (data[key]['%'] < 50.0) {
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
  Widget build(BuildContext context) {
    if (widget.data == "chart") {
      return charts.PieChart(
        consolidate(context),
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
      return consolidate(context);
    }
  }
}