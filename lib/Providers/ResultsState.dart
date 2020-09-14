import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../objects.dart';

class ResultsState extends ChangeNotifier {
  List<Result> results = [];

  void loadFromFile(Result result){
    results.add(result);
    notifyListeners();
  }

  void writeToFile(List<Result> results) async{
    var modified = [];

    for (var result in results){
      modified.add(result.toJson());
    }
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/results/data");
    file.writeAsString(jsonEncode(modified));
  }

  void add(Result result){
    results.add(result);
    writeToFile(results);
    notifyListeners();
  }
}
