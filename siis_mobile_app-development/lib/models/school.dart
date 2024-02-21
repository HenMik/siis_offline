import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'schools';

class School {
  late var emisId;
  late var schoolName;
  late var establishmentType;
  late var divisionId;
  late var districtId;
  late var zoneId;
  late var sectorId;
  late var visitationDate;
  late var visitId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'emis_id': emisId, 'school_name': schoolName, 'establishment_type': establishmentType, 'division_id':divisionId, 'district_id':districtId,
    'zone_id':zoneId, 'sector_id':sectorId};
    return map;
  }

  School({required this.emisId, required this.schoolName, required this.establishmentType, required this.divisionId, required this.districtId, required this.zoneId, required this.sectorId, this.visitationDate, this.visitId });

  School.fromMap(Map<String, Object?> map) {
    emisId = map['emis_id'] ?? "";
    schoolName = map['school_name'] ?? "";
    establishmentType = map['establishment_type'] ?? "";
    divisionId = map['division_id'] ?? "";
    districtId = map['district_id'] ?? "";
    zoneId = map['zone_id'] ?? "";
    sectorId = map['sector_id'] ?? "";
  }
}

class SchoolProvider {

  Future<bool> sync(headers) async {
    Database db = await DatabaseConnection().setDatabase();
    School? standard = await SchoolProvider().getOne(506011);
    if(standard?.schoolName == null){
      SchoolProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.schoolsPath), headers: headers);
      List results = jsonDecode(response.body);
      Batch batch = db.batch();
      results.forEach((element) async {
        School standard = School(
            emisId: element['emis_id'],
            schoolName: element['school_name'],
            establishmentType: element['establishment_type'],
            divisionId: element['division_id'],
            districtId: element['district_id'],
            zoneId: element['zone_id'],
            sectorId: element['sector_id'],
        );
        batch.insert(tableName, standard.toMap());
      });
      await batch.commit(noResult: true);
    }
    return true;
  }

  Future<School> insert(School nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, nes.toMap());
    return nes;
  }
  Future<Iterable<School>?> getByZone(String? zone_id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'zone_id = ? ORDER BY school_name',
        whereArgs: [zone_id]
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => School(emisId: e['emis_id'],
          schoolName: e['school_name'],
          establishmentType: e['establishment_type'],
          divisionId: e['division_id'],
          districtId: e['district_id'],
          zoneId: e['zone_id'],
          sectorId: e['sector_id']));
    }
    return null;
  }
  Future<Iterable<School>?> getBySector(String? sector) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'sector_id = ?',
        whereArgs: [sector]
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => School(emisId: e['emis_id'],
          schoolName: e['school_name'],
          establishmentType: e['establishment_type'],
          divisionId: e['division_id'],
          districtId: e['district_id'],
          zoneId: e['zone_id'],
          sectorId: e['sector_id'],));
    }
    return null;
  }
  Future<Iterable<School>?> getBySectorAndZone(String? sector, String? zone) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ["*"],
        where: 'sector_id = ? and zone_id = ?',
        whereArgs: [sector, zone]
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => School(emisId: e['emis_id'],
        schoolName: e['school_name'],
        establishmentType: e['establishment_type'],
        divisionId: e['division_id'],
        districtId: e['district_id'],
        zoneId: e['zone_id'],
        sectorId: e['sector_id'],
        ));
    }
    return null;
  }
  Future<Iterable<School>?> getByZoneAndVisitType(String? emis) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.rawQuery("SELECT inspections.*, schools.* from inspections INNER JOIN schools ON schools.emis_id = inspections.emis_id where schools.emis_id = $emis and inspections.visit_type_id = 1");
    if (maps.isNotEmpty) {
      return maps.map((e) => School(emisId: e['emis_id'],
          schoolName: e['school_name'],
          establishmentType: e['establishment_type'],
          divisionId: e['division_id'],
          districtId: e['district_id'],
          zoneId: e['zone_id'],
          sectorId: e['sector_id'],
          visitationDate: e['present_visitation_date'],
          visitId: e['visit_id']));
    }
    return null;
  }
  Future<Iterable<School>?> getByDate(String? date, String? emis) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.rawQuery("SELECT inspections.*, schools.* from inspections INNER JOIN schools ON schools.emis_id = inspections.emis_id where inspections.present_visitation_date = '$date' and schools.emis_id = '$emis' and inspections.visit_type_id = 1");
    if (maps.isNotEmpty) {
      return maps.map((e) => School(emisId: e['emis_id'],
          schoolName: e['school_name'],
          establishmentType: e['establishment_type'],
          divisionId: e['division_id'],
          districtId: e['district_id'],
          zoneId: e['zone_id'],
          sectorId: e['sector_id'],
          visitationDate: e['present_visitation_date'],
          visitId: e['visit_id']));
    }
    return null;
  }
  Future<School?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'emis_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return School.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'emis_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(School school) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, school.toMap(),
        where: 'emis_id = ?', whereArgs: [school.emisId]);
  }
}
