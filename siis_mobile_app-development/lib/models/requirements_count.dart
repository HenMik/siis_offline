import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'requirements_counts';

class RequirementsCount {
  late var requirementsCountId;
  late var nesId;
  late var nesLevelId;
  late var requirementsCount;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'requirement_count_id': requirementsCountId, 'nes_id': nesId, 'nes_level_id': nesLevelId, 'requirement_count': requirementsCount};
    return map;
  }

  RequirementsCount({required this.requirementsCountId, required this.nesId, required this.nesLevelId, required this.requirementsCount});

  RequirementsCount.fromMap(Map<String, Object?> map) {
    requirementsCountId = map['requirement_count_id'];
    nesId = map['nes_id'];
    nesLevelId = map['nes_level_id'];
    requirementsCount = map['requirement_count'];
  }
}

class RequirementsCountProvider {

  Future<bool> sync(headers) async {
    RequirementsCount? standard = await RequirementsCountProvider().getOne(1);
    if(standard?.requirementsCount== null){
      print("$tableName is empty. syncing...");
      RequirementsCountProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.requirementsCountPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        RequirementsCount standard = RequirementsCount(
            requirementsCountId : element['requirement_count_id'],
            nesId: element['nes_id'],
            nesLevelId: element['nes_level_id'],
             requirementsCount: element['requirement_count'],
        );
        RequirementsCountProvider().insert(standard);
      }
    }
    return true;
  }

  Future<RequirementsCount> insert(RequirementsCount category) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, category.toMap());
    return category;
  }


  Future<RequirementsCount?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'requirement_count_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return RequirementsCount.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'requirement_count_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(RequirementsCount category) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, category.toMap(),
        where: 'requirement_count_id = ?', whereArgs: [category.requirementsCountId]);
  }
}