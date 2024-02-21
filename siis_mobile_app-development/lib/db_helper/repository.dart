import 'package:siis_offline/utils/account_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'database_connection.dart';

class Repository {
  late DatabaseConnection _databaseConnection;
  Repository() {
    _databaseConnection= DatabaseConnection();
  }
  static Database? _database;
  Future<Database?>get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _databaseConnection.setDatabase();
      return _database;
    }
  }
  insertData(table, data) async {
    var connection = await database;
    return await connection?.insert(table, data);
  }
  insertRecommendation(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection?.insert(table, data);
  }
  insertKeyEvidence(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection?.insert(table, data);
  }
  insertNesNotifications(table, data) async {
    var connection = await database;
    return await connection?.insert(table, data);
  }
  insertAreaOfImprovement(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection?.insert(table, data);
  }
  insertCriticalIssues(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection?.insert(table, data);
  }
  insertGoodPractices(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection?.insert(table, data);
  }
  insertMajorStrengths(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection?.insert(table, data);
  }
  readDataByVisitType(table, String sectorId) async {
    var connection = await database;
    return await connection?.rawQuery("SELECT inspections.*, schools.* from inspections INNER JOIN schools "
        "ON schools.emis_id = inspections.emis_id where inspections.visit_type_id = 2 and schools.sector_id = $sectorId"
        " order by inspections.present_visitation_date desc");
  }


  readRecoByVisitId(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT recommendations.*, inspections.* from recommendations INNER JOIN inspections ON inspections.visit_id = recommendations.visit_id where recommendations.visit_id = $visitId AND recommendations.recommendation_type = 'Major'");
  }
  readRecoByVisitIdAndType(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT recommendations.*, inspections.* from recommendations INNER JOIN inspections ON inspections.visit_id = recommendations.visit_id where recommendations.visit_id = $visitId and recommendation_type = 'Minor'");
  }
  readCriticByVisitId(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT critical_issues.*, inspections.* from critical_issues INNER JOIN inspections ON inspections.visit_id = critical_issues.visit_id where critical_issues.visit_id = $visitId");
  }
  readAreaOfImprovementByVisitId(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT weaknesses.*, inspections.* from weaknesses INNER JOIN inspections ON inspections.visit_id = weaknesses.visit_id where weaknesses.visit_id = $visitId");
  }
  
  readGoodPracticesByVisitId(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT good_practices.*, inspections.* from good_practices INNER JOIN inspections ON inspections.visit_id = good_practices.visit_id where good_practices.visit_id = $visitId");
  }
  readKeyEvidence(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT key_evidence.*, inspections.* from key_evidence INNER JOIN inspections ON inspections.visit_id = key_evidence.visit_id  where key_evidence.visit_id = $visitId");
  }
  readKeyEvidenceByRequirement(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT key_evidence.*, national_standards.nes_name, nes_requirements.*, "
        "nes_levels.nes_level_name, recommendations.* FROM key_evidence, inspections, national_standards, nes_levels, nes_requirements, recommendations "
        "WHERE inspections.visit_id = key_evidence.visit_id	"
        "AND national_standards.nes_id = key_evidence.nes_id "
        "AND nes_levels.nes_level_id	 = key_evidence.nes_level_id "
        "AND national_standards.nes_id = nes_requirements.nes_id "
        "AND key_evidence.requirement_id = nes_requirements.requirement_id "
        "AND key_evidence.nes_id = recommendations.nes_id "
        "AND key_evidence.visit_id = $visitId "
        "AND recommendations.recommendation_type = 'Minor' "
        "AND recommendations.visit_id = $visitId "
        "GROUP BY key_evidence.key_evidence_id "
        "ORDER BY key_evidence.nes_id - 0 asc"
        );
  }
  readKeyEvidenceByNesId(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT key_evidence.*, national_standards.nes_name, nes_requirements.requirement_name, "
    "nes_levels.nes_level_name, recommendations.* FROM key_evidence, inspections, national_standards, nes_levels, nes_requirements, recommendations "
        "WHERE inspections.visit_id = key_evidence.visit_id	"
        "AND national_standards.nes_id = key_evidence.nes_id "
        "AND nes_levels.nes_level_id	 = key_evidence.nes_level_id "
        "AND national_standards.nes_id = nes_requirements.nes_id "
        "AND key_evidence.requirement_id = nes_requirements.requirement_id "
        "AND key_evidence.nes_id = recommendations.nes_id "
        "AND key_evidence.visit_id = $visitId "
        "AND recommendations.recommendation_type = 'Minor' "
        "AND recommendations.visit_id = $visitId "
        "GROUP BY key_evidence.nes_id "
        "ORDER BY national_standards.nes_id asc"
    );
  }

  readKeyByNes(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT nes_id from key_evidence where visit_id = '$visitId' GROUP BY nes_id"
    );
  }
  readRequirementsAchieved(table, visitId) async {
    var connection = await database;
    return await connection?.rawQuery("SELECT `key_evidence`.`visit_id` AS `visit_id`,`key_evidence`.`nes_id` AS `nes_id`,"
    "`key_evidence`.`nes_level_id` AS `nes_level_id`,COUNT(`key_evidence`.`nes_level_id`) AS `achieved`,"
        "`requirements_counts`.`requirement_count` AS `out_of`"
        "FROM (`key_evidence` INNER JOIN `requirements_counts` ON `key_evidence`.`nes_id`=`requirements_counts`.`nes_id`)"
    "WHERE ((`key_evidence`.`nes_level_id`=`requirements_counts`.`nes_level_id`) AND (`key_evidence`.`key_evidence_status`='Positive')) AND  (`key_evidence`.`visit_id`=$visitId)"
    "GROUP BY `key_evidence`.`nes_id`,`key_evidence`.`visit_id`,`key_evidence`.`nes_level_id`,"
    "`requirements_counts`.`requirement_count` ORDER BY `requirements_counts`.`nes_id` + 0 ASC"
    );
  }
  readRequirementsAchievedAndNes(table, visitId, nesId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT key_evidence.*, national_standards.nes_name, nes_requirements.requirement_name, "
        "nes_levels.nes_level_name, recommendations.recommendation_description FROM "
        "key_evidence, inspections, national_standards, nes_levels, nes_requirements, recommendations WHERE "
        "inspections.visit_id = key_evidence.visit_id	AND "
        "national_standards.nes_id = key_evidence.nes_id AND "
        "nes_levels.nes_level_id = key_evidence.nes_level_id AND "
        "national_standards.nes_id = nes_requirements.nes_id AND "
        "nes_requirements.requirement_id = key_evidence.requirement_id AND "
        "recommendations.nes_id = key_evidence.nes_id AND key_evidence.visit_id = $visitId AND key_evidence.nes_id = $nesId "
        "GROUP BY key_evidence.key_evidence_id order by key_evidence.nes_id asc"
    );
  }
  readNesLevelAchieved(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT `key_evidence`.`visit_id` AS `visit_id`,`key_evidence`.`nes_id` AS `nes_id`,"
        "`key_evidence`.`nes_level_id` AS `nes_level_id`,COUNT(`key_evidence`.`nes_level_id`) AS `achieved`,"
        "`requirements_counts`.`requirement_count` AS `out_of`"
        "FROM (`key_evidence` INNER JOIN `requirements_counts` ON `key_evidence`.`nes_id`=`requirements_counts`.`nes_id`)"
        "WHERE ((`key_evidence`.`nes_level_id`=`requirements_counts`.`nes_level_id`) AND (`key_evidence`.`key_evidence_status`='Positive')) AND  (`key_evidence`.`visit_id`=$visitId)"
        "GROUP BY `key_evidence`.`nes_id` ORDER BY `key_evidence`.nes_id + 0 ASC"
    );
  }
  readMajorStrengthsByVisitId(table, visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT strengths.*, inspections.* from strengths INNER JOIN inspections ON inspections.visit_id = strengths.visit_id where strengths.visit_id = $visitId");
  }
  readData(table, var sectorId) async {
    sectorId = int.parse(sectorId);
    var connection = await database;
    return await connection?.rawQuery("SELECT inspections.*, schools.school_name,"
        "zones.zone_name, districts.district_name, divisions.division_name FROM inspections, schools, zones,"
        "districts, divisions WHERE inspections.emis_id = schools.emis_id "
        "AND schools.zone_id = zones.zone_id AND zones.district_id = districts.district_id AND "
        "districts.division_id = divisions.division_id AND schools.sector_id = $sectorId AND inspections.visit_type_id = '1' order by inspections.present_visitation_date desc");
  }
  readDate(table, visit_id) async{
    var connection = await database;
    return await connection?.rawQuery("SELECT activity_start_date from action_plans where visit_id = $visit_id order by activity_start_date asc");
  }


  readDataZoneId(table, var sectorId, var zoneId) async {
    sectorId = int.parse(sectorId);
    var connection = await database;
    return await connection?.rawQuery("SELECT inspections.*, schools.school_name,"
        "zones.zone_name, districts.district_name, divisions.division_name FROM inspections, schools, zones,"
        "districts, divisions WHERE inspections.emis_id = schools.emis_id "
        "AND schools.zone_id = zones.zone_id AND zones.district_id = districts.district_id AND "
        "districts.division_id = divisions.division_id AND schools.sector_id = $sectorId AND inspections.visit_type_id = '1' AND inspections.zone_id = $zoneId order by inspections.present_visitation_date desc");
  }
  readDataByVisitId(table, var visitId) async {
    visitId = int.parse(visitId);
    var connection = await database;
    return await connection?.rawQuery("SELECT inspections.*, schools.school_name,"
        "zones.zone_name, districts.district_name, divisions.division_name FROM inspections, schools, zones,"
        "districts, divisions WHERE inspections.emis_id = schools.emis_id "
        "AND schools.zone_id = zones.zone_id AND zones.district_id = districts.district_id AND "
        "districts.division_id = divisions.division_id AND inspections.visit_id = $visitId order by inspections.present_visitation_date desc");
  }
  readAPData(table, visit_id) async {

    var connection = await database;
    return await connection?.rawQuery("SELECT * from action_plans where visit_id = $visit_id order by activity_start_date asc");
  }
  readPercentageInspection(table, var sectorId) async {
    sectorId = int.parse(sectorId);
    var connection = await database;
    return await connection?.rawQuery("SELECT CAST(inspections.present_visitation_date as date) as year, COUNT(DISTINCT inspections.emis_id) as total_inspection, schools.*"
        " FROM inspections, schools WHERE inspections.emis_id = schools.emis_id and "
        "schools.sector_id = $sectorId  "
        "GROUP BY year order by inspections.present_visitation_date asc");
  }
  readSchoolFromInspection(table, var sectorId) async {
    sectorId = int.parse(sectorId);
    var connection = await database;
    return await connection?.rawQuery("SELECT * from inspections where sector_id = $sectorId group by emis_id");
  }
  readNesNotifications(table, var nesId, var visitId) async {
    var connection = await database;
    return await connection?.rawQuery("SELECT * from nes_notifications where nes_id = $nesId and visit_id = $visitId");
  }
  readDataByZone(table, zoneId) async {
    var connection = await database;
    return await connection?.rawQuery("SELECT inspections.*, schools.* from inspections INNER JOIN schools ON schools.emis_id = inspections.emis_id where schools.zone_id = $zoneId");
  }
  readSEdate(table, recoId) async {
    var connection = await database;
    return await connection?.rawQuery("SELECT MIN(activity_start_date) AS start_date, MAx(activity_finish_date) AS end_date From action_plans  where recommendation_id = $recoId");
  }
  readDataById(table, itemId) async {
    var connection = await database;
    return await connection?.query(table, where: 'id=?', whereArgs: [itemId]);
  }
  updateData(table, data) async {
    var connection = await database;
    return await connection
        ?.update(table, data, where: 'visit_id=?', whereArgs: [data['visit_id']]);
  }
  updateReco(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection
        ?.update(table, data, where: 'recommendation_id=?', whereArgs: [data['recommendation_id']]);

  }
  updateInsp(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection
        ?.update(table, data, where: 'visit_id=?', whereArgs: [data['visit_id']]);

  }
  updateAction(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection
        ?.update(table, data, where: 'action_plan_id=?', whereArgs: [data['action_plan_id']]);
  }
  updateMajor(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection
        ?.update(table, data, where: 'strength_id=?', whereArgs: [data['strength_id']]);
  }
  updateGoodPractice(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection
        ?.update(table, data, where: 'good_practice_id=?', whereArgs: [data['good_practice_id']]);
  }
  UpdateAreaOfImprovement(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection
        ?.update(table, data, where: 'weakness_id=?', whereArgs: [data['weakness_id']]);
  }
  UpdateCriticalIssue(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection
        ?.update(table, data, where: 'critical_issue_id=?', whereArgs: [data['critical_issue_id']]);
  }
  UpdateRecommendation(table, data) async {
    var connection = await database;
    await connection?.rawUpdate("update inspections set sync=1 where visit_id = ${data['visit_id']}");
    return await connection
        ?.update(table, data, where: 'recommendation_id=?', whereArgs: [data['recommendation_id']]);
  }
  deleteGoodPractice(table, itemId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where good_practice_id=$itemId");
  }
  deleteCriticalIssue(table, itemId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where critical_issue_id=$itemId");
  }
  deleteNesNotifications(table, nesId, visitId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where nes_id=$nesId and visit_id=$visitId");
  }

  deleteAreaOfImprovement(table, itemId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where weakness_id=$itemId");
  }

  deleteMajor(table, itemId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where strength_id=$itemId");
  }
  deleteKeyEvidence(table, nesId, visitId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where key_evidence.nes_id = $nesId and key_evidence.visit_id = $visitId");
  }
  deleteRecommendation(table, nesId, visitId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where recommendations.nes_id = '$nesId' and recommendations.visit_id = '$visitId'");
  }
  deleteAction(table, actionPlanId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where action_plan_id = $actionPlanId");
  }
  deleteDataById(table, itemId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where visit_id=$itemId");
  }
  deleteRecommendation2(table, recoId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where recommendation_id  = $recoId" );
  }
  deleteActionByRecommendation(table, recoId) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where recommendation_id = $recoId");
  }

}
