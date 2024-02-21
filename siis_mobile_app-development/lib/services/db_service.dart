import 'dart:convert';


import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:siis_offline/models/inspector_model.dart';
import 'package:siis_offline/utils/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class DBService{
  Future<List<InspectorModel>>getProducts() async{
    await DBHelper.init();

    List<Map<String, dynamic>> products =
    await DBHelper.query(InspectorModel.table);

    return products.map((item) => InspectorModel.fromMap(item)).toList();
  }
  Future<List<InspectorModel>>getDetails() async{
    Database siis = await DatabaseConnection.getDatabaseInstance();
    var details = await siis.query('inspections', orderBy: 'visit_id ');
    List<InspectorModel> DetailsList = details.isNotEmpty?
    details.map((c) => InspectorModel.fromMap(c)).toList()
        :[];
    return DetailsList;
  }

  Future<bool> addProduct(InspectorModel model) async {
    await DBHelper.init();
    int ret = await DBHelper.insert(InspectorModel.table, model);
    return ret > 0 ? true: false;
  }
  Future<bool> updateProduct(InspectorModel model) async {
    await DBHelper.init();
    int ret = await DBHelper.update(InspectorModel.table, model);
    return ret > 0 ? true: false;
  }
  Future<bool> deleteProduct(InspectorModel model) async {
    await DBHelper.init();
    int ret = await DBHelper.delete(InspectorModel.table, model);
    return ret > 0 ? true: false;
  }
}