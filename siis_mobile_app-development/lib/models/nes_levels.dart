import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'nes_levels';

class NesLevel {
  late var nesLevelsId;
  late var nesLevelName;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'nes_level_id': nesLevelsId, 'nes_level_name': nesLevelName};
    return map;
  }

  NesLevel({required this.nesLevelsId, required this.nesLevelName});

  NesLevel.fromMap(Map<String, Object?> map) {
    nesLevelsId = map['nes_level_id'];
    nesLevelName = map['nes_level_name'];
  }
}

class NesLevelProvider {

  Future<bool> sync(headers) async {
    NesLevel? standard = await NesLevelProvider().getNationalStandard(1);
    if(standard?.nesLevelName == null){
      print("$tableName is empty. syncing...");
      NesLevelProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.nesLevelsPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        NesLevel standard = NesLevel(
            nesLevelsId: element['nes_level_id'],
            nesLevelName: element['nes_level_name'],
        );
        NesLevelProvider().insert(standard);
      }
    }
    return true;
  }

  Future<NesLevel> insert(NesLevel level) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, level.toMap());
    return level;
  }

  Future<NesLevel?> getNationalStandard(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['nes_level_id', 'nes_level_name'],
        where: 'nes_level_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return NesLevel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'nes_level_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(NesLevel level) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, level.toMap(),
        where: 'nes_level_id = ?', whereArgs: [level.nesLevelsId]);
  }
}
