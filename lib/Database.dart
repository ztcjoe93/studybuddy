import 'dart:async';

import 'package:memory_cards/Objects/objects.dart';
import 'package:memory_cards/Providers/DecksState.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database == null){
      _database = await initDB();
    }
    return _database;
  }

  get results async {
    return await _database.query("result");
  }

  get decks async {
    return await _database.query("decks");
  }

  get cards async {
    return await _database.query("cards");
  }

  insertDeck(Deck deck){
    _database.insert(
      "decks",
      {
        'deck_name': deck.name,
        'deck_tag': deck.tag,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("Inserted ${deck.name} into `decks` table");
  }

  insertResult(Result result) async{
    int deckId = await _database.rawQuery('''
      SELECT `deck_id` FROM decks WHERE deck_name = "${result.deckName}"
    ''').then((value) => value[0]['deck_id']);

    for (CardResult res in result.results){
      int cardId = await _database.rawQuery('''
        SELECT `card_id` FROM `cards` WHERE `deck_id` = $deckId AND `front` = "${res.card.front}"
      ''').then((value) => value[0]['card_id']);

      _database.insert(
          "result",
          {
            'datetime': result.isoTimestamp,
            'deck_id': deckId,
            'card_id': cardId,
            'score': res.score ? 1 : 0,
          }
      );

      print("Inserted ${res.card.front} into `cards` table");
    }
  }

  updateCard(Deck deck, int cardId) async {
  }

  insertCard(Deck deck, List<FlashCard> cards) async {
    int deckId = await _database.rawQuery('''
      SELECT `deck_id` FROM decks WHERE deck_name = "${deck.name}"
    ''').then((value) => value[0]['deck_id']);

    //https://api.dart.dev/stable/2.9.1/dart-async/Future/forEach.html
    cards.forEach((fc) {
        _database.insert(
          "cards",
          {
            'deck_id': deckId,
            'front': fc.front,
            'back': fc.back,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print("Inserted ${fc.front} into `cards` table");
      }
    );
  }

  removeCard(Deck deck, FlashCard card) async {
    int deck_id = await _database.rawQuery(
        "SELECT `deck_id` FROM decks WHERE deck_name = '${deck.name}'"
    ).then((value) => value[0]['deck_id']);

    _database.delete(
      "cards",
      where: 'deck_id = ? AND front = ?',
      whereArgs: [deck_id, card.front],
    );

    print("Successfully deleted ${card.front} from the `cards` table.");
  }

  removeDeck(Deck deck) {
    _database.delete(
      "decks",
      where: 'deck_name = ?',
      whereArgs: [deck.name],
    );
    print("Successfully deleted ${deck.name} from the `decks` table.");
  }

  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), "study_buddy.db"),
      // create relevant databases if it's an initial launch
      onCreate: (db, version){
        databaseCreation(db);
      },
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      version: 1,
    );
  }

  databaseCreation(db) {
    db.execute('''
    CREATE TABLE decks(
      deck_id INTEGER PRIMARY KEY,
      deck_name TEXT NOT NULL UNIQUE,
      deck_tag TEXT
  )''');

    db.execute('''
    CREATE TABLE cards(
      card_id INTEGER PRIMARY KEY,
      deck_id INTEGER NOT NULL,
      front TEXT NOT NULL,
      back TEXT NOT NULL,
      UNIQUE(deck_id, front),
      FOREIGN KEY (deck_id)
        REFERENCES decks(deck_id)
          ON DELETE CASCADE
  )''');

    db.execute('''
    CREATE TABLE result(
     result_id INTEGER PRIMARY KEY,
     datetime TEXT NOT NULL,
     deck_id INTEGER NOT NULL,
     card_id INTEGER NOT NULL,
     score INTEGER NOT NULL CHECK (score IN (0,1)),
     FOREIGN KEY (deck_id)
      REFERENCES decks(deck_id)
        ON DELETE CASCADE,
     FOREIGN KEY (card_id)
      REFERENCES cards(card_id)
        ON DELETE CASCADE
  )''');
  }
}



