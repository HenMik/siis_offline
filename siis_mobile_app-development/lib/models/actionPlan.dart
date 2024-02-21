import 'dart:convert';

import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

var tableName = "action_plans";

class ActionPlanModel{
  int? id;
  var activityName;
  var activityStartDate;
  var activityFinishDate;
  var activityStatus;
  var activityBudget;
  var recommendationId;
  var priorityId;
  var visitId;
  var statusRemarks;
  var createdAt;
  var sync;



  actionPlanMap() {
    var mapping = Map<String, dynamic>();
    mapping['action_plan_id'] = id ?? null;
    mapping['activity_name'] = activityName!;
    mapping['activity_start_date'] = activityStartDate!;
    mapping['activity_finish_date'] = activityFinishDate!;
    mapping['activity_status'] = activityStatus!;
    mapping['activity_budget'] = activityBudget!;
    mapping['recommendation_id'] = recommendationId!;
    mapping['visit_id'] = visitId!;
    mapping['status_remarks'] = statusRemarks!;
    mapping['created_at'] = createdAt!;
    mapping['sync'] = sync;

    return mapping;
  }
  
}


class ActionPlan {
  late var actionPlanId;
  late var activityName;
  late var activityStartDate;
  late var activityFinishDate;
  late var activityStatus;
  late var activityBudget;
  late var recommendationId;
  late var priorityId;
  late var statusRemarks;
  late var visitId;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{'action_plan_id': actionPlanId, 'activity_name': activityName, 'activity_start_date': activityStartDate, 'activity_finish_date': activityFinishDate,
      'activity_status': activityStatus, 'activity_budget':activityBudget, 'recommendation_id':recommendationId, 'priority_id':priorityId, 'status_remarks': statusRemarks, 'visit_id': visitId};
    return map;
  }

  ActionPlan({required this.actionPlanId, required this.activityName, required this.activityStartDate, required this.activityFinishDate, required this.activityStatus, required this.activityBudget,
    required this.recommendationId, required this.priorityId, required this.statusRemarks, required this.visitId});

  ActionPlan.fromMap(Map<String, Object?> map) {
    actionPlanId = map['action_plan_id'];
    activityName = map['activity_name'];
    activityStartDate  = map['activity_start_date'];
    activityFinishDate = map['activity_finish_date'];
    activityStatus = map['activity_status'] ;
    activityBudget = map['activity_budget'];
    recommendationId = map['recommendation_id'];
    priorityId = map['priority_id'];
    statusRemarks = map['status_remarks'];
    visitId = map['visit_id'];
  }
}

class ActionPlanProvider {

  Future<bool> sync(headers) async {
    ActionPlan? standard = await ActionPlanProvider().getFirst();
    if(standard == null){
      print("$tableName is empty. syncing...");
      ActionPlanProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.actionPlanPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var map in results) {
        ActionPlan standard = ActionPlan(
            actionPlanId: map['action_plan_id'],
            activityName: map['activity_name'],
            activityStartDate: map['activity_start_date'],
            activityFinishDate: map['activity_finish_date'],
            activityStatus: map['activity_status'],
            activityBudget: map['activity_budget'],
            recommendationId: map['recommendation_id'],
            priorityId: map['priority_id'],
            statusRemarks: map['status_remarks'],
            visitId: map['visit_id']
        );
        ActionPlanProvider().insert(standard);
      }
    }
    return true;
  }

  Future<ActionPlan> insert(ActionPlan category) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(tableName, category.toMap());
    return category;
  }

  Future<ActionPlan?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName);
    if (maps.isNotEmpty) {
      return ActionPlan.fromMap(maps.first);
    }
    return null;
  }

  Future<Iterable<ActionPlan>?> getToSync(int? recommendationId) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'sync = ? and recommendation_id = ?',
        whereArgs: ['1', recommendationId]);
    if (maps.isNotEmpty) {
      return maps.map((map) => ActionPlan(
          actionPlanId: map['action_plan_id'],
          activityName: map['activity_name'],
          activityStartDate: map['activity_start_date'],
          activityFinishDate: map['activity_finish_date'],
          activityStatus: map['activity_status'],
          activityBudget: map['activity_budget'],
          recommendationId: map['recommendation_id'],
          priorityId: map['priority_id'],
          statusRemarks: map['status_remarks'],
          visitId: map['visit_id']
      ));
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.delete(tableName, where: 'action_plan_id = ?', whereArgs: [id]);
  }

  Future<bool>truncate() async {
    Database db = await DatabaseConnection().setDatabase();
    db.execute("DELETE FROM $tableName");
    return true;
  }

  Future<int> update(ActionPlan category) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(tableName, category.toMap(),
        where: 'action_plan_id = ?', whereArgs: [category.actionPlanId]);
  }

  Future<Iterable<ActionPlan>?> getToEdit() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: ['*'],
        where: 'sync = ?',
        whereArgs: ['2']);
    if (maps.isNotEmpty) {
      return maps.map((map) => ActionPlan(
          actionPlanId: map['action_plan_id'],
          activityName: map['activity_name'],
          activityStartDate: map['activity_start_date'],
          activityFinishDate: map['activity_finish_date'],
          activityStatus: map['activity_status'],
          activityBudget: map['activity_budget'],
          recommendationId: map['recommendation_id'],
          priorityId: map['priority_id'],
          statusRemarks: map['status_remarks'],
          visitId: map['visit_id']
      ));
    }
    return null;
  }
}