import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'districts';

class District {
  late var districtId;
  late var districtName;
  late var divisionId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'district_id': districtId, 'district_name': districtName, 'division_id': divisionId};
    return map;
  }

  District({required this.districtId, required this.districtName, required this.divisionId});

  District.fromMap(Map<String, Object?> map) {
    districtId = map['district_id'];
    districtName = map['district_name'];
    divisionId = map['division_id'];
  }
}

class DistrictProvider {

  Future<bool> sync(headers) async {
    District? standard = await DistrictProvider().getOne(1);
    if(standard?.districtName == null){
      print("$tableName is empty. syncing...");
      DistrictProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.districtPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        District standard = District(
            districtId: element['district_id'],
            districtName: element['district_name'],
            divisionId: element['division_id']
        );
        DistrictProvider().insert(standard);
      }
    }
    return true;
  }

  Future<District> insert(District nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, nes.toMap());
    return nes;
  }
  Future<Iterable<District>?> getAll() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"]);
    if (maps.isNotEmpty) {
      return maps.map((e) => District(districtId: e['division_id'], districtName: e['division_name'], divisionId: e['division_id']));
    }
    return null;
  }

  Future<Iterable<District>?> getByDivision(String? division_id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'division_id = ? ORDER BY district_name',
        whereArgs: [division_id]
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => District(districtId: e['district_id'], districtName: e['district_name'], divisionId: e['division_id']));
    }
    return null;
  }

  Future<District?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['district_id', 'district_name', 'division_id'],
        where: 'district_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return District.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'district_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(District district) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, district.toMap(),
        where: 'district_id = ?', whereArgs: [district.districtId]);
  }
}
