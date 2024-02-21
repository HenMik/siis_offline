import 'dart:convert';

import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

var tableName = 'critical_issues';

class CriticalIssuesModel {
  int? id;
  var description;
  var visitId;
  var sync;
  var createdAt;

  criticalissuesMap() {
    var mappingg = Map<String, dynamic>();
    mappingg['critical_issue_id'] = id ?? null;
    mappingg['critical_issue_description'] = description!;
    mappingg['visit_id'] = visitId;
    mappingg['sync'] = sync;
    mappingg['created_at'] = createdAt;

    return mappingg;
  }
}

class CriticalIssues {
  late var criticalIssueId;
  late var criticalIssueName;
  late var visitId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'critical_issue_id': criticalIssueId,
      'critical_issue_description': criticalIssueName,
      'visit_id': visitId
    };
    return map;
  }

  CriticalIssues(
      {required this.criticalIssueId,
      required this.criticalIssueName,
      required this.visitId});

  CriticalIssues.fromMap(Map<String, Object?> map) {
    criticalIssueId = map['critical_issue_id'];
    criticalIssueName = map['critical_issue_description'];
    visitId = map['visit_id'];
  }
}

class CriticalIssuesProvider {
  Future<bool> sync(headers) async {
    CriticalIssues? standard = await CriticalIssuesProvider().getOne(1);
    if (standard?.criticalIssueName == null) {
      print("$tableName is empty. syncing...");
      CriticalIssuesProvider().truncate();
      Response response =
          await get(Uri.parse(BaseApi.criticalIssuesPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        CriticalIssues standard = CriticalIssues(
            criticalIssueId: element['critical_issue_id'],
            criticalIssueName: element['critical_issue_description'],
            visitId: element['visit_id']);
        CriticalIssuesProvider().insert(standard);
      }
    }
    return true;
  }

  Future<bool?> syncToServer(
      String offlineVisitId, onlineVisitId, Map<String, String> headers) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'sync = ? and visit_id = ?',
        whereArgs: ['1', offlineVisitId]);
    if (maps.isNotEmpty) {
      var criticalIssues = maps.map((e) => CriticalIssues(
          criticalIssueId: e['critical_issue_id'],
          criticalIssueName: e['critical_issue_description'],
          visitId: e['visit_id']));
      for (var ci in criticalIssues!) {
        ci.visitId = onlineVisitId;
        post(Uri.parse(BaseApi.criticalIssuesPath),
            headers: headers, body: jsonEncode(ci.toMap()));
      }
      return true;
    }
    return null;
  }

  Future<CriticalIssues> insert(CriticalIssues nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, nes.toMap());
    return nes;
  }

  Future<Iterable<CriticalIssues>?> getAll() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName, columns: ["*"]);
    if (maps.isNotEmpty) {
      return maps.map((e) => CriticalIssues(
          criticalIssueId: e['critical_issue_id'],
          criticalIssueName: e['critical_issue_description'],
          visitId: e['visit_id']));
    }
    return null;
  }

  Future<CriticalIssues?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName, columns: ['*']);
    if (maps.isNotEmpty) {
      return CriticalIssues.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db
        .delete(tableName, where: 'critical_issue_id = ?', whereArgs: [id]);
  }

  Future<bool> truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(CriticalIssues district) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, district.toMap(),
        where: 'critical_issue_id = ?', whereArgs: [district.criticalIssueId]);
  }

  syncUpdatesToServer(String offlineVisitId, onlineVisitId, Map<String, String> headers) async {
    await syncToServer(offlineVisitId, onlineVisitId, headers);
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'sync = ? and visit_id = ?',
        whereArgs: ['2', offlineVisitId]);
    if (maps.isNotEmpty) {
      var criticalIssues = maps.map((e) => CriticalIssues(
          criticalIssueId: e['critical_issue_id'],
          criticalIssueName: e['critical_issue_description'],
          visitId: e['visit_id']));
      for (var ci in criticalIssues!) {
        patch(Uri.parse("${BaseApi.criticalIssuesPath}/update/${ci.criticalIssueId}"),
            headers: headers, body: jsonEncode(ci.toMap()));
      }
      return true;
    }
    return null;
  }
}
