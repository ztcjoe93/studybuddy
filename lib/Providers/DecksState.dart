import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memory_cards/Deck/CardsManagement.dart';
import 'package:memory_cards/Deck/ModifyCard.dart';
import 'package:memory_cards/Providers/ResultsState.dart';
import 'package:memory_cards/Revision/RevisionSession.dart';
import 'package:memory_cards/Objects/objects.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../Database.dart';

class DecksState extends ChangeNotifier{
  List<Deck> _decks = [];

  // for deck management use; ontap brings to card management view
  Widget get deckManagementView => Scrollbar(
    child: ListView.separated(
      itemCount: _decks.length,
      itemBuilder: (BuildContext context, int index) => ListTile(
        onTap: (){
          manageCards(context, _decks, index);
        },
        title: Text("${_decks[index].name}"),
        subtitle: Text("${_decks[index].tag}"),
      ),
      separatorBuilder: (BuildContext context, int index) => Divider(),
    ),
  );

  Widget deckManagementViewFiltered(String tag){
    List<Deck> filtered = _decks.where((deck) => deck.tag == tag).toList();
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) => ListTile(
        onTap: () => manageCards(context, filtered, index),
        title: Text("${filtered[index].name}"),
        subtitle: Text("${filtered[index].tag}"),
      ),
      separatorBuilder: (_, __) => Divider(),
      itemCount: filtered.length,
    );
  }

  // for card management use;
  void manageCards(BuildContext context, List<Deck> decks, int index) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CardsManagement(decks[index]),
        transitionDuration: Duration(seconds: 0),
      ),
    );

    // delete deck confirmation received from PageRoute
    if (result == false){
      // remove any relevant results associated with deckName
      Provider.of<ResultsState>(context, listen: false).remove(_decks[index].name);
      Provider.of<DecksState>(context, listen: false).remove(_decks[index]);
    }
  }

  void updateCard(BuildContext context, Deck deck, int index) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ModifyCard(deck.cards[index]),
        transitionDuration: Duration(seconds: 0),
      ),
    );

    if (result != null){
      deck.cards[index] = result;
      Provider.of<DecksState>(context, listen: false).update(deck);
    }
  }

  Widget cardManagementView(BuildContext context, Deck deck){
    if(deck.cards.length == 0){
      return Text("You have no cards in this deck!");
    }
    return Scrollbar(
      child: ListView.separated(
        itemCount: deck.cards.length,
        itemBuilder: (BuildContext context, int index) => Card(
          child: ListTile(
            onTap: () => updateCard(context, deck, index),
            title: Text("${deck.cards[index].front}"),
            subtitle: Text("${deck.cards[index].back}"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    content: Text("Are you sure you wish to delete this card?"),
                    actions: [
                      FlatButton(
                        child: Text("Yes"),
                        onPressed: (){
                          DBProvider.db.removeCard(deck, deck.cards[index]);
                          deck.cards.removeAt(index);
                          notifyListeners();
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("No"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  )
                );
              },
            ),
          ),
        ),
        separatorBuilder: (BuildContext context, int index) => Divider(),
      ),
    );
  }

  // for revision use; ontap brings to start of revision
  Widget get revisionView {
    List<Deck> availableDecks = _decks.where((deck) => deck.cards.length != 0).toList();

    return ListView.builder(
      itemCount: availableDecks.length,
      itemBuilder: (BuildContext context, int index) =>
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => RevisionSession(availableDecks[index]),
                  transitionDuration: Duration(seconds: 0),
                ));
              },
              title: Text("${availableDecks[index].name}"),
              subtitle: Text("${availableDecks[index].tag}"),
            ),
          ),
    );
  }

  Widget revisionViewFiltered(String tag){
    List<Deck> filtered = _decks.where(
            (deck) => deck.tag == tag && deck.cards.length != 0
    ).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (BuildContext context, int index) => Card(
        child: ListTile(
          onTap: (){
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => RevisionSession(filtered[index]),
              transitionDuration: Duration(seconds: 0),
            ));
          },
          title: Text("${filtered[index].name}"),
          subtitle: Text("${filtered[index].tag}"),
        ),
      ),
    );
  }

  List<DropdownMenuItem> get tagFilters{
    List<String> tags = [];
    for (var deck in _decks){
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

  void writeToDb(Deck deck) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), "study_buddy.db"),
    );

    await db.insert(
     "decks",
     {
       'deck_name': deck.name,
       'deck_tag': deck.tag,
     },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("Completed inserting ${deck.name} into `decks` table.");

    int deckId = await db.rawQuery(
      'SELECT `deck_id` FROM decks WHERE deck_name = "${deck.name}"'
    ).then((value) => value[0]['deck_id']);

    await Future.forEach(deck.cards, (cardo) async{
      await db.insert(
        "cards",
        {
          'deck_id': deckId,
          'front': cardo.front,
          'back': cardo.back,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("Completed inserting ${cardo.front} into `cards` table.");
    });
  }

  void update(Deck deck){
    for (var _deck in _decks){
      if (_deck.name == deck.name){
        _deck = deck;
        notifyListeners();
      }
    }
  }

  dbLoad() async {
    var tefuda = await DBProvider.db.decks;
    var kaado = await DBProvider.db.cards;

    _decks = tefuda.map<Deck>((dekki) =>
        Deck(
          dekki['deck_name'],
          dekki['deck_tag'],
          kaado
              .where(
                  (tanpin) => tanpin['deck_id'] == dekki['deck_id'])
              .toList()
              .map<FlashCard>(
                  (filter) => FlashCard(filter['front'], filter['back']))
              .toList(),
        )
    ).toList();

    notifyListeners();
  }

  addCard(Deck deck, FlashCard card) async {
    await DBProvider.db.insertCard(deck, [card]);

    notifyListeners();
  }


  add(Deck deck) async{
    _decks.add(deck);

    await DBProvider.db.insertDeck(deck);
    await DBProvider.db.insertCard(deck, deck.cards);

    notifyListeners();
  }

  remove(Deck deck){
    _decks.removeWhere((e) => e.name == deck.name);
    DBProvider.db.removeDeck(deck);

    notifyListeners();
  }
}