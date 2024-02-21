import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'nes_requirements';

class NesRequirement {
  late var nesId;
  late var requirementId;
  late var nesLevelId;
  late var requirementName;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'nes_id': nesId, 'requirement_id': requirementId, 'nes_level_id': nesLevelId, 'requirement_name': requirementName};
    return map;
  }

  NesRequirement({required this.nesId, required this.requirementId, required this.nesLevelId, required this.requirementName});

  NesRequirement.fromMap(Map<String, Object?> map) {
    nesId = map['nes_id'];
    requirementId = map['requirement_id'];
    nesLevelId = map['nes_level_id'];
    requirementName = map['requirement_name'];
  }
}

class NesRequirementProvider {

  Future<bool> sync(headers) async {
    NesRequirement? standard = await NesRequirementProvider().getOne(1);
    if(standard?.requirementId == null){
      print("$tableName is empty. syncing...");
      NesRequirementProvider().truncate();
      Response response = await get(Uri.parse(BaseApi.nesRequirementPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        NesRequirement standard = NesRequirement(
            nesId: element['nes_id'],
            requirementId: element['requirement_id'],
            nesLevelId: element['nes_level_id'],
            requirementName: element['requirement_name']
        );
        NesRequirementProvider().insert(standard);
      }
    }
    return true;
  }

  Future<NesRequirement> insert(NesRequirement nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, nes.toMap());
    return nes;
  }

  Future<List<NesRequirement>?> getByNesId(String? nes_id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'nes_id = ? and nes_level_id != 1 order by requirement_id asc',
        whereArgs: [nes_id]
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => NesRequirement(nesId: e['nes_id'],
          requirementId: e['requirement_id'],
          nesLevelId: e['nes_level_id'],
          requirementName: e['requirement_name'])).toList();
    }
    return null;
  }
  Future<NesRequirement?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['nes_id', 'requirement_id', 'nes_level_id', 'requirement_name'],
        where: 'nes_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return NesRequirement.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'nes_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(NesRequirement district) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, district.toMap(),
        where: 'nes_id = ?', whereArgs: [district.nesId]);
  }
}
