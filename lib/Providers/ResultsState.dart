import 'package:flutter/material.dart';
import 'package:studybuddy/Database.dart';

import '../Objects/objects.dart';

class ResultsState extends ChangeNotifier {
  List<Result> results = [];

  void loadFromDatabase() async {
    var _results = await DBProvider.db.results;
    var _crQuery = await DBProvider.db.cardresults;

    Map<int, List<dynamic>> _cardresults = Map();
    for(dynamic cr in _crQuery){
      if(_cardresults.containsKey(cr['result_id'])){
        _cardresults[cr['result_id']].add(cr);
      } else {
        _cardresults[cr['result_id']] = [cr];
      }
    }

    Map<int, dynamic> _cards = Map.fromIterable(await DBProvider.db.cards,
      key: (obj) => obj['card_id'],
      value: (obj) => obj,
    );

    results = _results.map<Result>((r) {
      return Result(
        r['result_id'],
        r['datetime'],
        r['deck_id'],
        _cardresults[r['result_id']]
            .map<CardResult>((cr) => CardResult(
              cr['cr_id'],
              FlashCard(
                cr['card_id'],
                _cards[cr['card_id']]['front'],
                _cards[cr['card_id']]['back'],
              ),
              cr['score'] == 1 ? true : false,
            ))
            .toList(),
      );
    }).toList();

    print("Finish loading from database for ResultsState.");
    notifyListeners();
  }

  writeToDb(Result result) async {
    await DBProvider.db.create(
      'result',
      Map<String, dynamic>.from({
        'result_id': result.id,
        'datetime': result.isoTimestamp,
        'deck_id': result.deckId,
      })
    );

    for(CardResult cr in result.results){
      await DBProvider.db.create(
          'cardresult',
          Map<String, dynamic>.from({
            'cr_id': await DBProvider.db.getNewRow('cardresult'),
            'result_id': result.id,
            'card_id': cr.card.id,
            'score': cr.score ? 1 : 0,
          })
      );
    }

    notifyListeners();
  }

  void add(Result result){
    results.add(result);
    writeToDb(result);
    notifyListeners();
  }

  void remove(int deckId){
    results.removeWhere((r) => r.deckId == deckId);
    DBProvider.db.delete('deck', 'deck_id = ?', [deckId]);
    notifyListeners();
  }
}
