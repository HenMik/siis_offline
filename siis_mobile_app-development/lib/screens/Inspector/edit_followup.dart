import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/constants.dart';
import 'package:siis_offline/models/Inspection.dart';

import '../../models/key_evidence.dart';
import '../../models/recommendationUpdate.dart';
import '../../models/user.dart';
import '../../services/InspectionService.dart';
import '../../services/KeyEvidenceService.dart';
import '../../services/RecommendationService.dart';
import '../../utils/account_provider.dart';

class EditFollowUp extends StatefulWidget {
  final Inspection inspection;
  const EditFollowUp({Key? key, required this.inspection}) : super(key: key);

  @override
  State<EditFollowUp> createState() => _EditFollowUpState();
}

class _EditFollowUpState extends State<EditFollowUp> {
  String? selectedInspectorId;
  String? selectedFirstInspectorId;
  String? selectedSecondInspectorId;
  late Iterable<User> inspectors = [];
  var selectedDivisionValue;
  String? selectedYOEValue;
  var selectedClusterValue;
  var selectedSchoolValue;
  var selectedDistrictValue;
  var currentDate;
  var actionPlanDate;
  var nextInspectionDate;
  var visitType;
  var yoe;
  var sectorId;
  var _headTeacher = TextEditingController();
  var _headPhonenumber = TextEditingController();
  var _postAddress = TextEditingController();
  var _nofqTeachers = TextEditingController();
  var _noufqTeachers = TextEditingController();
  var _totalEnrolledBoys = TextEditingController();
  var _totalEnrolledGirls = TextEditingController();
  var _totalAttendanceBoys = TextEditingController();
  var _totalAttendanceGirls = TextEditingController();
  var _advisor = TextEditingController();
  var _schoolGovernanceChair = TextEditingController();
  var _inspectionService = InspectionService();
  var _extraFollowUpComment = TextEditingController();
  var _otherInspectors = [];
  var _recommService = RecommendationService();
  DateTime selectedDate = DateTime.now();
  DateTime selectedNIDate = DateTime.now();
  final List<TextEditingController> _followUpComment = [
    TextEditingController()
  ];
  final List<String?> _status = [];
  var _recomService = KeyEvidenceService();
  late List<KeyEvidenceModel> _recommendationList = <KeyEvidenceModel>[];
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor, // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Colors.black, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.red, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        actionPlanDate = picked.toString();
        selectedDate = picked;
      });
    }
  }

  getAllRecommendationDetails() async {
    var recommendations = await _recomService
        .readAllKeyEvidencesByNes(widget.inspection.asocVisit);
    _recommendationList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    recommendations.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = int.parse(key_evidence['nes_id']);
        keyEvidenceModel.requirementId = key_evidence['requirement_name'];
        keyEvidenceModel.recomId = key_evidence['recommendation_id'];
        keyEvidenceModel.nesLevelId = key_evidence['nes_level_id'];
        keyEvidenceModel.followUpComments = key_evidence['followup_comments'];
        keyEvidenceModel.status = key_evidence['need_extra_followup'];
        keyEvidenceModel.extraFollowUp = key_evidence['extra_comments'];
        keyEvidenceModel.nesId = key_evidence['nes_name'];
        keyEvidenceModel.description = key_evidence['key_evidence_description'];
        keyEvidenceModel.visitId = !nes.contains(key_evidence['nes_id'])
            ? key_evidence['recommendation_description']
            : '';
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus =
            key_evidence['key_evidence_status'];

        _recommendationList.add(keyEvidenceModel);
      });
      if (!nes.contains(key_evidence['nes_id'])) {
        nes.add(key_evidence['nes_id']);
      }
    });
  }

  getAllInspectorDetails(String? sector_id) async {
    Iterable<User>? u = await UserProvider().getAll(sector_id);
    setState(() {
      inspectors = u!;
    });
  }

  Future<void> _nextInspectionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor, // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Colors.black, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.red, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: selectedNIDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedNIDate) {
      setState(() {
        nextInspectionDate = picked.toString();
        selectedNIDate = picked;
      });
    }
  }

  List<DropdownMenuItem<String>> get status {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Achieved"), value: "Achieved"),
      DropdownMenuItem(
          child: Text("Partially Achieved"), value: "Partially Achieved"),
      DropdownMenuItem(child: Text("Not Achieved"), value: "Not Achieved"),
    ];
    return menuItems;
  }

  late List<String> _initial;
  @override
  void initState() {
    setState(() {
      getAllRecommendationDetails();
      sectorId = widget.inspection.sector_id ?? '';
      selectedDistrictValue = widget.inspection.districtName ?? '';
      selectedDivisionValue = widget.inspection.divisionName ?? '';
      selectedClusterValue = widget.inspection.clusterName ?? '';
      selectedSchoolValue = widget.inspection.emisId ?? '';
      actionPlanDate = widget.inspection.actionPlanDate ?? '';
      nextInspectionDate = widget.inspection.nextInspectionDate ?? '';
      currentDate = widget.inspection.presentVisitationDate ?? '';
      _headTeacher.text = widget.inspection.headTeacher ?? '';
      _headPhonenumber.text = widget.inspection.headPhonenumber ?? '';
      _postAddress.text = widget.inspection.postAddress ?? '';
      _nofqTeachers.text = widget.inspection.nofqTeachers ?? '';
      _noufqTeachers.text = widget.inspection.noufqTeachers ?? '';
      _totalEnrolledBoys.text = widget.inspection.totalEnrolledBoys ?? '';
      _totalEnrolledGirls.text = widget.inspection.totalEnrolledGirls ?? '';
      _totalAttendanceBoys.text = widget.inspection.totalAttendanceBoys ?? '';
      _totalAttendanceGirls.text = widget.inspection.totalAttendanceGirls ?? '';
      _advisor.text = widget.inspection.advisor ?? '';
      _schoolGovernanceChair.text =
          widget.inspection.schoolGovernanceChair ?? '';
      yoe = widget.inspection.yearOfEstablishment ?? '';
      visitType = widget.inspection.visitType ?? '';
      nextInspectionDate = widget.inspection.nextInspectionDate ?? '';
      actionPlanDate = widget.inspection.actionPlanDate ?? '';
      selectedNIDate = DateTime.parse(widget.inspection.presentVisitationDate);
      selectedDate = DateTime.parse(widget.inspection.actionPlanDate);
      selectedInspectorId = widget.inspection.leadInspectorName ?? '';
      selectedFirstInspectorId = widget.inspection.firstInspectorName ?? '';
      selectedSecondInspectorId = widget.inspection.secondInspectorName ?? '';
      if (widget.inspection.thirdInspectorName == null &&
          widget.inspection.fourthInspectorName == null) {
        _initial = [];
      }
      if (widget.inspection.thirdInspectorName == '' ||
          widget.inspection.thirdInspectorName == null) {
        _initial = [];
      }
      if ((widget.inspection.fourthInspectorName == '' ||
              widget.inspection.fourthInspectorName == null) &&
          (widget.inspection.thirdInspectorName != '' ||
              widget.inspection.thirdInspectorName != null)) {
        _initial = [widget.inspection.thirdInspectorName];
      } else {
        _initial = [
          widget.inspection.thirdInspectorName,
          widget.inspection.fourthInspectorName
        ];
      }
      _otherInspectors = _initial.toList();

      var user = context.read<AccountProvider>().user;
      getAllInspectorDetails(user!['sector_id'].toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Inspection"),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                    text: selectedNIDate.toLocal().toString().split(' ')[0]),
                decoration: InputDecoration(
                  labelText: "Present Visitation Date",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                ),
                onTap: () {
                  _nextInspectionDate(context);
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                  labelText: 'Lead Inspector Name',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                value: widget.inspection.leadInspectorName.toString(),
                validator: (value) =>
                    value == null ? "Select inspector name" : null,
                onChanged: (String? newValue) {
                  setState(() {
                    var user = context.read<AccountProvider>().user;
                    selectedInspectorId = newValue;
                    getAllInspectorDetails(user!['sector_id'].toString());
                  });
                },
                items: inspectors
                    ?.where((d) =>
                        selectedFirstInspectorId != d.userId.toString() &&
                        selectedSecondInspectorId != d.userId.toString())
                    .map((item) {
                  return DropdownMenuItem(
                    value: item.userId.toString(),
                    child: Text(
                        "${item.firstName.toString()} ${item.lastName.toString()}"),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 25.0,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                  labelText: 'First Inspector Name',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                value: widget.inspection.firstInspectorName.toString(),
                validator: (value) =>
                    value == null ? "Select inspector name" : null,
                onChanged: (String? newValue) {
                  setState(() {
                    var user = context.read<AccountProvider>().user;
                    selectedFirstInspectorId = newValue;
                    getAllInspectorDetails(user!['sector_id'].toString());
                  });
                },
                items: inspectors
                    ?.where((d) => selectedInspectorId != d.userId.toString())
                    .map((item) {
                  return DropdownMenuItem(
                    value: item.userId.toString(),
                    child: Text(
                        "${item.firstName.toString()} ${item.lastName.toString()}"),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 25.0,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                  labelText: 'second Inspector Name',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                value: widget.inspection.secondInspectorName.toString(),
                validator: (value) =>
                    value == null ? "Select inspector name" : null,
                onChanged: (String? newValue) {
                  setState(() {
                    var user = context.read<AccountProvider>().user;
                    selectedSecondInspectorId = newValue;
                    getAllInspectorDetails(user!['sector_id'].toString());
                  });
                },
                items: inspectors
                    ?.where((d) =>
                        selectedInspectorId != d.userId.toString() &&
                        selectedFirstInspectorId != d.userId.toString())
                    .map((item) {
                  return DropdownMenuItem(
                    value: item.userId.toString(),
                    child: Text(
                        "${item.firstName.toString()} ${item.lastName.toString()}"),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 25.0,
              ),
              MultiSelectDialogField(
                title: Text("Inspectors"),
                selectedColor: Colors.teal,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                buttonIcon: Icon(
                  Icons.people,
                  color: Colors.teal,
                ),
                buttonText: Text(
                  "Other Inspectors",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                initialValue: _initial,
                items: inspectors
                    .where((d) =>
                        selectedInspectorId != d.userId.toString() &&
                        selectedFirstInspectorId != d.userId.toString() &&
                        selectedSecondInspectorId != d.userId.toString())
                    .map((e) => MultiSelectItem(e.userId.toString(),
                        "${e.firstName.toString()} ${e.lastName.toString()}"))
                    .toList(),
                onConfirm: (results) {
                  setState(() {
                    _initial.remove(_initial);
                    _otherInspectors = results;
                  });
                },
              ),
              SizedBox(
                height: 25.0,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dataRowHeight: 100,
                  columns: [
                    DataColumn(
                        label: Text('NES', style: TextStyle(fontSize: 12))),
                    DataColumn(
                        label: Text('MINOR RECOMMENDATION',
                            style: TextStyle(fontSize: 12))),
                    DataColumn(
                        label: Text('FOLLOWUP EVIDENCE',
                            style: TextStyle(fontSize: 12))),
                    DataColumn(
                        label: Text('STATUS', style: TextStyle(fontSize: 12))),
                  ],
                  rows: _recommendationList.map((item) {
                    var index = _recommendationList.indexOf(item);
                    _followUpComment.add(TextEditingController());
                    _followUpComment[index].text = item.followUpComments;
                    _extraFollowUpComment.text = item.extraFollowUp;
                    _status.add(item.status);
                    _status[index] = item.status.toString();
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: 100,
                            child: Text(item.nesId.toString()),
                          ),
                        ),
                        DataCell(Text(item.visitId.toString())),
                        DataCell(
                          TextField(
                            controller: _followUpComment[index],
                            keyboardType: TextInputType.multiline,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Followup evidence',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        DataCell(
                          DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              value: item.status.toString() == 'null'
                                  ? 'Achieved'
                                  : item.status.toString(),
                              validator: (value) =>
                                  value == null ? "Select a Status" : null,
                              onChanged: (String? newValue) {
                                _status[index] = newValue;
                              },
                              items: status),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              SizedBox(
                height: 25.0,
              ),
              TextField(
                controller: _extraFollowUpComment,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Extra Followup Comment',
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                children: [
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.teal,
                          textStyle: const TextStyle(fontSize: 15)),
                      child: const Text('Update Details'),
                      onPressed: () async {
                        var user = context.read<AccountProvider>().user;
                        var _inspection = Inspection();
                        _inspection.id = widget.inspection.id;
                        _inspection.divisionName = selectedDivisionValue;
                        _inspection.clusterName = selectedClusterValue;
                        _inspection.schoolName = selectedSchoolValue;
                        _inspection.districtName = selectedDistrictValue;
                        _inspection.headTeacher = _headTeacher.text;
                        _inspection.headPhonenumber = _headPhonenumber.text;
                        _inspection.postAddress = _postAddress.text;
                        _inspection.nofqTeachers = _nofqTeachers.text;
                        _inspection.noufqTeachers = _noufqTeachers.text;
                        _inspection.totalEnrolledBoys = _totalEnrolledBoys.text;
                        _inspection.totalEnrolledGirls =
                            _totalEnrolledGirls.text;
                        _inspection.totalAttendanceBoys =
                            _totalAttendanceBoys.text;
                        _inspection.totalAttendanceGirls =
                            _totalAttendanceGirls.text;
                        _inspection.nextInspectionDate =
                            widget.inspection.nextInspectionDate;
                        _inspection.yearOfEstablishment = yoe.toString();
                        _inspection.actionPlanDate = actionPlanDate.toString();
                        _inspection.nextInspectionDate =
                            nextInspectionDate.toString();
                        _inspection.advisor = _advisor.text;
                        _inspection.asocVisit =
                            widget.inspection.asocVisit.toString();
                        _inspection.schoolGovernanceChair =
                            _schoolGovernanceChair.text;
                        _inspection.visitType = '2';
                        _inspection.presentVisitationDate =
                            selectedNIDate.toString().split(' ')[0];
                        _inspection.actionPlanDate = selectedDate.toString();
                        _inspection.leadInspectorName =
                            selectedInspectorId.toString();
                        _inspection.firstInspectorName =
                            selectedFirstInspectorId.toString();
                        _inspection.secondInspectorName =
                            selectedSecondInspectorId.toString();
                        if (_otherInspectors.length > 2) {
                          _inspection.thirdInspectorName = _otherInspectors[1];
                          _inspection.fourthInspectorName = _otherInspectors[2];
                        } else {
                          _otherInspectors.length <= 0
                              ? ''
                              : _inspection.thirdInspectorName =
                                  _otherInspectors[0];
                          _otherInspectors.length <= 1
                              ? ''
                              : _inspection.fourthInspectorName =
                                  _otherInspectors[1];
                        }
                        _inspection.sector_id = user!['sector_id'].toString();
                        _inspection.sync = '1';
                        var result = await _inspectionService.UpdateInspection(
                            _inspection);
                        var recommendation = RecommendationUp();
                        for (var i = 0; i < _recommendationList.length; i++) {
                          recommendation.id = _recommendationList[i].recomId;
                          recommendation.followUpComments =
                              _followUpComment[i].text;
                          recommendation.extraFollowUp =
                              _extraFollowUpComment.text;
                          recommendation.status = _status[i].toString();

                          var result =
                              await _recommService.UpdateRecomm(recommendation);
                        }
                        Navigator.pop(context, result);
                      }),
                  const SizedBox(
                    width: 10.0,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red,
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () {
                        _headTeacher.text = '';
                        _headPhonenumber.text = '';
                        _postAddress.text = '';
                        _nofqTeachers.text = '';
                        _noufqTeachers.text = '';
                        _totalEnrolledBoys.text = '';
                        _totalEnrolledGirls.text = '';
                        _totalAttendanceBoys.text = '';
                        _totalAttendanceGirls.text = '';
                        visitType = '';
                      },
                      child: const Text('Clear Details')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
