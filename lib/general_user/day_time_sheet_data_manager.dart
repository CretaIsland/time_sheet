import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../common/logger.dart';
import '../../model/data_model.dart';

class DayTimeSheetDataManager {

  Database? _database;


  Future<void> openDB() async {  // open database
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'daytimesheet.db');

    try {
      _database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
        // database가 없을 경우, 새로 생성한다.
        logger.finest("create database");
        await db.execute("CREATE TABLE day_time_sheet (timeslot INTEGER PRIMARY KEY, act_code TEXT, date TEXT)");
        for(int i=0; i<24; i++) {
          await db.execute("INSERT INTO day_time_sheet(timeslot, act_code, date) VALUES($i, '', ${DataManager.formatter.format(DateTime.now())})");
        }
      });
    } catch (error) {
      await _database!.close();
      logger.finest(error);
    }
  }

    Future<void> deleteDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'daytimesheet.db');
    try {
      if(_database == null ) { _database!.close(); }
      await deleteDatabase(path);
    } catch (e) {
      logger.warning('deleteDatabase($path) ERROR !!!');
    }
  }


  Future<void> addTimeSheetData(int timeSlot, String actCode) async { // add timesheet data
    try {
      if(_database == null) {
        await openDB();
      }
      await _database!.update("day_time_sheet", {"act_code" : actCode}, where: "timeslot = ?", whereArgs: [timeSlot]);
    } catch (error) {
      await _database!.close();
      logger.finest(error);
    }
  }

  Future<void> deleteTimeSheetData(int timeSlot) async { // delete timesheet data
    try {
      if(_database == null) { 
        await openDB(); 
      }
      await _database!.update("day_time_sheet", {"act_code" : ""}, where: "timeslot = ?", whereArgs: [timeSlot]);
    } catch (error) {
      await _database?.close();
    }
  }

  Future<List<String>> getTimeSheetData() async { // get timesheet data
    List<String> actCodeList = [];
    try {
      if(_database == null) { 
        await openDB(); 
      }
      List<Map> list = await _database!.rawQuery('SELECT * FROM day_time_sheet');
      for(var row in list) {
        actCodeList.add(row["act_code"]);
      }
    } catch (error) {
      await _database?.close();
    }
    return actCodeList;
  }

  Future<void> resetTimeSheet() async {
    try {
      if(_database == null) {
        await openDB();
      }
      for(int i=0; i<24; i++) {
        await _database!.update("day_time_sheet", {"act_code" : "", "date" : DataManager.formatter.format(DateTime.now())}, where: "timeslot = ?", whereArgs: [i]);
      }
    } catch (error) {
      _database!.close();
      logger.finest(error);
    }
  }

  Future<void> checkDate(String date) async {
    try {
      if(_database == null) { await openDB(); }
      List<Map> list = await _database!.rawQuery('SELECT date FROM day_time_sheet LIMIT 1');
      logger.finest(list[0]["date"]);
      if(date != list[0]["date"]) {
        logger.finest("날짜가 다르기 때문에 초기화하기");
        await resetTimeSheet();
      }
    } catch (error) {
      await _database!.close();
      logger.finest(error);
    }
  }
  

}