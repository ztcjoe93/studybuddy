import 'dart:async';

import 'package:studybuddy/Objects/objects.dart';
import 'package:studybuddy/Providers/DecksState.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database database;

  get results async => await database.query("result");
  get decks async => await database.query("deck");
  get cards async => await database.query("card");

  create(String tableName, Map items) async {
    return await database.insert(
      tableName,
      items,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  read(String tableName, {String where, List<dynamic> whereArgs}) async {
    return await database.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }

  update(String tableName, Map items, String where, List<dynamic> whereArgs) async {
    return await database.update(
      tableName,
      items,
      where: where,
      whereArgs: whereArgs,
    );
  }

  delete(String tableName, String where, List<dynamic> whereArgs) async {
    return await database.delete(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }


  insertDeck(Deck deck){
    database.insert(
      "deck",
      {
        'deck_name': deck.name,
        'deck_tag': deck.tag,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("Inserted ${deck.name} into `deck` table");
  }

  insertResult(Result result) async{
    int deckId = await database.rawQuery('''
      SELECT `deck_id` FROM deck WHERE deck_name = "${result.deckName}"
    ''').then((value) => value[0]['deck_id']);

    for (CardResult res in result.results){
      int cardId = await database.rawQuery('''
        SELECT `card_id` FROM `card` WHERE `deck_id` = $deckId AND `front` = "${res.card.front}"
      ''').then((value) => value[0]['card_id']);

      database.insert(
          "result",
          {
            'datetime': result.isoTimestamp,
            'deck_id': deckId,
            'card_id': cardId,
            'score': res.score ? 1 : 0,
          }
      );

      print("Inserted ${res.card.front} into `card` table");
    }
  }

  updateCard(Deck deck, FlashCard card) async {
    int deckId = await database.rawQuery('''
      SELECT `deck_id` FROM deck WHERE deck_name = "${deck.name}"
    ''').then((value) => value[0]['deck_id']);

    int cardId = await database.rawQuery('''
      SELECT `card_id` FROM card WHERE deck_id = "$deckId" AND front = "${card.front}"
    ''').then((val)=> val[0]['card_id']);

    await database.rawUpdate(
      'UPDATE `card` SET front = ? AND back = ? WHERE card_id = ?',
      [card.front, card.back, cardId],
    );
  }

  insertCard(Deck deck, List<FlashCard> cards) async {
    int deckId = await database.rawQuery('''
      SELECT `deck_id` FROM deck WHERE deck_name = "${deck.name}"
    ''').then((value) => value[0]['deck_id']);

    //https://api.dart.dev/stable/2.9.1/dart-async/Future/forEach.html
    cards.forEach((fc) {
        database.insert(
          "card",
          {
            'deck_id': deckId,
            'front': fc.front,
            'back': fc.back,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print("Inserted ${fc.front} into `card` table");
      }
    );
  }

  removeCard(Deck deck, FlashCard card) async {
    int deck_id = await database.rawQuery(
        "SELECT `deck_id` FROM deck WHERE deck_name = '${deck.name}'"
    ).then((value) => value[0]['deck_id']);

    database.delete(
      "card",
      where: 'deck_id = ? AND front = ?',
      whereArgs: [deck_id, card.front],
    );

    print("Successfully deleted ${card.front} from the `card` table.");
  }

  removeDeck(Deck deck) {
    database.delete(
      "deck",
      where: 'deck_name = ?',
      whereArgs: [deck.name],
    );
    print("Successfully deleted ${deck.name} from the `deck` table.");
  }

  initializeDatabase() async {
    if (database == null){
      database = await openDatabase(
        join(await getDatabasesPath(), "study_buddy.db"),
        // create relevant databases if it's an initial launch
        onCreate: (Database db, int version) => databaseCreation(db),
        // to allow foreign key referencing
        onConfigure: (Database db) async => await db.execute("PRAGMA foreign_keys = ON"),
        version: 1,
      );
    }
    return database;
  }

  databaseCreation(Database db) {
    db.execute('''
    CREATE TABLE deck(
      deck_id INTEGER PRIMARY KEY,
      deck_name TEXT NOT NULL UNIQUE,
      deck_tag TEXT
    )''');

    db.execute('''
    CREATE TABLE card(
      card_id INTEGER PRIMARY KEY,
      deck_id INTEGER NOT NULL,
      front TEXT NOT NULL,
      back TEXT NOT NULL,
      UNIQUE(deck_id, front),
      FOREIGN KEY (deck_id)
        REFERENCES deck(deck_id)
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
      REFERENCES deck(deck_id)
        ON DELETE CASCADE,
     FOREIGN KEY (card_id)
      REFERENCES card(card_id)
        ON DELETE CASCADE
     )''');
  }
}



