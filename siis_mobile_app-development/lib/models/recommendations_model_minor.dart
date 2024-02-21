import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/models/model.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

String table = "recommendations";

class RecommendationMinorModel extends Model{

  static String table = table;

  var recoId;
  var description;
  var nesCategory;
  var recommendationType;
  var visitId;
  var createdAt;
  var nesId;

  RecommendationMinorModel({
    this.recoId,
    this.description,
    this.nesCategory,
    this.createdAt,
    this.nesId,
    this.visitId,
    this.recommendationType
  });


  static RecommendationMinorModel fromMap(Map<String, Object?> json)
  {
    return RecommendationMinorModel(
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
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {
      'recommendation_id': recoId,
      'recommendation_description': description,
      'visit_id': visitId,
      'nes_id': nesId,
      'created_at': createdAt,
      'category_id': nesCategory,
      'recommendation_type':recommendationType,
    };
    return map;
  }
}

class RecommendationMinorModelProvider {

  Future<bool> sync(headers) async {
    RecommendationMinorModel? standard = await RecommendationMinorModelProvider().getOne('Minor');
    if(standard == null){
      print("Minor recommendation is empty. syncing...");
      Response response =
      await get(Uri.parse(BaseApi.minorRecommendationPath), headers: headers);
      List results = jsonDecode(response.body);

      for (var json in results) {
        RecommendationMinorModel standard = RecommendationMinorModel(
          recoId: json['recommendation_id'],
          description: json['recommendation_description'],
          nesCategory: json['category_id'],
          recommendationType: json['recommendation_type'],
          visitId: json['visit_id'],
          nesId: json['nes_id'],
          createdAt: json['created_at'],

        );

        RecommendationMinorModelProvider().insert(standard);
      }
    }
    return true;
  }

  Future<RecommendationMinorModel> insert(RecommendationMinorModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(table, nes.toJson());
    return nes;
  }

  Future<Iterable<RecommendationMinorModel>?> getToSync() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'sync = ?',
        whereArgs: ['1']);
    if (maps.isNotEmpty) {
      print(maps);
      return maps.map((e) => RecommendationMinorModel(
        recoId: e['recommendation_id'],
        description: e['recommendation_description'],
        nesCategory: e['category_id'],
        recommendationType: e['recommendation_type'],
        visitId: e['visit_id'],
        nesId: e['nes_id'],
        createdAt: e['created_at'],

      ));
  }
    return null;
  }

  Future<RecommendationMinorModel?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table);
    if (maps.isNotEmpty) {
      return RecommendationMinorModel.fromMap(maps.first);
    }
    return null;
  }

  Future<RecommendationMinorModel?> getOne(String type) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'recommendation_type = ?',
        whereArgs: [type]);
    if (maps.isNotEmpty) {
      return RecommendationMinorModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(table, where: 'visit_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $table");
    return true;
  }

  Future<int> update(RecommendationMinorModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(table, nes.toJson(),
        where: 'visit_id = ?', whereArgs: [nes.id]);
  }
}

