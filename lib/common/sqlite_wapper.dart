import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'logger.dart';

class SqliteWrapper {

  static Future<void> clearAutologinInfo() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'userinfo.db');

    Database? database;
    try {
      // open the database
      database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            // When creating the db, create the table
            await db.execute(
                'CREATE TABLE Userinfo (id TEXT PRIMARY KEY, password TEXT)');
          });

      await database.rawDelete('DELETE FROM Userinfo');
      await database.close();
    } catch (e) {
      await database?.close();
      // 문제발생시 DB초기화(삭제)
      deleteDB();
    }
  }

  static Future<void> deleteDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'userinfo.db');
    try {
      await deleteDatabase(path);
    } catch (e) {
      logger.warning('deleteDatabase($path) ERROR !!!');
    }
  }

  static Future<void> setAutologinInfo(String userId, String password) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'userinfo.db');

    Database? database;
    try {
      // open the database
      database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            // When creating the db, create the table
            await db.execute(
                'CREATE TABLE Userinfo (id TEXT PRIMARY KEY, password TEXT)');
          });

      await database.rawDelete('DELETE FROM Userinfo');
      await database.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO Userinfo(id, password) VALUES("$userId", "$password")');
      });
      await database.close();
    } catch (e) {
      await database?.close();
      // 문제발생시 DB초기화(삭제)
      deleteDB();
    }
  }

  static Future<Map<String, String>> getAutologinInfo() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'userinfo.db');

    Database? database;
    try {
      // open the database
      database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
            // When creating the db, create the table
            await db.execute(
                'CREATE TABLE Userinfo (id TEXT PRIMARY KEY, password TEXT)');
          });

      List<Map> list = await database.rawQuery('SELECT * FROM Userinfo');
      for(var row in list) {
        Map<String, String> rowMap = Map<String, String>.from(row);
        String userId = rowMap['id'] ?? '';
        String password = rowMap['password'] ?? '';
        await database.close();
        return {"userId": userId, "password" : password};
      }

      await database.close();
    } catch (e) {
      await database?.close();
      // 문제발생시 DB초기화(삭제)
      deleteDB();
    }

    return {};
  }

}
