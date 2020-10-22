import 'package:flutter/material.dart';
import 'package:studybuddy/Database.dart';

import '../Objects/objects.dart';

class ResultsState extends ChangeNotifier {
  List<Result> results = [];

  void loadFromDatabase() async {
    var _results = await DBProvider.db.results;
    var _cardresults = await DBProvider.db.cardresults;
    var _cards = await DBProvider.db.cards;

    results = _results.map<Result>((r) {
      return Result(
        r['result_id'],
        r['datetime'],
        r['deck_id'],
        _cardresults
            .where((cr) => cr['result_id'] == r['result_id'])
            .map<CardResult>((cr) => CardResult(
              cr['cr_id'],
              FlashCard(
                cr['card_id'],
                _cards.firstWhere((c) => c['card_id'] == cr['card_id'])['front'],
                _cards.firstWhere((c) => c['card_id'] == cr['card_id'])['back'],
              ),
              cr['score'] == 1 ? true : false,
            ))
            .toList(),
      );
    }).toList();

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
            'cr_id': cr.id,
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
