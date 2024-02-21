import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/base_api.dart';

const String tableName = 'nes_categories';

class NesCategory {
  late var categoryId;
  late var categoryName;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'category_id': categoryId, 'category_name': categoryName};
    return map;
  }

  NesCategory({required this.categoryId, required this.categoryName});

  NesCategory.fromMap(Map<String, Object?> map) {
    categoryId = map['category_id'];
    categoryName = map['category_name'];
  }
}

class NesCategoryProvider {

  Future<bool> sync(headers) async {
    NesCategory? standard = await NesCategoryProvider().getNationalStandard(1);
    if(standard?.categoryName == null){
      print("$tableName is empty. syncing...");
      NesCategoryProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.nesCategoriesPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var element in results) {
        NesCategory standard = NesCategory(
            categoryName: element['category_name'],
            categoryId: element['category_id']
        );
        NesCategoryProvider().insert(standard);
      }
    }
    return true;
  }

  Future<NesCategory> insert(NesCategory category) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, category.toMap());
    return category;
  }

  Future<NesCategory?> getNationalStandard(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['category_id', 'category_name'],
        where: 'category_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return NesCategory.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'category_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(NesCategory category) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, category.toMap(),
        where: 'category_id = ?', whereArgs: [category.categoryId]);
  }
}