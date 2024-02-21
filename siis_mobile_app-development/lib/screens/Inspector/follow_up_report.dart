import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/constants.dart';
import 'package:siis_offline/screens/Inspector/school_visits.dart';
import 'package:siis_offline/utils/account_provider.dart';

import '../../models/Inspection.dart';
import '../../models/key_evidence.dart';
import '../../models/user.dart';
import '../../services/InspectionService.dart';
import '../../services/KeyEvidenceService.dart';
import 'edit_inspection.dart';
import 'control_panel.dart';

class FollowupReport extends StatefulWidget {
  final Inspection inspection;

  const FollowupReport({Key? key, required this.inspection}) : super(key: key);

  @override
  State<FollowupReport> createState() => _FollowupReportState();
}

class _FollowupReportState extends State<FollowupReport> {
  late List<Inspection> _inspectionList = <Inspection>[];
  final _inspectionService = InspectionService();
  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(message),
      ),
    );
  }
  var map;
  String? leadInspectorName;
  String? firstInspectorName;
  String? secondInspectorName;
  String? thirdInspectorName;
  String? fourthInspectorName;

  var _recomService =  KeyEvidenceService();
  late List<KeyEvidenceModel> _recommendationList = <KeyEvidenceModel>[];


  getAllRecommendationDetails() async {
    var recommendations = await _recomService.readAllKeyEvidencesByNes(widget.inspection.asocVisit);
    _recommendationList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    recommendations.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = int.parse(key_evidence['nes_id']);
        keyEvidenceModel.requirementId = key_evidence['requirement_name'];
        keyEvidenceModel.nesLevelId = key_evidence['nes_level_id'];
        keyEvidenceModel.followUpComments = key_evidence['followup_comments'];
        keyEvidenceModel.status = key_evidence['need_extra_followup'];
        keyEvidenceModel.extraFollowUp = key_evidence['extra_comments'];
        keyEvidenceModel.nesId = key_evidence['nes_name'];
        keyEvidenceModel.description = key_evidence['key_evidence_description'];
        keyEvidenceModel.visitId = !nes.contains(key_evidence['nes_id']) ? key_evidence['recommendation_description'] : '';
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus = key_evidence['key_evidence_status'];


        _recommendationList.add(keyEvidenceModel);
      });
      if(!nes.contains(key_evidence['nes_id'])){
        nes.add(key_evidence['nes_id']);
      }
    });
  }
  getAllInspection() async {
    var inspections =
    await _inspectionService.readAllInspectionsByVisitId(widget.inspection.asocVisit);
    _inspectionList = <Inspection>[];
    inspections.forEach((inspection) {
      setState(() {
        var inspectionModel = Inspection();
        inspectionModel.id = inspection['visit_id'];
        inspectionModel.presentVisitationDate = inspection['present_visitation_date'];
        _inspectionList.add(inspectionModel);
      });

    });

  }
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


  @override
  void initState() {
    print(widget.inspection.asocVisit);
    getAllInspection();
    getAllRecommendationDetails();
    getLeadInspector();
    getFirstInspector();
    getSecondInspector();
    getThirdInspector();
    getFourthInspector();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("School Inspection"),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            var date = DateTime.parse(widget.inspection.presentVisitationDate);
            var date2 = DateTime.parse(_inspectionList[0].presentVisitationDate.toString());
            DateFormat formatter = DateFormat('dd/MM/yyyy');
            final String formatted = formatter.format(date);
            final String formatted2 = formatter.format(date2);
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset("assets/images/index.png", width: 80, height: 80),),
                  SizedBox(height: 10,),
                  Center(child: Text('FOLLOW UP INSPECTION REPORT', style: TextStyle(
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
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text('...' ?? '',
                              style: TextStyle(fontSize: 14)),
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
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.yearOfEstablishment ?? '',
                              style: TextStyle(fontSize: 14)),
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
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.postAddress ?? '',
                              style: TextStyle(fontSize: 14)),
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
                        child: Text('FOLLOW UP INSPECTION DATE:',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(formatted ?? '',
                              style: TextStyle(fontSize: 14)),
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
                        child: Text("FULL INSPECTION DATE:",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(formatted2, style: TextStyle(
                                  fontSize: 14,
                                ),)

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
                        child: Text('ENROLMENT:',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text('...' ?? '',
                              style: TextStyle(fontSize: 14)),
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
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                              '...' ?? '',
                              style: TextStyle(fontSize: 14)),
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
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                              '...' ?? '',
                              style: TextStyle(fontSize: 14)),
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
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                              leadInspectorName ?? '',
                              style: TextStyle(fontSize: 14)),
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
                                color: Colors.black,
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
                                child: Text('1. ${firstInspectorName}' ?? '',
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
                      Expanded(child: Text("${widget.inspection.schoolName} opened its doors in January 1, ${widget.inspection.yearOfEstablishment}. "
                          "Currently the school has an enrolment of ... of which ... are boys and ... are girls. On this day of inspection ... students "
                          "attended classes. Out of these students ... are boys and ... are girls. ... are qualified and ... unqualified. On the day of "
                          "inspection, ... teachers were present, and ... students attended school. The community around the school earns its living mainly "
                          "through small scale businesses as most people travel to South Africa in search for jobs and so they bring back commodities for sale."
                          " It is a single streamed school which has 6 classrooms of which one is used as a staffroom and has a temporary administration block."
                          " The Directorate of Quality Assurance Services (DQAS) conducted a follow-up visit to the school on ${formatted2}. "
                          "This was a follow up to the full inspection that was carried out on ${formatted}.", style: TextStyle(
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
                      Text("2.0 THE PURPOSE OF FOLLOW UP VISIT AND THIS REPORT", style: TextStyle(
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
                      Expanded(child: Text("The purpose of this followup and this report is to evaluate the quality of education provided"
                          " to the school and to make Recommendations on how it should be improved.${widget.inspection.schoolName} was "
                          "inspected on ${formatted}, by a team of at least 2 inspectors led by ${leadInspectorName}. "
                          "he purpose of this follow up and support visit was to check whether the school fulfilled the action points that the external "
                          "evaluators made during the inspection visit. This will guide the school to improve its practice and provisions.As a result, "
                          "students’ learning will improve and they will achieve better outcomes for "
                          "their own benefit and for the benefit of the nation.", style: TextStyle(
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
                      Text("3.0. FOLLOW UP INSPECTION FINDINGS", style: TextStyle(
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
                      Expanded(child: Text("The section summarises the conclusions on progress made on the "
                          "action points followed by a discussion of the results of the findings. The results of teams’ "
                          "conclusions on progress on the key action points during the follow-up and support visit have "
                          "been summarised in Table 3.1.", style: TextStyle(
                        fontSize: 14,
                      ),))
                    ],
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  DataTable(
                      dataRowHeight: 100,
                      columnSpacing: 30,
                      border: TableBorder.all(
                      width: 1.0,
                      color: Colors.grey),
                      columns: [
                        DataColumn(
                            label: Text('NES', style: TextStyle(fontSize: 9))),
                        DataColumn(
                            label: Text('MINOR\nRECOMMENDATION', style: TextStyle(fontSize: 9))),
                        DataColumn(
                            label: Text('FOLLOWUP\nEVIDENCE', style: TextStyle(fontSize: 9))),
                        DataColumn(
                            label: Text('ACHIEVED', style: TextStyle(fontSize: 9))),
                        DataColumn(
                            label: Text('PARTIALLY\nACHIEVED', style: TextStyle(fontSize: 9))),
                        DataColumn(
                            label: Text('NOT\nACHIEVED', style: TextStyle(fontSize: 9))),

                      ], rows: _recommendationList.map((item) {

                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              child: Text(item.nesId.toString(), style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          DataCell(Text(item.visitId, style: TextStyle(fontSize: 12))),
                          DataCell( Text(item.followUpComments.toString()=='null'?'':item.followUpComments.toString(), style: TextStyle(fontSize: 12))),
                          DataCell((item.status.toString() == 'Achieved')?(Text('✅', style: TextStyle(fontSize: 12))):Text('')),
                          DataCell((item.status.toString() == 'Partially Achieved')?(Text('✅', style: TextStyle(fontSize: 12))):Text('')),
                          DataCell((item.status.toString() == 'Not Achieved')?(Text('✅', style: TextStyle(fontSize: 12))):Text('')),
                        ],

                      );
                    }).toList(),


                    ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
            Expanded(child:Text("4.0. OTHER ACTIONS POINTS DISCUSSED DURING THE FOLLOW UP INSPECTION VISIT", style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),)),

                    ],
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        return Text(_recommendationList.isEmpty?'None':_recommendationList[0].extraFollowUp.toString() == 'null'?'None':_recommendationList[0].extraFollowUp.toString(), style: TextStyle(
                            fontSize: 14,
                        ),);
                      }),

                ],
              ),
            );
          }),
    );
  }
}
