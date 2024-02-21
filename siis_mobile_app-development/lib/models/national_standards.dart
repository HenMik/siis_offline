import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'national_standards';

class NationalStandard {
  late var nesId;
  late var nesName;
  late var categoryId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'nes_id': nesId, 'nes_name': nesName, 'category_id': categoryId};
    return map;
  }

  NationalStandard({required this.nesId, required this.nesName, required this.categoryId});

  NationalStandard.fromMap(Map<String, Object?> map) {
    nesId = map['nes_id'];
    nesName = map['nes_name'];
    categoryId = map['category_id'];
  }
}

class NationalStandardProvider {

  Future<bool> sync(headers) async {
    NationalStandard? standard = await NationalStandardProvider().getNationalStandard(1);
    if(standard?.nesName == null){
      print("$tableName is empty. syncing...");
      NationalStandardProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.nationalStandardsPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        NationalStandard standard = NationalStandard(
            nesId: element['nes_id'],
            nesName: element['nes_name'],
            categoryId: element['category_id']
        );
        NationalStandardProvider().insert(standard);
      }
    }
    return true;
  }

  Future<NationalStandard> insert(NationalStandard nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, nes.toMap());
    return nes;
  }
  Future<Iterable<NationalStandard>?> getAll() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"]);
    if (maps.isNotEmpty) {
      return maps.map((e) => NationalStandard(categoryId: e['category_id'], nesId: e['nes_id'], nesName: e['nes_name']));
    }
    return null;
  }
  Future<NationalStandard?> getNationalStandard(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['nes_id', 'nes_name', 'category_id'],
        where: 'nes_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return NationalStandard.fromMap(maps.first);
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

  Future<int> update(NationalStandard nes) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, nes.toMap(),
        where: 'nes_id = ?', whereArgs: [nes.nesId]);
  }
}
