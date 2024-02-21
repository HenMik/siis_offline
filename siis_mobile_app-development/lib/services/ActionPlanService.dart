import 'package:siis_offline/models/Inspection.dart';
import 'package:siis_offline/models/actionPlan.dart';
import 'package:siis_offline/screens/Inspector/ActionPlan.dart';

import '../db_helper/repository.dart';


class ActionPlanService
{
  late Repository _repository;
  ActionPlanService(){
    _repository = Repository();
  }
  //Save User
  SaveActionPlan(ActionPlanModel actionPlan) async{
    actionPlan.sync = '1';
    return await _repository.insertData('action_plans', actionPlan.actionPlanMap());
  }


  readAllActionPlans(String visit_id) async{
    return await _repository.readAPData('action_plans', visit_id);
  }

  readDate(String visit_id) async{
    return await _repository.readDate('action_plans',visit_id);
  }
  readAllInspectionsByZone(String zoneId) async{
    return await _repository.readDataByZone('inspections', zoneId);
  }


  UpdateInspection(Inspection inspection) async{
    inspection.sync = '2';
    return await _repository.updateData('action_plans', inspection.inspectionMap());
  }


  updateAction(ActionPlanModel action_Plan) async{
    return await _repository.updateAction('action_plans', action_Plan.actionPlanMap());
  }

  deleteActionplan(actionId) async {
    return await _repository.deleteAction('action_plans', actionId);
  }

}