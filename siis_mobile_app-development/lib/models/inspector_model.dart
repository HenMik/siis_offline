import 'dart:convert';
import 'package:http/http.dart';
import 'package:siis_offline/models/model.dart';
import 'package:sqflite/sqflite.dart';

import '../db_helper/database_connection.dart';
import '../utils/base_api.dart';

String table = "inspections";

class InspectorModel extends Model{

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
  var establishment;
  var assoc_visit;
  var sync;


  InspectorModel({
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
    this.establishment,
    this.sync,
    this.assoc_visit
  });


  static InspectorModel fromMap(Map<String, Object?> json)
  {
    return InspectorModel(
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
      assoc_visit: ['assoc_visit'],
      sync: ['sync']
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
      'establishment': establishment,
      'assoc_visit': assoc_visit,
      'sync': sync
    };
    return map;
  }
}

class InspectorModelProvider {

  Future<bool> sync(headers) async {
    InspectorModel? standard = await InspectorModelProvider().getFirst();
    if(standard == null){
      print("$table is empty. syncing...");
      InspectorModelProvider().truncate();
      Response response =
      await get(Uri.parse(BaseApi.schoolVisitPath), headers: headers);
      List results = jsonDecode(response.body);
      for (var json in results) {
        InspectorModel standard = InspectorModel(
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
          assoc_visit: json['assoc_visit'],
          sync: json['sync']
        );

        InspectorModelProvider().insert(standard);
      }
    }
    return true;
  }

  Future<InspectorModel> insert(InspectorModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(table, nes.toJson());
    return nes;
  }

  Future<Iterable<InspectorModel>?> getToSync() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'sync = ?',
        whereArgs: ['1']);
    if (maps.isNotEmpty) {
      return maps.map((e) => InspectorModel(
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
          establishment: e['establishment'],
          assoc_visit: e['assoc_visit'],
          sync: e['sync']
      ));
  }
    return null;
  }

  Future<InspectorModel?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table);
    if (maps.isNotEmpty) {
      return InspectorModel.fromMap(maps.first);
    }
    return null;
  }

  Future<InspectorModel?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'visit_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InspectorModel.fromMap(maps.first);
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

  Future<int> update(InspectorModel visit, String visit_id) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(table, visit.toJson(),
        where: 'visit_id = ?', whereArgs: [visit_id]);
  }
}
class InspectorModelProviderManualSync {

  Future<bool> sync(headers) async {
    InspectorModelProvider().truncate();
    Response response =
    await get(Uri.parse(BaseApi.schoolVisitPath), headers: headers);
    List results = jsonDecode(response.body);
    for (var json in results) {
      InspectorModel standard = InspectorModel(
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
          assoc_visit: json['assoc_visit'],
          sync: json['sync']
      );

      InspectorModelProvider().insert(standard);
    }

    return true;
  }

  Future<InspectorModel> insert(InspectorModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    await db.insert(table, nes.toJson());
    return nes;
  }

  Future<Iterable<InspectorModel>?> getToSync() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'sync = ?',
        whereArgs: ['1']);
    if (maps.isNotEmpty) {
      return maps.map((e) => InspectorModel(
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
          assoc_visit: e['assoc_visit'],
          establishment: e['establishment']
      ));
    }
    return null;
  }

  Future<InspectorModel?> getFirst() async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table);
    if (maps.isNotEmpty) {
      return InspectorModel.fromMap(maps.first);
    }
    return null;
  }

  Future<InspectorModel?> getOne(int id) async {
    Database db = await DatabaseConnection().setDatabase();
    List<Map<String, Object?>> maps = await db.query(table,
        columns: ['*'],
        where: 'visit_id = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InspectorModel.fromMap(maps.first);
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

  Future<int> update(InspectorModel nes) async {
    Database db = await DatabaseConnection().setDatabase();
    return await db.update(table, nes.toJson(),
        where: 'visit_id = ?', whereArgs: [nes.id]);
  }
}

