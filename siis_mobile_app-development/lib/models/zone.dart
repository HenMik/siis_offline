import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'zones';

class Zone {
  late var zoneId;
  late var zoneName;
  late var districtId;
  late var sectorId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'zone_id': zoneId, 'zone_name': zoneName, 'district_id': districtId, 'sector_id': sectorId};
    return map;
  }

  Zone({required this.zoneId, required this.zoneName, required this.districtId, required this.sectorId});

  Zone.fromMap(Map<String, Object?> map) {
    zoneId = map['zone_id'];
    zoneName = map['zone_name'];
    districtId = map['district_id'];
    sectorId = map['sector_id'];
  }
}

class ZoneProvider {

  Future<bool> sync(headers) async {
    Zone? standard = await ZoneProvider().getFirst();
    if(standard == null){
      print("$tableName is empty. syncing...");
      ZoneProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.zonePath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        Zone standard = Zone(
            zoneName: element['zone_name'],
            zoneId: element['zone_id'],
            districtId: element['district_id'],
            sectorId: element['sector_id']
        );
        ZoneProvider().insert(standard);
      }
    }
    return true;
  }

  Future<Zone> insert(Zone category) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, category.toMap());
    return category;
  }
  Future<Iterable<Zone>?> getBySector(String? sector) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'sector_id = ?',
        whereArgs: [sector]
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => Zone(zoneName: e['zone_name'],
          zoneId: e['zone_id'],
          districtId: e['district_id'],
          sectorId: e['sector_id']));
    }
    return null;
  }
  Future<Iterable<Zone>?> getByDistrict(String? district_id, String? sector_id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'district_id = ? and sector_id = ? ORDER BY zone_name',
        whereArgs: [district_id, sector_id]
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => Zone(zoneId: e['zone_id'], zoneName: e['zone_name'], districtId: e['district_id'], sectorId: e['sector_id']));
    }
    return null;
  }
  Future<Zone?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName);
    if (maps.isNotEmpty) {
      return Zone.fromMap(maps.first);
    }
    return null;
  }
  Future<Zone?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'zone_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Zone.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'zone_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(Zone category) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, category.toMap(),
        where: 'zone_id = ?', whereArgs: [category.zoneId]);
  }
}