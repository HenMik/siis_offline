import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseConnection {
  final String databaseName = "siis";

  static Future<Database> getDatabaseInstance() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, "siis");
    var database = await openDatabase(path, version: 1);
    return database;
  }

  Future<Database> setDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, databaseName);
    var database =
        await openDatabase(path, version: 1, onCreate: _createDatabase);
    return database;
  }

  Future<void> _createDatabase(Database database, int version) async {
    String inspectionsTable =
        "CREATE TABLE inspections (visit_id INTEGER PRIMARY KEY, 	emis_id text, head_teacher text,	phone_number text,"
        "present_visitation_date text,	prev_visitation_date text,	lead_inspector_id text,	first_inspector_id text,	"
        "second_inspector_id text, expiry_date text,	third_inspector_id text,	fourth_inspector_id text,	school_address text,	establishment_year"
        " text,	enrolment_boys text,	enrolment_girls text,	attendance_boys text,	attendance_girls text,	number_of_teachers text,"
        "	unqualified_teachers text,	publication_date text, establishment text,	action_plan_date text,	next_inspection_date text,	zone_id text,	"
        "sector_id text,	district_id text,	division_id text,	lead_advisor_id text,	govt_chair_id text,	visit_type_id text,	assoc_visit "
        "text, sync text)";
    await database.execute(inspectionsTable);


    String recommendationTable = "CREATE table recommendations (recommendation_id INTEGER PRIMARY KEY,	recommendation_description text,"
        "recommendation_type text,	nes_id text,	category_id text,	visit_id text,	need_extra_followup text, followup_comments text, extra_comments text,	created_at text,"
        "	updated_at text, sync text)";
    await database.execute(recommendationTable);

    String keyEvidenceTable = "CREATE table key_evidence (key_evidence_id INTEGER PRIMARY KEY,	key_evidence_description text,"
        "	key_evidence_status text,	include_in_ir text,	visit_id text,	nes_id text,	requirement_id text,	nes_level_id text,	created_at text,	updated_at text, sync text)";
    await database.execute(keyEvidenceTable);

    String ActionPlansTable = "CREATE table action_plans(action_plan_id INTEGER PRIMARY KEY,	activity_name text,	activity_start_date text,	activity_finish_date text,	activity_status text,	activity_budget text,	recommendation_id text,	"
        "priority_id text,	visit_id text,	status_remarks text,	created_at text,	updated_at text, sync text)";
    await database.execute(ActionPlansTable);


    String nesNotifications = "CREATE table nes_notifications(notification_id	INTEGER PRIMARY KEY, nes_id text, visit_id text,	department_id text)";
    await database.execute(nesNotifications);

    String strengthTable = "CREATE table strengths( strength_id INTEGER PRIMARY KEY,	strength_description text,	visit_id text,	created_at text,	updated_at text, sync text)";
    await database.execute(strengthTable);

    String weaknessesTable = "CREATE table weaknesses(  weakness_id INTEGER PRIMARY KEY,	weakness_description text,	visit_id text,	created_at text,	updated_at text, sync text)";
    await database.execute(weaknessesTable);

    String criticalIssuesTable = "CREATE table critical_issues(   critical_issue_id INTEGER PRIMARY KEY,	critical_issue_description text,	visit_id text,	created_at text,	updated_at text, sync text)";
    await database.execute(criticalIssuesTable);

    String goodPracticesTable = "CREATE table good_practices(   good_practice_id INTEGER PRIMARY KEY,	good_practice_description text,	visit_id text,	created_at text,	updated_at text, sync text)";
    await database.execute(goodPracticesTable);

    String nationalStandardsTable =
        "CREATE table national_standards (nes_id INTEGER PRIMARY KEY, nes_name text not null, category_id integer not null, sync text)";
    await database.execute(nationalStandardsTable);

    String districtTable = "CREATE TABLE districts("
        "district_id int primary key,"
        "district_name text,"
        "division_id int, sync text)";
    await database.execute(districtTable);

    String divisionsTable = "CREATE TABLE divisions("
        "division_id int primary key,"
        "division_name text, sync text)";
    await database.execute(divisionsTable);

    String zonesTable = "CREATE TABLE zones("
        "zone_id int primary key,"
        "zone_name text,"
        "district_id int,"
        "sector_id int, sync text)";
    await database.execute(zonesTable);

    String nesCategoryTable = "CREATE TABLE nes_categories("
        "category_id int primary key,"
        "category_name text, sync text DEFAULT '0' NOT NULL)";
    await database.execute(nesCategoryTable);

    String nesLevelsTable = "CREATE TABLE nes_levels("
        "nes_level_id int primary key,"
        "nes_level_name text, sync text DEFAULT '0' NOT NULL)";
    await database.execute(nesLevelsTable);

    String nesRequirementsTable = "CREATE TABLE nes_requirements("
        "nes_id int,"
        "requirement_id int,"
        "nes_level_id int,"
        "requirement_name text, sync text DEFAULT '0' NOT NULL)";
    await database.execute(nesRequirementsTable);

    String schoolName = "CREATE TABLE schools("
        "emis_id int primary key,"
        "school_name text,"
        "establishment_type text,"
        "division_id int,"
        "district_id int,"
        "zone_id int,"
        "sector_id int, sync text DEFAULT '0' NOT NULL)";
    await database.execute(schoolName);

    String nesLevelAchievement = "CREATE TABLE nes_level_achievements(id int primary key,	nes_level_achieved text,"
        "	nes_id text)";
    await database.execute(nesLevelAchievement);

    String requirementsCount = "CREATE TABLE requirements_counts( requirement_count_id int primary key,	nes_id text,	nes_level_id text,"
        "	requirement_count text)";
    await database.execute(requirementsCount);


    String userTable = "CREATE TABLE users("
        "user_id int primary key,"
        "first_name text,"
        "middle_name text,"
        "last_name text,"
        "user_name text,"
        "user_role text,"
        "user_phone text,"
        "user_email text,"
        "sector_id int,"
        "emis_id int,"
        "zone_id int,"
        "district_id int,"
        "division_id int, sync text DEFAULT '0' NOT NULL)";
    await database.execute(userTable);
  }
}
