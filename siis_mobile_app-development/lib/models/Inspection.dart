class Inspection {
  int? id;
  var divisionName;
  var districtName;
  var districtId;
  var divisionId;
  var clusterName;
  var schoolName;
  var emisId;
  var headTeacher;
  var headPhonenumber;
  var postAddress;
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
  var sector_id;
  var sync;
  var asocVisit;
  var establishment;

  inspectionMap() {
    var mapping = Map<String, dynamic>();
    mapping['visit_id'] = id ?? null;
    mapping['division_id'] = divisionName!;
    mapping['district_id'] = districtName!;
    mapping['zone_id'] = clusterName!;
    mapping['emis_id'] = schoolName!;
    mapping['head_teacher'] = headTeacher!;
    mapping['phone_number'] = headPhonenumber!;
    mapping['school_address'] = postAddress!;
    mapping['establishment_year'] = yearOfEstablishment!;
    mapping['number_of_teachers'] = nofqTeachers!;
    mapping['unqualified_teachers'] = noufqTeachers!;
    mapping['enrolment_boys'] = totalEnrolledBoys!;
    mapping['enrolment_girls'] = totalEnrolledGirls!;
    mapping['attendance_boys'] = totalAttendanceBoys!;
    mapping['attendance_girls'] = totalAttendanceGirls!;
    mapping['visit_type_id'] = visitType!;
    mapping['present_visitation_date'] = presentVisitationDate!;
    mapping['action_plan_date'] = actionPlanDate!;
    mapping['next_inspection_date'] = nextInspectionDate!;
    mapping['lead_advisor_id'] = advisor!;
    mapping['govt_chair_id'] = schoolGovernanceChair!;
    mapping['sector_id'] = sector_id!;
    mapping['lead_inspector_id'] = leadInspectorName!;
    mapping['first_inspector_id'] = firstInspectorName!;
    mapping['second_inspector_id'] = secondInspectorName!;
    mapping['sync'] = sync;
    mapping['assoc_visit'] = asocVisit ?? null;

    mapping['prev_visitation_date'] = previousVisitationDate ?? null;
    mapping['establishment'] = establishment ?? null;

    mapping['third_inspector_id'] = thirdInspectorName ?? null;
    mapping['fourth_inspector_id'] = fourthInspectorName ?? null;

    return mapping;
  }
}