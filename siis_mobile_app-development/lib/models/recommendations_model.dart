import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/models/model.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';
import 'actionPlan.dart';

String table = "recommendations";

class RecommendationModel extends Model {
  static String table = table;

  var recoId;
  var description;
  var nesCategory;
  var recommendationType;
  var visitId;
  var createdAt;
  var nesId;

  RecommendationModel(
      {this.recoId,
      this.description,
      this.nesCategory,
      this.createdAt,
      this.nesId,
      this.visitId,
      this.recommendationType});

  static RecommendationModel fromMap(Map<String, Object?> json) {
    return RecommendationModel(
      recoId: json['recommendation_id'],
      description: json['recommendation_description'],
      nesCategory: json['category_id'],
      recommendationType: json['recommendation_type'],
      visitId: json['visit_id'],
      nesId: json['nes_id'],
      createdAt: json['created_at'],
    );
  }

  @override
  Map<String, Object?> toJson() {
    Map<String, Object?> map = {
      'recommendation_id': recoId,
      'recommendation_description': description,
      'visit_id': visitId,
      'nes_id': nesId,
      'created_at': createdAt,
      'category_id': nesCategory,
      'recommendation_type': recommendationType,
    };
    return map;
  }
}

class RecommendationModelProvider {
  Future<bool> sync(headers) async {
    RecommendationModel? standard =
        await RecommendationModelProvider().getFirst();
    if (standard == null) {
      print("$table is empty. syncing...");
      Response response =
          await get(Uri.parse(BaseApi.recommendationPath), headers: headers);
      List results = jsonDecode(response.body);

      for (var json in results) {
        RecommendationModel standard = RecommendationModel(
          recoId: json['recommendation_id'],
          description: json['recommendation_description'],
          nesCategory: json['category_id'],
          recommendationType: json['recommendation_type'],
          visitId: json['visit_id'],
          nesId: json['nes_id'],
          createdAt: json['created_at'],
        );

        RecommendationModelProvider().insert(standard);
      }
    }
    return true;
  }

  Future<RecommendationModel> insert(RecommendationModel nes) async {
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
      var recommendations = maps.map((e) => RecommendationModel(
            recoId: e['recommendation_id'],
            description: e['recommendation_description'],
            nesCategory: e['category_id'],
            recommendationType: e['recommendation_type'],
            visitId: e['visit_id'],
            nesId: e['nes_id'],
            createdAt: e['created_at'],
          ));
      for (var r in recommendations!) {
        r.visitId = onlineVisitId;
        Response resp = await post(Uri.parse(BaseApi.recommendationPath),
            headers: headers, body: jsonEncode(r.toJson()));
        var recom = jsonDecode(resp.body);
        var recommendationId = recom['data']['recommendation_id'];
        var actionPlans = await ActionPlanProvider().getToSync(r.recoId);
        if (actionPlans != null) {
          for (var action in actionPlans) {
            action.recommendationId = recommendationId;
            action.visitId = onlineVisitId;
            post(Uri.parse(BaseApi.actionPlanPath),
                headers: headers, body: jsonEncode(action.toMap()));
          }
        }
      }
      return true;
    }
    return null;
  }

  Future<RecommendationModel?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table);
    if (maps.isNotEmpty) {
      return RecommendationModel.fromMap(maps.first);
    }
    return null;
  }

  Future<RecommendationModel?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'], where: 'visit_id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return RecommendationModel.fromMap(maps.first);
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

  Future<int> update(RecommendationModel nes) async {
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
        whereArgs: ['2', onlineVisitId]);
    if (maps.isNotEmpty) {
      var recommendations = maps.map((e) => RecommendationModel(
        recoId: e['recommendation_id'],
        description: e['recommendation_description'],
        nesCategory: e['category_id'],
        recommendationType: e['recommendation_type'],
        visitId: e['visit_id'],
        nesId: e['nes_id'],
        createdAt: e['created_at'],
      ));
      for (var r in recommendations!) {
        patch(Uri.parse("${BaseApi.recommendationPath}/major/update/${r.recoId}"),
            headers: headers, body: jsonEncode(r.toJson()));
      }
      var actionPlans = await ActionPlanProvider().getToEdit();
      if(actionPlans != null) {
        for (var action in actionPlans) {
          patch(Uri.parse("${BaseApi.actionPlanPath}/update/${action.actionPlanId}"),
              headers: headers, body: jsonEncode(action.toMap()));
        }
      }
      return true;
    }
    return null;
  }
}
