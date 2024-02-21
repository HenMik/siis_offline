import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'divisions';

class Division {
  late var divisionId;
  late var divisionName;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'division_id': divisionId, 'division_name': divisionName};
    return map;
  }

  Division({required this.divisionId, required this.divisionName});

  Division.fromMap(Map<String, Object?> map) {
    divisionId = map['division_id'];
    divisionName = map['division_name'];
  }
}

class DivisionProvider {

  Future<bool> sync(headers) async {
    Division? standard = await DivisionProvider().getOne(1);
    if(standard?.divisionName == null){
      print("$tableName is empty. syncing...");
      DivisionProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.divisionPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        Division standard = Division(
            divisionName: element['division_name'],
            divisionId: element['division_id']
        );
        DivisionProvider().insert(standard);
      }
    }
    return true;
  }

  Future<Division> insert(Division division) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, division.toMap());
    return division;
  }

  Future<Division?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['division_id', 'division_name'],
        where: 'division_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Division.fromMap(maps.first);
    }
    return null;
  }
  Future<Iterable<Division>?> getAll() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"]);
    if (maps.isNotEmpty) {
      return maps.map((e) => Division(divisionId: e['division_id'], divisionName: e['division_name']));
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'division_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(Division division) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, division.toMap(),
        where: 'district_id = ?', whereArgs: [division.divisionId]);
  }
}
