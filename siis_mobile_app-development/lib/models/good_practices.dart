import 'dart:convert';

import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

class GoodPracticesModel {
  int? id;
  var description;
  var visitId;
  var sync;
  var createdAt;

  goodPracticesMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['good_practice_id'] = id ?? null;
    mappingg['good_practice_description'] = description!;
    mappingg['visit_id'] = visitId;
    mappingg['sync'] = sync;
    mappingg['created_at'] = createdAt;

    return mappingg;
  }
}

var tableName = 'good_practices';

class GoodPractice {
  late var goodPracticeId;
  late var goodPracticeDescription;
  late var visitId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'good_practice_id': goodPracticeId,
      'good_practice_description': goodPracticeDescription,
      'visit_id': visitId
    };
    return map;
  }

  GoodPractice(
      {required this.goodPracticeId,
      required this.goodPracticeDescription,
      required this.visitId});

  GoodPractice.fromMap(Map<String, Object?> map) {
    goodPracticeId = map['good_practice_id'];
    goodPracticeDescription = map['good_practice_description'];
    visitId = map['visit_id'];
  }
}

class GoodPracticeProvider {
  Future<bool> sync(headers) async {
    GoodPractice? standard = await GoodPracticeProvider().getFirst();
    if (standard == null) {
      print("$tableName is empty. syncing...");
      GoodPracticeProvider().truncate();
      Response response =
          await get(Uri.parse(BaseApi.goodPracticesPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        GoodPractice standard = GoodPractice(
            goodPracticeId: element['good_practice_id'],
            goodPracticeDescription: element['good_practice_description'],
            visitId: element['visit_id']);
        GoodPracticeProvider().insert(standard);
      }
    }
    return true;
  }

  Future<GoodPractice> insert(GoodPractice category) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, category.toMap());
    return category;
  }

  Future<GoodPractice?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName);
    if (maps.isNotEmpty) {
      return GoodPractice.fromMap(maps.first);
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
      var goodPractices = maps.map((e) => GoodPractice(
          goodPracticeId: e['good_practice_id'],
          goodPracticeDescription: e['good_practice_description'],
          visitId: e['visit_id']));
      for (var gp in goodPractices!) {
        gp.visitId = onlineVisitId;
        post(Uri.parse(BaseApi.goodPracticesPath),
            headers: headers, body: jsonEncode(gp.toMap()));
      }
      return true;
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db
        .delete(tableName, where: 'good_practice_id = ?', whereArgs: [id]);
  }

  Future<bool> truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(GoodPractice category) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, category.toMap(),
        where: 'good_practice_id = ?', whereArgs: [category.goodPracticeId]);
  }

  syncUpdatesToServer(String offlineVisitId, onlineVisitId, Map<String, String> headers) async{
    await syncToServer(offlineVisitId, onlineVisitId, headers);
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'sync = ? and visit_id = ?',
        whereArgs: ['2', onlineVisitId]);
    if (maps.isNotEmpty) {
      var goodPractices = maps.map((e) => GoodPractice(
          goodPracticeId: e['good_practice_id'],
          goodPracticeDescription: e['good_practice_description'],
          visitId: e['visit_id']));
      for (var gp in goodPractices!) {
        patch(Uri.parse("${BaseApi.goodPracticesPath}/update/${gp.goodPracticeId}"),
            headers: headers, body: jsonEncode(gp.toMap()));
      }
      return true;
    }
    return null;

  }
}
