import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database database;

  get decks async => await database.query("deck");
  get cards async => await database.query("card");
  get results async => await database.query("result");
  get cardresults async => await database.query("cardresult");

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

  getNewRow(String tableName) async{
    Map<String, String> tablePk = {
      'deck': 'deck_id',
      'card': 'card_id',
      'result': 'result_id',
      'cardresult': 'cr_id',
    };

    List<Map> results = await database.rawQuery("SELECT MAX(${tablePk[tableName]}) AS lastRow FROM $tableName");

    return results[0]['lastRow'] == null
        ? 1 : results[0]['lastRow']+1;
  }

  initializeDatabase() async {
    if (database == null){
      print("Initializing database...");
      database = await openDatabase(
        join(await getDatabasesPath(), "study_buddy.db"),
        // create relevant databases if it's an initial launch
        onCreate: (Database db, int version) => databaseCreation(db),
        // to allow foreign key referencing
        onConfigure: (Database db) async => await db.execute("PRAGMA foreign_keys = ON"),
        version: 1,
      );
    }
    print("Initialization completed.");
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
     FOREIGN KEY (deck_id)
      REFERENCES deck(deck_id)
        ON DELETE CASCADE
     )''');

    db.execute('''
    CREATE TABLE cardresult(
     cr_id INTEGER PRIMARY KEY,
     result_id INTEGER NOT NULL,
     card_id INTEGER NOT NULL,
     score INTEGER NOT NULL CHECK (score IN (0,1)),
     FOREIGN KEY (result_id)
      REFERENCES result(result_id)
        ON DELETE CASCADE,
     FOREIGN KEY (card_id)
      REFERENCES card(card_id)
        ON DELETE CASCADE
    )''');
  }
}
