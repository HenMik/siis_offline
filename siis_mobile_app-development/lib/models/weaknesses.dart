import 'dart:convert';

import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

var tableName = 'weaknesses';

class Weaknesses {
  late var weaknessId;
  late var weaknessDescription;
  late var visitId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'weakness_id': weaknessId,
      'weakness_description': weaknessDescription,
      'visit_id': visitId
    };
    return map;
  }

  Weaknesses(
      {required this.weaknessId,
      required this.weaknessDescription,
      required this.visitId});

  Weaknesses.fromMap(Map<String, Object?> map) {
    weaknessId = map['weakness_id'];
    weaknessDescription = map['weakness_description'];
    visitId = map['visit_id'];
  }
}

class WeaknessProvider {
  Future<bool> sync(headers) async {
    Weaknesses? standard = await WeaknessProvider().getFirst();
    if (standard == null) {
      print("$tableName is empty. syncing...");
      WeaknessProvider().truncate();
      Response response =
          await get(Uri.parse(BaseApi.weaknessesPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        Weaknesses standard = Weaknesses(
            weaknessId: element['weakness_id'],
            weaknessDescription: element['weakness_description'],
            visitId: element['visit_id']);
        WeaknessProvider().insert(standard);
      }
    }
    return true;
  }

  Future<Weaknesses> insert(Weaknesses category) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, category.toMap());
    return category;
  }

  Future<Weaknesses?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName);
    if (maps.isNotEmpty) {
      return Weaknesses.fromMap(maps.first);
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
      var weaknesses = maps.map((e) => Weaknesses(
          weaknessId: e['weakness_id'],
          weaknessDescription: e['weakness_description'],
          visitId: e['visit_id']));
      for (var weakness in weaknesses!) {
        weakness.visitId = onlineVisitId;
        post(Uri.parse(BaseApi.weaknessesPath),
            headers: headers, body: jsonEncode(weakness.toMap()));
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

  Future<int> update(Weaknesses category) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, category.toMap(),
        where: 'category_id = ?', whereArgs: [category.weaknessId]);
  }

  syncUpdatesToServer(String offlineVisitId, onlineVisitId, Map<String, String> headers) async {
    await syncToServer(offlineVisitId, onlineVisitId, headers);
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'sync = ? and visit_id = ?',
        whereArgs: ['2', onlineVisitId]);
    if (maps.isNotEmpty) {
      var weaknesses = maps.map((e) => Weaknesses(
          weaknessId: e['weakness_id'],
          weaknessDescription: e['weakness_description'],
          visitId: e['visit_id']));
      for (var weakness in weaknesses) {
        print("wekaness 1");
        patch(Uri.parse("${BaseApi.weaknessesPath}/update/${weakness.weaknessId}"),
            headers: headers, body: jsonEncode(weakness.toMap()));
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
  var createdAt;

  majorStrengthsMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['weakness_id'] = id ?? null;
    mappingg['weakness_description'] = description!;
    mappingg['visit_id'] = visitId;
    mappingg['created_at'] = createdAt;

    return mappingg;
  }
}
