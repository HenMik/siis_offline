import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/models/key_evidence.dart';
import 'package:siis_offline/screens/Inspector/edit_key_evidence.dart';
import 'package:siis_offline/services/keyEvidenceService.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/actionPlan.dart';
import '../../models/area_of_improvement.dart';
import '../../models/critical_issues.dart';
import '../../models/good_practices.dart';
import '../../models/major_strengths.dart';
import '../../models/nes_bar_chart_model.dart';
import '../../models/recommendation.dart';
import '../../models/user.dart';
import '../../services/ActionPlanService.dart';
import '../../services/AreaOfImprovementService.dart';
import '../../services/CriticalIssues.dart';
import '../../services/GoodPractices.dart';
import '../../services/MajorStrengths.dart';
import '../../services/RecommendationService.dart';
import '../../utils/account_provider.dart';
import 'key_evidence_form.dart';
import "package:collection/collection.dart";
import '../../../constants.dart';
import '../../../models/Inspection.dart';
class SchoolVisitReport extends StatefulWidget {
  final Inspection inspection;
  const SchoolVisitReport ({Key? key, required this.inspection}) : super(key: key);

  @override
  _SchoolVisitReport createState() => _SchoolVisitReport();

}

class _SchoolVisitReport extends State<SchoolVisitReport> {


  var _recomServices = MajorStrengthsService();
  String? selectedStartDate;
  String? selectedDueDate;
  String? selectedActivityStatus;
  String emoji='';
  String? selectedPriorityLevel;
  String progress = '';
  var _activityName = TextEditingController();
  var _activityBudget = TextEditingController();
  var _statusRemarks = TextEditingController();
  var _actionPlanService = ActionPlanService();
  DateTime startDate = DateTime.now();
  DateTime dueDate = DateTime.now();
  String? selectedNESValue;
  bool _customTileExpanded = false;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var school_id;
  var _description = TextEditingController();
  var _recomService = RecommendationService();
  String recoId = '';
  late List<Recommendation> _recommendationList = <Recommendation>[];
  late List<ActionPlanModel> _actionPlanList = <ActionPlanModel>[];
  late TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  late List<KeyEvidenceModel> _keyEvidenceList = <KeyEvidenceModel>[];
  late List<KeyEvidenceModel> _achievedList = <KeyEvidenceModel>[];
  late List<KeyEvidenceModel> _nesAchievedList = <KeyEvidenceModel>[];
  final _keyEvidenceService = KeyEvidenceService();
  final _recommendationService = RecommendationService();
  var levelsAchieved = {};
  var newAchieved = [];
  var evidenceDesc = {};
  int totalEnrollment = 0;
  var _improvementServices = AreaOfImprovementService();
  late List<AreaOfImprovementModel> _areaOfImprovementList = <AreaOfImprovementModel>[];
  var _formKeySchoolVisit = GlobalKey<FormState>();
  late List<MajorStrengthModel> _majorStrengthList = <MajorStrengthModel>[];
  var _crititalService = CriticalIssuesService();
  late List<CriticalIssuesModel> _criticalissuesList = <CriticalIssuesModel>[];
  var _practiceService = GoodPracticesService();
  late List<GoodPracticesModel> _goodPracticesList = <GoodPracticesModel>[];

  String? leadInspectorName;
  String? firstInspectorName;
  String? secondInspectorName;
  String? thirdInspectorName;
  String? fourthInspectorName;

  getLeadInspector() async {
    Iterable<User>? u = await UserProvider().getLeadInspector(widget.inspection.leadInspectorName);
    u?.map((item) {
      setState(() {
        leadInspectorName = "${item.firstName.toString()} ${item.lastName.toString()}";
      });
    }).toList();
  }
  getFirstInspector() async {
    Iterable<User>? u = await UserProvider().getLeadInspector(widget.inspection.firstInspectorName);
    u?.map((item) {
      setState(() {
        firstInspectorName = "${item.firstName.toString()} ${item.lastName.toString()}";
      });
    }).toList();
  }
  getSecondInspector() async {
    Iterable<User>? u = await UserProvider().getLeadInspector(widget.inspection.secondInspectorName);
    u?.map((item) {
      setState(() {
        secondInspectorName = "${item.firstName.toString()} ${item.lastName.toString()}";
      });
    }).toList();
  }
  getThirdInspector() async {
    Iterable<User>? u = await UserProvider().getLeadInspector(widget.inspection.thirdInspectorName.toString());
    u?.map((item) {
      setState(() {
        thirdInspectorName = "${item.firstName} ${item.lastName}";
      });
    }).toList();
  }
  getFourthInspector() async {
    Iterable<User>? u = await UserProvider().getLeadInspector(widget.inspection.fourthInspectorName.toString());
    u?.map((item) {
      setState(() {
        fourthInspectorName = "${item.firstName} ${item.lastName}";
      });
    }).toList();
  }

  getAllGoodPracticesDetails() async {
    var goodPracticess = await _practiceService.readAllGoodPracticessByVisitId(widget.inspection.id.toString());
    _goodPracticesList = <GoodPracticesModel>[];
    goodPracticess.forEach((goodPractices) {
      setState(() {
        var goodPracticesModel = GoodPracticesModel();
        goodPracticesModel.id = goodPractices['good_practice_id'];
        goodPracticesModel.createdAt = goodPractices['created_at'];
        goodPracticesModel.description= goodPractices['good_practice_description'];
        goodPracticesModel.visitId = goodPractices['visit_id'];
        _goodPracticesList.add(goodPracticesModel);

      });
    });

  }
  getAllMajorStrengthDetails() async {
    var majorStrengths = await _recomServices
        .readAllMajorStrengthssByVisitId(widget.inspection.id.toString());
    _majorStrengthList = <MajorStrengthModel>[];
    majorStrengths.forEach((majorStrength) {
      setState(() {
        var majorStrengthModel = MajorStrengthModel();
        majorStrengthModel.id = majorStrength['strength_id'];
        majorStrengthModel.createdAt = majorStrength['created_at'];
        majorStrengthModel.description = majorStrength['strength_description'];
        majorStrengthModel.visitId = majorStrength['visit_id'];
        _majorStrengthList.add(majorStrengthModel);
      });
    });
  }
  getAllAreaOfImprovementDetails() async {
    var areaOfImprovements = await _improvementServices.readAllAreaOfImprovementsByVisitId(widget.inspection.id.toString());
    _areaOfImprovementList = <AreaOfImprovementModel>[];
    areaOfImprovements.forEach((areaOfImprovement) {
      setState(() {
        var areaOfImprovementModel = AreaOfImprovementModel();
        areaOfImprovementModel.id = areaOfImprovement['weakness_id'];
        areaOfImprovementModel.createdAt = areaOfImprovement['created_at'];
        areaOfImprovementModel.description= areaOfImprovement['weakness_description'];
        areaOfImprovementModel.visitId = areaOfImprovement['visit_id'];
        _areaOfImprovementList.add(areaOfImprovementModel);

      });
    });

  }
  getNesLevelAchieved() async{
    var levelsAchived = await _keyEvidenceService.readAllRequirementsAchieved(widget.inspection.id.toString());
    var newMap = [];
    levelsAchived.forEach((level) {
      var l = {...level, 'percentage': (int.parse(level['achieved'].toString())/int.parse(level['out_of'])) * 100};
      newMap.add(l);
    });
    var newMapp = newMap.groupListsBy((obj) => obj['nes_id']);
    newMapp.forEach((key, value) {
      var newMaap = newMapp[key];

      newMaap!.forEach((element) {
        var contain = newMaap!.where((e) => e["nes_level_id"] == '2' && e["percentage"] == 100);
        var contain2 = newMaap!.where((e) => e["nes_level_id"] == '3' && e["percentage"] == 100);
        var contain3 = newMaap!.where((e) => e["nes_level_id"] == '4' && e["percentage"] == 100);
        if(contain.isEmpty){
          levelsAchieved[element['nes_id']] = '1';
        }
        else{
          if(element['nes_level_id'] == '2' && element['percentage'] < 100){

            levelsAchieved[element['nes_id']] = '1';

          }
          if(element['nes_level_id'] == '2' && element['percentage'] == 100){
            levelsAchieved[element['nes_id']] = '2';
          }
          else{
            if(contain2.isEmpty){
              levelsAchieved[element['nes_id']] = '2';
            }
            else{
              if(element['nes_level_id'] == '3' && element['percentage'] < 100){

                levelsAchieved[element['nes_id']] = '2';

              }
              if(element['nes_level_id'] == '3' && element['percentage'] == 100){
                levelsAchieved[element['nes_id']] = '3';
              }
              else{
                if(contain3.isEmpty){
                  levelsAchieved[element['nes_id']] = '3';
                }
                else{
                  if(element['nes_level_id'] == '4' && element['percentage'] < 100){

                    levelsAchieved[element['nes_id']] = '3';

                  }
                  if(element['nes_level_id'] == '4' && element['percentage'] == 100){

                    levelsAchieved[element['nes_id']] = '4';

                  }


                }
              }
            }
          }

        }


      });
    });

  }
  getAllRecommendationDetails() async {
    var recommendations = await _recomService
        .readAllRecommendationsByVisitId(widget.inspection.id.toString());
    print(recommendations);
    _recommendationList = <Recommendation>[];
    recommendations.forEach((recommendation) {
      setState(() {
        var recommendationModel = Recommendation();
        recommendationModel.id = recommendation['recommendation_id'];
        recommendationModel.createdAt = recommendation['created_at'];
        recommendationModel.description =
        recommendation['recommendation_description'];
        recommendationModel.nesCategory = recommendation['category_id'];
        recommendationModel.visitId = recommendation['visit_id'];
        _recommendationList.add(recommendationModel);
      });
    });
  }
  getAllActions() async {
    var actionsplans = await _actionPlanService
        .readAllActionPlans(widget.inspection.id.toString());
    _actionPlanList = <ActionPlanModel>[];
    actionsplans.forEach((ActionPlan) {
      setState(() {
        var actionPlanModel = ActionPlanModel();

        actionPlanModel.id = ActionPlan['action_plan_id'];
        actionPlanModel.activityName = ActionPlan['activity_name'];
        actionPlanModel.activityStartDate = ActionPlan['activity_start_date'];
        actionPlanModel.activityFinishDate = ActionPlan['activity_finish_date'];
        actionPlanModel.activityStatus = ActionPlan['activity_status'];
        actionPlanModel.activityBudget = ActionPlan['activity_budget'];
        actionPlanModel.priorityId = ActionPlan['priority_id'];
        actionPlanModel.statusRemarks = ActionPlan['status_remarks'];
        actionPlanModel.recommendationId =
            int.parse(ActionPlan['recommendation_id']);
        _actionPlanList.add(actionPlanModel);
      });
    });
  }
  getAllKeyEvidenceDetails() async {
    var keyEvidences = await _keyEvidenceService.readAllKeyEvidencesByRequirement(widget.inspection.id.toString());

    _keyEvidenceList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    keyEvidences.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = int.parse(key_evidence['nes_id']);
        keyEvidenceModel.requirementName = key_evidence['requirement_name'];
        keyEvidenceModel.requirementId = key_evidence['requirement_id'];
        keyEvidenceModel.nesLevelId = key_evidence['nes_level_id'];
        keyEvidenceModel.nesId = !nes.contains(key_evidence['nes_id']) ? key_evidence['nes_name'] : '';
        keyEvidenceModel.description = key_evidence['key_evidence_description'];
        keyEvidenceModel.visitId = !nes.contains(key_evidence['nes_id']) ? key_evidence['recommendation_description'] : '';
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus =key_evidence['key_evidence_status'];

        _keyEvidenceList.add(keyEvidenceModel);
      });
      if(!nes.contains(key_evidence['nes_id'])){
        nes.add(key_evidence['nes_id']);
      }
      evidenceDesc[key_evidence['key_evidence_id']] = key_evidence['key_evidence_description'];

    });
  }
  getAllCriticalIssuesDetails() async {
    var criticalIssues= await _crititalService.readAllCriticalIssuessByVisitId(widget.inspection.id.toString());
    _criticalissuesList = <CriticalIssuesModel>[];
    criticalIssues.forEach((criticalIssues) {
      setState(() {
        var criticalIssuesModel = CriticalIssuesModel();
        criticalIssuesModel.id = criticalIssues['critical_issue_id'];
        criticalIssuesModel.createdAt = criticalIssues['created_at'];
        criticalIssuesModel.description= criticalIssues['critical_issue_description'];
        criticalIssuesModel.visitId = criticalIssues['visit_id'];
        _criticalissuesList.add(criticalIssuesModel);

      });
    });

  }
  getAllRequirementsAchieved() async {
    var levelsAchived = await _keyEvidenceService.readAllRequirementsAchieved(widget.inspection.id.toString());
    _achievedList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    levelsAchived.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = key_evidence['key_evidence_id'];
        keyEvidenceModel.requirementName = key_evidence['requirement_name'];
        keyEvidenceModel.requirementId = key_evidence['requirement_id'];
        keyEvidenceModel.nesLevelId = key_evidence['achieved'].toString();
        keyEvidenceModel.nesId = key_evidence['nes_id'];
        keyEvidenceModel.description = key_evidence['out_of'];
        keyEvidenceModel.visitId = key_evidence['recommendation_description'];
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus =key_evidence['nes_level_id'];

        _achievedList.add(keyEvidenceModel);
      });
      if(!nes.contains(key_evidence['nes_id'])){
        nes.add(key_evidence['nes_id']);
      }
    });

  }
  getNesLevelsAchieved() async {
    var nesLevelsAchived = await _keyEvidenceService.readNesLevelsAchieved(widget.inspection.id.toString());

    _nesAchievedList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    nesLevelsAchived.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = key_evidence['key_evidence_id'];
        keyEvidenceModel.requirementName = key_evidence['requirement_name'];
        keyEvidenceModel.requirementId = key_evidence['requirement_id'];
        keyEvidenceModel.nesLevelId = key_evidence['achieved'].toString();
        keyEvidenceModel.nesId = key_evidence['nes_id'];
        keyEvidenceModel.description = key_evidence['out_of'];
        keyEvidenceModel.visitId = key_evidence['recommendation_description'];
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus =key_evidence['nes_level_id'];

        _nesAchievedList.add(keyEvidenceModel);
      });
      if(!nes.contains(key_evidence['nes_id'])){
        nes.add(key_evidence['nes_id']);
      }

    });

  }
  var date, date2, date3;
  late final String formatted, formatted1, formatted2;
  @override
  void initState() {
    date = DateTime.parse(widget.inspection.presentVisitationDate);
    date2 = DateTime.parse(widget.inspection.actionPlanDate);
    date3 = DateTime.parse(widget.inspection.nextInspectionDate);

    DateFormat formatter = DateFormat('dd/MM/yyyy');
    formatted = formatter.format(date);
    formatted1 = formatter.format(date2);
    formatted2 = formatter.format(date3);
    totalEnrollment = int.parse(widget.inspection.totalEnrolledGirls) + int.parse(widget.inspection.totalEnrolledBoys);
    super.initState();
getAllRecommendationDetails();
getAllMajorStrengthDetails();
    getNesLevelAchieved();
    getNesLevelsAchieved();
    getAllKeyEvidenceDetails();
    getAllRequirementsAchieved();
    getAllAreaOfImprovementDetails();
    getAllCriticalIssuesDetails();
    getAllGoodPracticesDetails();
    getLeadInspector();
    getFirstInspector();
    getSecondInspector();
    getThirdInspector();
    getFourthInspector();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('School Visit Report'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,),

      body: Center(
        child: ListView(

          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              color: kGreyLightColor,
              child: Row(
                children:<Widget>[
                  Text(
                      'Home',
                      style: TextStyle(fontSize: 15, )
                  ),
                  Icon(Icons.arrow_right),
                  Text(
                      'School Visit Report',
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                  ),
                ],

              ),

            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                children: [
                  Center(child: Image.asset("assets/images/index.png", width: 80, height: 80),),
                  SizedBox(height: 10,),
                  Center(child: Text('INPECTION REPORT AT ${widget.inspection.schoolName}', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold
                  ),),),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('HEAD TEACHER:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.headTeacher ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('DIVISION:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.divisionName ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('DISTRICT:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.districtName ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('CLUSTER:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.clusterName ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('ESTABLISHMENT:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.establishment ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('YEAR OF ESTABLISHMENT:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.yearOfEstablishment ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('POSTAL ADDRESS:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.postAddress ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('FULL INSPECTION DATE:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(formatted ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('ENROLLMENT:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(

                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(totalEnrollment.toString() ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('NUMBER OF ENROLLED BOYS:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.totalEnrolledBoys ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('NUMBER OF ENROLLED GIRLS:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.totalEnrolledGirls ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('NUMBER OF BOYS IN ATTENDANCE:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.totalAttendanceBoys ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('NUMBER OF GIRLS IN ATTENDANCE:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.totalAttendanceBoys ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('QUALIFIED TEACHERS:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.nofqTeachers ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('UNQUALIFIED TEACHERS:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.noufqTeachers ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('LEAD INSPECTOR:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(leadInspectorName ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('INSPECTION TEAM:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text('1. ${firstInspectorName}' ??'',
                                    style: TextStyle(fontSize: 14,)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text('2. ${secondInspectorName}' ?? '',
                                    style: TextStyle(fontSize: 14,)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text('3. ${thirdInspectorName== null?'None':thirdInspectorName}' ?? '',
                                    style: TextStyle(fontSize: 14,)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text('4. ${fourthInspectorName== null?'None':fourthInspectorName}' ?? '',
                                    style: TextStyle(fontSize: 14,)),
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text("HEAD TEACHER'S PHONE(S):",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.headPhonenumber ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('DATE FOR REPORT PUBLICATION:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(formatted2.split(' ')[0] ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('DATE OF EXPECTED ACTION PLAN:',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(formatted1.split(' ')[0] ?? '',
                              style: TextStyle(fontSize: 14,)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      child: Divider(
                          color: Colors.grey
                      )
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("1.0. BACKGROUND TO THE SCHOOL", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),)
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("${widget.inspection.schoolName} opened its doors in January 1, ${widget.inspection.yearOfEstablishment}. Currently the school has an enrolment of ${int.parse(widget.inspection.totalEnrolledBoys) + int.parse(widget.inspection.totalEnrolledGirls)} of which ${widget.inspection.totalEnrolledBoys} are boys and ${widget.inspection.totalEnrolledGirls} are girls. On this day of inspection ${int.parse(widget.inspection.totalAttendanceBoys) + int.parse(widget.inspection.totalAttendanceGirls)} students attended classes. Out of these students ${widget.inspection.totalAttendanceBoys} are boys and ${widget.inspection.totalAttendanceGirls} are girls.", style: TextStyle(
                          fontSize: 14,
                      ),))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("2.0 THE PURPOSE OF INSPECTION AND THIS REPORT", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),)),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("The purpose of this inspection and this report is to evaluate the quality of education provided to the school and to make Recommendations on how it should be improved. ${widget.inspection.schoolName} was inspected on ${widget.inspection.presentVisitationDate}, by a team of at least ${widget.inspection.fourthInspectorName!=null?5:widget.inspection.thirdInspectorName!= null?4:3} inspectors led by ${leadInspectorName}. The inspection team observed lessons, carried out interviews with different stakeholders, scrutinized learners work in exercise books and then checked administrative and teaching records. The information contained in the Pre-Inspection Self Assessment Document (PISAD) completed by the school and data from the National Education Management System were taken into account also. The evaluations in this report were made against the National Education Standards (NES).On receipt of this report the school, should build on its strengths, and then act on its shortfalls and meet the Recommendations set down at the end of this report. Thereafter, the school will produce an Action Plan in order to guide its work on improvement. As a result students’ learning will improve and they will achieve better outcomes for their own benefits and that of the nation.", style: TextStyle(
                        fontSize: 14,
                      ),))
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("3.0 SCHOOL'S PERFORMANCE AGAINST NATIONAL EDUCATION STANDARDS", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),))
                    ],
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("Graphical Summary of ${widget.inspection.schoolName} inspection performance against NES:", style: TextStyle(
                        fontSize: 14,
                      ),))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Graph of Visit Report
                  Container(
                      child: SfCartesianChart(
                          isTransposed: true,
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(minimum: 0, maximum: 4,interval: 1),
                          tooltipBehavior: _tooltip,
                          series: <ChartSeries<_ChartData, String>>[

                            BarSeries<_ChartData, String>(

                                dataSource: _achievedList.map((item) {
                                  var year = double.parse(levelsAchieved[item.nesId]);
                                  return _ChartData(year,item.nesId.toString());
                                }).toList(),
                                xValueMapper: (_ChartData data, _) => data.y,
                                yValueMapper: (_ChartData data, _) => data.x,
                                name: 'Level achived',
                                color: Color.fromRGBO(255, 156, 46, 1),
                                markerSettings: MarkerSettings(
                                  isVisible: true,
                                )),

                          ])),
                  const SizedBox(
                    height: 20,
                  ),
        ListView.builder(
       physics: ScrollPhysics(),
    shrinkWrap: true,
    itemCount: _keyEvidenceList.length,
    itemBuilder: (context, index) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_keyEvidenceList[index].nesId, style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal
          ),),
          const SizedBox(
            height: 20,
          ),

              Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Text('${_keyEvidenceList[index].id.toString()}.${_keyEvidenceList[index].requirementId.toString()}  ${_keyEvidenceList[index].requirementName.toString()}', style: TextStyle(
                      fontSize: 14,
                  ),)),
                  const SizedBox(
                    width: 20,
                  ),
                   Expanded(

                      child: Row(children: [
                        Expanded(child: Text('${_keyEvidenceList[index].keyEvidenceStatus=='Positive'?'+':'-'}'),),
                      Expanded(child: Text('${_keyEvidenceList[index].description}'),),


                   ],),

                   ),
                ],
              ),

        ],
      );
       }
    ),

                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("4.0 MAJOR STRENGTHS", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),))
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _majorStrengthList.length,
                      itemBuilder: (context, index) {
                        return(
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                            "${_majorStrengthList[index].description}",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.normal),
                                    ),


                            ],
                                ),
                                SizedBox(height: 10),


                              ],
                            )
                        );
                      }
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("5.0 AREAS OF IMPROVEMENT", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _areaOfImprovementList.length,
                      itemBuilder: (context, index) {
                        return(
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${_areaOfImprovementList[index].description}",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                              ],
                            )
                        );
                      }
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("6.0 GOOD PRACTICES", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),))
                    ],
                  ),
                  ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _goodPracticesList.length,
                      itemBuilder: (context, index) {
                        return(
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${_goodPracticesList[index].description}",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                              ],
                            )
                        );
                      }
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("7.0 CRITICAL ISSUES", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _criticalissuesList.length,
                      itemBuilder: (context, index) {
                        return(
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${_criticalissuesList[index].description}",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                              ],
                            )
                        );
                      }
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text("8.0 MAJOR RECOMMENDATIONS", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
        ListView.builder(
        physics: ScrollPhysics(),
    shrinkWrap: true,
    itemCount: _recommendationList.length,
    itemBuilder: (context, index) {
          return(
      Column(
        children: [
          Row(
            children: [
              Text(
                "${_recommendationList[index].description}",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          SizedBox(height: 20),

        ],
      )
          );
    }
        ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )

          ],
        ),

      ),
    );


  }
}
class _ChartData {
  _ChartData(this.x, this.y);

  final String y;
  final double x;
}


