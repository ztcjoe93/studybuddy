import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:memory_cards/Objects/objects.dart';

class CardPerformance extends StatelessWidget {
  final List<Result> results;
  String data;
  var listResults;

  CardPerformance(this.results, this.data);

  // consolidate all card results
  consolidate(BuildContext context){
    final consolidatedResults = Map();
    // iterate over each card in result
    for (var result in results){
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

    var consolidatedList = [];

    if (data == "chart"){
      return generateChart(consolidatedResults);
    } else {
      consolidatedResults.forEach((key, value){
        consolidatedList.add({
          'front': key,
          'back': value['back'],
          '%': value['%'],
          'score': value['score'],
          'tries': value['count'],
        });
      });
      
      return generateTable(consolidatedList, context);
    }
  }

  generateTable(data, context){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columnSpacing: MediaQuery.of(context).size.width * 0.085,
        columns: [
          DataColumn(label: Text('Front')),
          DataColumn(label: Text('Back')),
          DataColumn(label: Text('%')),
          DataColumn(label: Text('Score')),
          DataColumn(label: Text('Tries')),
        ],
        rows: [
          for(var datum in data)
          DataRow(
            color: MaterialStateProperty.resolveWith((states){
              if (datum['%'] >= 75.0){
               return Colors.lightGreen.withOpacity(0.5);
              } else if (datum['%'] < 50.0) {
                return Colors.redAccent.withOpacity(0.5);
              } else {
                return Colors.yellow.withOpacity(0.5);
              }
            }),
            cells: [
              DataCell(Container(
                child: Text("${datum['front']}"),
                width: MediaQuery.of(context).size.width * 0.1,
              )),
              DataCell(Container(
                child: Text("${datum['back']}"),
                width: MediaQuery.of(context).size.width * 0.1,
              )),
              DataCell(Container(
                child: Text("${datum['%'].toStringAsFixed(2)}"),
                width: MediaQuery.of(context).size.width * 0.1,
              )),
              DataCell(Container(
                child: Text("${datum['score']}"),
                width: MediaQuery.of(context).size.width * 0.1,
              )),
              DataCell(Container(
                child: Text("${datum['tries']}"),
                width: MediaQuery.of(context).size.width * 0.1,
              )),
            ],
          ),
        ],
      ),
    );
  }

  generateChart(data){
    final chartData = [
      {'domain': 0, 'count': 0},
      {'domain': 1, 'count': 0},
      {'domain': 2, 'count': 0},
    ];

    for (var key in data.keys){
      if(data[key]['%'] >= 75.0) {
        chartData[0]['count']++;
      } else if (data[key]['%'] < 50.0) {
        chartData[2]['count']++;
      } else {
        chartData[1]['count']++;
      }
    }

    chartData.removeWhere((element) => element['count'] == 0);

    return [
      charts.Series<dynamic, int>(
        id: 'Card Performance',
        domainFn: (dynamic datum, _) => datum['domain'],
        measureFn: (dynamic datum, _) => datum['count'],
        labelAccessorFn: (dynamic datum, _){
          return datum['domain'] == 0
              ? "Great"
              : datum['domain'] == 1 ? "Good" : "Poor";
        },
        data: chartData,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (data == "chart") {
      return charts.PieChart(
        consolidate(context),
        animate: false,
        defaultRenderer: charts.ArcRendererConfig(
            arcRendererDecorators: [charts.ArcLabelDecorator()]
        ),
      );
    } else if (data == "list") {
      return consolidate(context);
    }
  }
}