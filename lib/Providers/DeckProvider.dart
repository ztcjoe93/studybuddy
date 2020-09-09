import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memory_cards/CardsManagement.dart';
import 'package:memory_cards/objects.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DecksState extends ChangeNotifier{
  final List<Deck> _decks = [];

  // for deck management use; ontap brings to card management view
  Widget get deckManagementView => ListView.separated(
    itemCount: _decks.length,
    itemBuilder: (BuildContext context, int index) => ListTile(
      onTap: (){
        manageCards(context, index);
      },
      title: Text("${_decks[index].name}"),
      subtitle: Text("${_decks[index].tag}"),
    ),
    separatorBuilder: (BuildContext context, int index) => Divider(),
  );

  void manageCards(BuildContext context, int index) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CardsManagement(_decks[index]),
        transitionDuration: Duration(seconds: 0),
      ),
    );

    // delete deck confirmation received from PageRoute
    if (result == false){
      Provider.of<DecksState>(context, listen: false).remove(_decks[index]);
    }
  }

  Widget cardManagementView(BuildContext context, Deck deck){
    return ListView.separated(
      itemCount: deck.cards.length,
      itemBuilder: (BuildContext context, int index) => Card(
        child: ListTile(
          title: Text("${deck.cards[index].front}"),
          subtitle: Text("${deck.cards[index].back}"),
        ),
      ),
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  // for revision use; ontap brings to start of revision
  Widget get revisionView => ListView.builder(
    itemCount: _decks.length,
    itemBuilder: (BuildContext context, int index) => ListTile(
      title: Text("${_decks[index].name}"),
      subtitle: Text("${_decks[index].tag}"),
    ),
  );

  void writeToFile(Deck deck) async{
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/decks/${deck.name}");
    file.writeAsString(jsonEncode(deck.toJson()));
    print("I/O operations complete.");
  }

  void deleteFromFile(Deck deck) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/decks/${deck.name}");
    file.deleteSync();
    print("I/O operations complete.");
  }

  int get deckCount => _decks.length;

  void add(Deck deck){
    _decks.add(deck);
    writeToFile(deck);
    notifyListeners();
  }

  void remove(Deck deck){
    _decks.removeWhere((e) => e.name == deck.name);
    deleteFromFile(deck);
    notifyListeners();
  }
}