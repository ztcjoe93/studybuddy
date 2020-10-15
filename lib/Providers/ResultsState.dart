import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:studybuddy/Charts/CardPerformance.dart';
import 'package:studybuddy/Charts/DeckPerformance.dart';
import 'package:studybuddy/Database.dart';
import 'package:path_provider/path_provider.dart';

import '../Objects/objects.dart';

class ResultsState extends ChangeNotifier {
  List<Result> results = [];
  String _selectedDeck;
  int _selected;


  int get deckIndex => _selected;


  Widget get generateLineChart => DeckPerformance(
    results.where((d) => d.deckName == _selectedDeck).toList(),
    "chart",
  );

  Widget get generatePieChart => CardPerformance(
    results.where((d) => d.deckName == _selectedDeck).toList(),
    "chart",
  );

  Widget generatePieChartTable(BuildContext context){
    return CardPerformance(
      results.where((d) => d.deckName == _selectedDeck).toList(),
      "list",
    );
  }

  Widget generateLineChartTable(BuildContext context){
    return DeckPerformance(
      results.where((d) => d.deckName == _selectedDeck).toList(),
      "list",
    );
  }

  selectedText(BuildContext context){
    if(_selected != null){
      return Center(
        child: Text(
          "$_selectedDeck is selected.",
          style: Theme.of(context).textTheme.headline5,
        ),
      );
    } else {
      return Center(
        child: Text(
          "Select a deck",
          style: Theme.of(context).textTheme.headline5,
        ),
      );
    }
  }

  Widget selection(){
    if(results.length == 0){
      return Text("Empty");
    } else {
      // get only unique deck names
      List<String> deckNames = [];

      for (var result in results){
        if(!deckNames.contains(result.deckName)){
          deckNames.add(result.deckName);
        }
      }

      return Expanded(
        child: ListView.builder(
          itemCount: deckNames.length,
          itemBuilder: (BuildContext context, int index) => Container(
            decoration: BoxDecoration(
              color: _selected == index ? Colors.red : Colors.transparent,
            ),
            child: ListTile(
              onTap: (){
                _selected = _selected == null
                    ? index
                    : _selected == index ? null : index;
                if (_selected == null){
                  _selectedDeck = null;
                } else {
                  _selectedDeck = deckNames[_selected];
                }
                notifyListeners();
              },
              title: Text(deckNames[index]),
            ),
          ),
        ),
      );
    }
  }

  writeToDb(Result result) async {
    DBProvider.db.insertResult(result);
    notifyListeners();
  }

  void add(Result result){
    results.add(result);
    writeToDb(result);
    notifyListeners();
  }

  void remove(String deckName){
    results.removeWhere((r) => r.deckName == deckName);
    notifyListeners();
  }
}
