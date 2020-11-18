import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studybuddy/Objects/objects.dart';

import '../Database.dart';

class DecksState extends ChangeNotifier{
  List<Deck> decks = [];

  List<DropdownMenuItem> get tagFilters{
    List<String> tags = [];
    for (var deck in decks){
      if(!tags.contains(deck.tag) && deck.tag != ""){
        tags.add(deck.tag);
      }
    }

    return tags.map<DropdownMenuItem<String>>(
            (String value) => DropdownMenuItem(
          value: value,
          child: Text(value),
        )
    ).toList();
  }

  void loadFromDatabase() async {
    var _decks = Map.fromIterable(await DBProvider.db.decks,
      key: (obj) => obj['deck_id'],
      value: (obj) => obj,
    );
    print("debug: $_decks");
    var _cQuery = await DBProvider.db.cards;

    Map<int, List<dynamic>> _cards = Map();
    for(dynamic c in _cQuery){
      if(_cards.containsKey(c['deck_id'])){
        _cards[c['deck_id']].add(c);
      } else {
        _cards[c['deck_id']] = [c];
      }
    }
    print("debug: $_cards");

    decks = _decks.keys.map((k) {
      print("bing: ${_decks[k]['deck_id']}");
      print("bong: ${_cards[_decks[k]['deck_id']]}");
      return Deck(
        _decks[k]['deck_id'],
        _decks[k]['deck_name'],
        _decks[k]['deck_tag'],
        // check for empty list
        _cards[_decks[k]['deck_id']] == null
          ? List<FlashCard>()
          : _cards[_decks[k]['deck_id']].map<FlashCard>(
                (f) => FlashCard(f['card_id'], f['front'], f['back'])
            ).toList(),
      );
    }).toList();

    notifyListeners();
  }

  void addCard({int deckId, FlashCard card}) async {
    await DBProvider.db.create("card", Map<String, dynamic>.from({
      'card_id': card.id,
      'deck_id': deckId,
      'front': card.front,
      'back': card.back,
    }));
    decks.firstWhere((d) => d.id == deckId).cards.add(card);
    notifyListeners();
  }

  void addDeck(Deck deck) async{
    decks.add(deck);
    await DBProvider.db.create(
      'deck',
      Map<String, dynamic>.from({
        'deck_id': deck.id,
        'deck_name': deck.name,
        'deck_tag': deck.tag,
      }),
    );

    for(FlashCard fc in deck.cards){
      await DBProvider.db.create('card',
        Map<String, dynamic>.from({
          'card_id': fc.id,
          'deck_id': deck.id,
          'front': fc.front,
          'back': fc.back,
        })
      );
    }

    notifyListeners();
  }

  Deck getDeckFromId(int id) => decks.firstWhere((d) => d.id == id);

  void removeCardFromId(int deckId, int cardId){
    decks.firstWhere((d) => d.id == deckId).cards.removeWhere((c) => c.id == cardId);
    DBProvider.db.delete("card", "card_id = ?", [cardId]);

    notifyListeners();
  }
}