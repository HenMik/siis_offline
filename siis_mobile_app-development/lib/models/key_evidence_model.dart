import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:siis_offline/models/key_evidence.dart';
import 'package:siis_offline/models/model.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

String table = "key_evidence";

class KeyEvidenceModel extends Model {
  static String table = table;

  var keyEvidenceId;
  var description;
  var keyEvidenceStatus;
  var visitId;
  var createdAt;
  var nesId;
  var requirementId;
  var nesLevelId;

  KeyEvidenceModel(
      {this.description,
      this.visitId,
      this.nesId,
      this.keyEvidenceId,
      this.requirementId,
      this.nesLevelId,
      this.keyEvidenceStatus,
      this.createdAt});

  static KeyEvidenceModel fromMap(Map<String, Object?> json) {
    return KeyEvidenceModel(
      keyEvidenceId: json['key_evidence_id'],
      description: json['key_evidence_description'],
      visitId: json['visit_id'],
      nesId: json['nes_id'],
      requirementId: json['requirement_id'],
      nesLevelId: json['nes_level_id'],
      keyEvidenceStatus: json['key_evidence_status'],
      createdAt: json['created_at'],
    );
  }

  @override
  Map<String, Object?> toJson() {
    Map<String, Object?> map = {
      'key_evidence_id': id,
      'key_evidence_description': description,
      'visit_id': visitId,
      'nes_id': nesId,
      'requirement_id': requirementId,
      'nes_level_id': nesLevelId,
      'key_evidence_status': keyEvidenceStatus,
      'created_at': createdAt,
    };
    return map;
  }
}

class KeyEvidenceModelProvider {
  Future<bool> sync(headers) async {
    Database db = await DatabaseConnection().setDatabase();
    KeyEvidenceModel? standard = await KeyEvidenceModelProvider().getFirst();
    if (standard == null) {
      print("$table is empty. syncing...");
      Response response =
          await get(Uri.parse(BaseApi.keyEvidencePath), headers: headers);
      List results = jsonDecode(response.body);
      Batch batch = db.batch();
      for (var json in results) {
        KeyEvidenceModel standard = KeyEvidenceModel(
          keyEvidenceId: json['key_evidence_id'],
          description: json['key_evidence_description'],
          visitId: json['visit_id'],
          nesId: json['nes_id'],
          requirementId: json['requirement_id'],
          nesLevelId: json['nes_level_id'],
          keyEvidenceStatus: json['key_evidence_status'],
          createdAt: json['created_at'],
        );
        batch.insert(table, standard.toJson());
      }
      await batch.commit();
    }
    return true;
  }

  Future<KeyEvidenceModel> insert(KeyEvidenceModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(table, nes.toJson());
    return nes;
  }

  Future<bool?> syncToServer(
      String offlineVisitId, onlineVisitId, Map<String, String> headers) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'sync = ? and visit_id = ?',
        whereArgs: ['1', offlineVisitId]);
    if (maps.isNotEmpty) {
      var data = groupBy(
          maps.map((e) => KeyEvidenceModel(
                keyEvidenceId: e['key_evidence_id'],
                description: e['key_evidence_description'],
                visitId: e['visit_id'],
                nesId: e['nes_id'],
                requirementId: e['requirement_id'],
                nesLevelId: e['nes_level_id'],
                keyEvidenceStatus: e['key_evidence_status'],
                createdAt: e['created_at'],
              )),
          (KeyEvidenceModel d) => d.nesId);
      data.forEach((key, value) async {
        var keyEvidenceObj =
            buildKeyEvidenceObj(value, onlineVisitId.toString());
        await post(Uri.parse(BaseApi.keyEvidencePath),
            headers: headers, body: jsonEncode(keyEvidenceObj));
      });
    }
    return null;
  }

  buildKeyEvidenceObj(var keyEvidences, String visitId) {
    return {
      "key_evidence_description": keyEvidences
          .map((e) => {'descr': e.requirementId + ":" + e.description})
          .toList(),
      "key_evidence_status": keyEvidences
          .map((e) => {'state': e.requirementId + ":" + e.keyEvidenceStatus})
          .toList(),
      "nes_id": keyEvidences.first.nesId.toString(),
      "recommendation_type": "Minor",
      'recommendation_description': 'Desc',
      'nes_level_id': keyEvidences
          .map((e) => e.requirementId + ':' + e.nesLevelId)
          .toList(),
      'requirement_id': keyEvidences.map((e) => e.requirementId).toList(),
      "visit_id": visitId.toString()
    };
  }

  Future<KeyEvidenceModel?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table);
    if (maps.isNotEmpty) {
      return KeyEvidenceModel.fromMap(maps.first);
    }
    return null;
  }

  Future<Iterable<KeyEvidenceModel>?> getByVisitId(String? visit_id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ["*"], where: 'visit_id = ?', whereArgs: [visit_id]);
    if (maps.isNotEmpty) {
      return maps.map((e) => KeyEvidenceModel(
            keyEvidenceId: e['key_evidence_id'],
            description: e['key_evidence_description'],
            visitId: e['visit_id'],
            nesId: e['nes_id'],
            requirementId: e['requirement_id'],
            nesLevelId: e['nes_level_id'],
            keyEvidenceStatus: e['key_evidence_status'],
            createdAt: e['created_at'],
          ));
      return null;
    }
  }

  Future<KeyEvidenceModel?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'], where: 'visit_id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return KeyEvidenceModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(table, where: 'visit_id = ?', whereArgs: [id]);
  }

  Future<bool> truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $table");
    return true;
  }

  Future<int> update(KeyEvidenceModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(table, nes.toJson(),
        where: 'visit_id = ?', whereArgs: [nes.id]);
  }

  syncUpdatesToServer(String offlineVisitId, onlineVisitId, Map<String, String> headers) async{
    await syncToServer(offlineVisitId, onlineVisitId, headers);
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'sync = ? and visit_id = ?',
        whereArgs: ['1', offlineVisitId]);
    if (maps.isNotEmpty) {
      var data = groupBy(
          maps.map((e) => KeyEvidenceModel(
            keyEvidenceId: e['key_evidence_id'],
            description: e['key_evidence_description'],
            visitId: e['visit_id'],
            nesId: e['nes_id'],
            requirementId: e['requirement_id'],
            nesLevelId: e['nes_level_id'],
            keyEvidenceStatus: e['key_evidence_status'],
            createdAt: e['created_at'],
          )),
              (KeyEvidenceModel d) => d.nesId);
      data.forEach((key, value) {
        var keyEvidenceObj =
        buildKeyEvidenceObj(value, onlineVisitId.toString());
        post(Uri.parse("${BaseApi.keyEvidencePath}/update/${keyEvidenceObj['key_evidence_id']}"),
            headers: headers, body: jsonEncode(keyEvidenceObj));
      });
    }
    return null;
  }
}
