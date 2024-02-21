import 'dart:convert';

import 'package:http/http.dart';
import 'package:siis_offline/models/model.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

String table = "inspections";

class FollowUpModel extends Model{

  static String table = table;

  var visitId;
  var divisionId;
  var zoneId;
  var schoolId;
  var headTeacher;
  var phoneNumber;
  var yearOfEstablishment;
  var nofqTeachers;
  var noufqTeachers;
  var totalEnrolledBoys;
  var totalEnrolledGirls;
  var totalAttendanceBoys;
  var totalAttendanceGirls;
  var visitType;
  var presentVisitationDate;
  var previousVisitationDate;
  var leadInspectorName;
  var firstInspectorName;
  var secondInspectorName;
  var thirdInspectorName;
  var fourthInspectorName;
  var actionPlanDate;
  var nextInspectionDate;
  var advisor;
  var schoolGovernanceChair;
  var districtId;
  var leadAdvisor;
  var visitTypeId;
  var sectorId;
  var attendanceGirls;
  var expiryDate;
  var attendanceBoys;
  var schoolAddress;
  var assocVisit;


  FollowUpModel({
    this.visitId,
    this.schoolAddress,
    this.divisionId,
    this.zoneId,
    this.schoolId,
    this.headTeacher,
    this.phoneNumber,
    this.yearOfEstablishment,
    this.nofqTeachers,
    this.noufqTeachers,
    this.totalEnrolledBoys,
    this.totalEnrolledGirls,
    this.totalAttendanceBoys,
    this.totalAttendanceGirls,
    this.visitType,
    this.presentVisitationDate,
    this.previousVisitationDate,
    this.leadInspectorName,
    this.firstInspectorName,
    this.secondInspectorName,
    this.thirdInspectorName,
    this.fourthInspectorName,
    this.actionPlanDate,
    this.nextInspectionDate,
    this.advisor,
    this.schoolGovernanceChair,
    this.districtId,
    this.leadAdvisor,
    this.visitTypeId,
    this.sectorId,
    this.attendanceGirls,
    this.expiryDate,
    this.attendanceBoys,
    this.assocVisit,
  });


  static FollowUpModel fromMap(Map<String, Object?> json)
  {
    return FollowUpModel(
      visitId: json['visit_id'],
      divisionId: json['division_id'],
      zoneId: json['zone_id'],
      schoolId: json['emis_id'],
      sectorId: json['sector_id'],
      headTeacher: json['head_teacher'],
      phoneNumber: json['phone_number'],
      yearOfEstablishment: json['establishment_year'],
      nofqTeachers: json['number_of_teachers'],
      noufqTeachers: json['unqualified_teachers'],
      totalEnrolledBoys: json['enrolment_boys'],
      totalEnrolledGirls: json['enrolment_girls'],
      expiryDate: json['expiry_date'],
      presentVisitationDate: json['present_visitation_date'],
      previousVisitationDate: json['prev_visitation_date'],
      leadInspectorName: json['lead_inspector_id'],
      firstInspectorName: json['first_inspector_id'],
      secondInspectorName: json['second_inspector_id'],
      thirdInspectorName: json['third_inspector_id'],
      fourthInspectorName: json['fourth_inspector_id'],
      actionPlanDate: json['action_plan_ate'],
      nextInspectionDate: json['next_inspection_date'],
      advisor: json['lead_advisor_id'],
      schoolGovernanceChair: json['govt_chair_id'],
      districtId: ['district_id'],
      visitTypeId: ['visit_type_id'],
      attendanceGirls: ['attendance_boys'],
      attendanceBoys: ['attendance_girls'],
      schoolAddress: ['school_address'],
      assocVisit: ['assoc_visit']

    );
  }
  @override
  Map<String, Object?> toJson(){
    Map<String, Object?> map = {
      'visit_id': visitId,
      'division_id': divisionId,
      'zone_id': zoneId,
      'school_address': schoolAddress,
      'emis_id': schoolId,
      'head_teacher': headTeacher,
      'phone_number': phoneNumber,
      'establishment_year': yearOfEstablishment,
      'number_of_teachers': nofqTeachers,
      'unqualified_teachers': noufqTeachers,
      'enrolment_boys':totalEnrolledBoys,
      'enrolment_girls': totalEnrolledGirls,
      'present_visitation_date': presentVisitationDate,
      'prev_visitation_date': previousVisitationDate,
      'lead_inspector_id': leadInspectorName,
      'first_inspector_id': firstInspectorName,
      'second_inspector_id':secondInspectorName,
      'third_inspector_id': thirdInspectorName,
      'fourth_inspector_id':fourthInspectorName,
      'action_plan_date': actionPlanDate,
      'next_inspection_date':nextInspectionDate,
      'attendance_boys': attendanceBoys,
      'attendance_girls':attendanceGirls,
      'visit_type_id':visitTypeId,
      'govt_chair_id':schoolGovernanceChair,
      'lead_advisor_id':leadAdvisor,
      'sector_id':sectorId,
      'district_id': districtId,
      'assoc_visit': assocVisit
    };
    return map;
  }
}

class FollowUpModelProvider {

  Future<bool> sync(headers) async {
    FollowUpModel? standard = await FollowUpModelProvider().getOne(2);
    if(standard == null){
      print("$table is empty. syncing...");
      Response response =
      await get(Uri.parse(BaseApi.followUpPath), headers: headers);
      List results = jsonDecode(response.body);

      for (var json in results) {
        FollowUpModel standard = FollowUpModel(
          visitId: json['visit_id'],
          divisionId: json['division_id'],
          zoneId: json['zone_id'],
          schoolId: json['emis_id'],
          districtId: json['district_id'],
          headTeacher: json['head_teacher'],
          phoneNumber: json['phone_number'],
          yearOfEstablishment: json['establishment_year'],
          nofqTeachers: json['number_of_teachers'],
          noufqTeachers: json['unqualified_teachers'],
          totalEnrolledBoys: json['enrolment_boys'],
          totalEnrolledGirls: json['enrolment_girls'],
          visitType: json['visit_type'],
          presentVisitationDate: json['present_visitation_date'],
          previousVisitationDate: json['prev_visitation_date'],
          leadInspectorName: json['lead_inspector_id'],
          firstInspectorName: json['first_inspector_id'],
          secondInspectorName: json['second_inspector_id'],
          thirdInspectorName: json['third_inspector_id'],
          fourthInspectorName: json['fourth_inspector_id'],
          leadAdvisor: json['lead_advisor_id'],
          visitTypeId: json['visit_type_id'],
          actionPlanDate: json['action_plan_date'],
          nextInspectionDate: json['next_inspection_date'],
          attendanceBoys: json['attendance_boys'],
          attendanceGirls: json['attendance_girls'],
          schoolAddress: json['school_address'],
          schoolGovernanceChair: json['govt_chair_id'],
          sectorId: json['sector_id'],
          assocVisit: json['assoc_visit']
        );

        FollowUpModelProvider().insert(standard);
      }
    }
    return true;
  }

  Future<FollowUpModel> insert(FollowUpModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(table, nes.toJson());
    return nes;
  }

  Future<Iterable<FollowUpModel>?> getToSync() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'sync = ?',
        whereArgs: ['1']);
    if (maps.isNotEmpty) {
      print(maps);
      return maps.map((e) => FollowUpModel(
          visitId: e['visit_id'],
          divisionId: e['division_id'],
          zoneId: e['zone_id'],
          schoolId: e['emis_id'],
          districtId: e['district_id'],
          headTeacher: e['head_teacher'],
          phoneNumber: e['phone_number'],
          yearOfEstablishment: e['establishment_year'],
          nofqTeachers: e['number_of_teachers'],
          noufqTeachers: e['unqualified_teachers'],
          totalEnrolledBoys: e['enrolment_boys'],
          totalEnrolledGirls: e['enrolment_girls'],
          visitType: e['visit_type'],
          presentVisitationDate: e['present_visitation_date'],
          previousVisitationDate: e['prev_visitation_date'],
          leadInspectorName: e['lead_inspector_id'],
          firstInspectorName: e['first_inspector_id'],
          secondInspectorName: e['second_inspector_id'],
          thirdInspectorName: e['third_inspector_id'],
          fourthInspectorName: e['fourth_inspector_id'],
          leadAdvisor: e['lead_advisor_id'],
          visitTypeId: e['visit_type_id'],
          actionPlanDate: e['action_plan_date'],
          nextInspectionDate: e['next_inspection_date'],
          attendanceBoys: e['attendance_boys'],
          attendanceGirls: e['attendance_girls'],
          schoolAddress: e['school_address'],
          schoolGovernanceChair: e['govt_chair_id'],
          sectorId: e['sector_id'],
          assocVisit: e['assoc_visit']
      ));
  }
    return null;
  }

  Future<FollowUpModel?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table);
    if (maps.isNotEmpty) {
      return FollowUpModel.fromMap(maps.first);
    }
    return null;
  }

  Future<FollowUpModel?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'visit_type_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return FollowUpModel.fromMap(maps.first);
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

  Future<int> update(FollowUpModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(table, nes.toJson(),
        where: 'visit_id = ?', whereArgs: [nes.id]);
  }
}

