import 'dart:convert';

import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

var tableName = 'strengths';

class MajorStrength {
  late var strengthId;
  late var strengthDescription;
  late var visitId;
  late var sync;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'strength_id': strengthId,
      'strength_description': strengthDescription,
      'visit_id': visitId
    };
    return map;
  }

  MajorStrength(
      {
      required this.strengthId,
      required this.strengthDescription,
      required this.visitId});

  MajorStrength.fromMap(Map<String, Object?> map) {
    strengthId = map['strength_id'];
    strengthDescription = map['strength_description'];
    visitId = map['visit_id'];
  }
}

class MajorStrengthProvider {
  Future<bool> sync(headers) async {
    MajorStrength? standard = await MajorStrengthProvider().getFirst();
    if (standard == null) {
      print("$tableName is empty. syncing...");
      MajorStrengthProvider().truncate();
      Response response =
          await get(Uri.parse(BaseApi.strengthPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        MajorStrength standard = MajorStrength(
            strengthId: element['strength_id'],
            strengthDescription: element['strength_description'],
            visitId: element['visit_id']);
        MajorStrengthProvider().insert(standard);
      }
    }
    return true;
  }

  Future<MajorStrength> insert(MajorStrength category) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, category.toMap());
    return category;
  }

  Future<MajorStrength?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName);
    if (maps.isNotEmpty) {
      return MajorStrength.fromMap(maps.first);
    }
    return null;
  }

  Future<bool?> syncToServer(
      String offlineVisitId, onlineVisitId, Map<String, String> headers) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'sync = ? and visit_id = ?',
        whereArgs: ['1', offlineVisitId]);
    if (maps.isNotEmpty) {
      var strengths = maps.map((e) => MajorStrength(
          strengthId: e['strength_id'],
          strengthDescription: e['strength_description'],
          visitId: e['visit_id']));
      if (strengths != null) {
        for (var strength in strengths) {
          strength.visitId = onlineVisitId;
          post(Uri.parse(BaseApi.strengthPath),
              headers: headers, body: jsonEncode(strength.toMap()));
          strength.sync = 0;
          update(strength);
        }
      }
      return true;
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db
        .delete(tableName, where: 'category_id = ?', whereArgs: [id]);
  }

  Future<bool> truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(MajorStrength category) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, category.toMap(),
        where: 'strength_id = ?', whereArgs: [category.strengthId]);
  }

  Future<bool?> syncUpdatesToServer(String offlineVisitId, onlineVisitId, Map<String, String> headers) async{
    syncToServer(offlineVisitId, onlineVisitId, headers);
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'sync = ? and visit_id = ?',
        whereArgs: ['2', onlineVisitId]);
    if (maps.isNotEmpty) {
      var strengths = maps.map((e) => MajorStrength(
          strengthId: e['strength_id'],
          strengthDescription: e['strength_description'],
          visitId: e['visit_id']));
      for (var strength in strengths) {
        patch(Uri.parse("${BaseApi.strengthPath}/update/${strength.strengthId}"),
            headers: headers, body: jsonEncode(strength.toMap()));
      }
      return true;
    }
    return null;
  }
}

class MajorStrengthModel {
  int? id;
  var description;
  var visitId;
  var sync;
  var createdAt;

  majorStrengthsMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['strength_id'] = id ?? null;
    mappingg['strength_description'] = description!;
    mappingg['visit_id'] = visitId;
    mappingg['sync'] = sync;
    mappingg['created_at'] = createdAt;

    return mappingg;
  }
}
