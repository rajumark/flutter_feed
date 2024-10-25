import 'dart:async';
import 'dart:developer';
import 'package:flutter_feed/database/Model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbManager {
  late Database _database;
var dbName= "subscribe.db";
var tableName= "source_model";
  Future<Database> openDb() async {
    _database = await openDatabase(join(await getDatabasesPath(), dbName),
        version: 1, onCreate: (Database db, int version) async {
          await db.execute(
            "CREATE TABLE $tableName(url TEXT PRIMARY KEY, title TEXT, icon TEXT, is_on INTEGER)", // Updated schema
          );
        });
    return _database;
  }

  Future<int> insertModel(Model model) async {
    await openDb();
    return await _database.insert('$tableName', model.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertModels(List<Model> list) async {
    await openDb();
    Batch batch = _database.batch();
    for (var aaaa in list) {
      try {
        await insertModel(aaaa);
      } catch (e) {
        log("Rajuerror=" + e.toString());
      }
    }
    await batch.commit(noResult: true);
  }

  Future<List<Model>> getModelList() async { // Removed selectedChip parameter
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('$tableName');

    var list = List.generate(maps.length, (i) {
      return Model(
        url: maps[i]['url'], // Changed from id to url
        title: maps[i]['title'],
        icon: maps[i]['icon'],
        is_on: maps[i]['is_on'],
      );
    });
    // Sort the list by title
    list.sort((a, b) => a.title.compareTo(b.title));

    return list; // No sorting needed as there's no date field in Model
  }

  Future<List<Model>> getModelListRow() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('$tableName');

    var list = List.generate(maps.length, (i) {
      return Model(
        url: maps[i]['url'], // Changed from id to url
        title: maps[i]['title'],
        icon: maps[i]['icon'],
        is_on: maps[i]['is_on'],
      );
    });

    return list; // No sorting needed as there's no date field in Model
  }

  Future<int> updateModel(Model model) async {
    await openDb();
    return await _database.update('$tableName', model.toJson(),
        where: "url = ?", whereArgs: [model.url]); // Changed from id to url
  }


  Future<void> deleteModel(String url) async { // Change to String
    await openDb();
    await _database.delete('$tableName', where: "url = ?", whereArgs: [url]); // Changed from id to url
  }

  Future<void> deleteModelList(List<String> urls) async { // Change to String
    await openDb();
    Batch batch = _database.batch();
    for (var element in urls) {
      batch.delete('$tableName', where: "url = ?", whereArgs: [element]); // Changed from id to url
    }
    await batch.commit(noResult: true);
  }
}