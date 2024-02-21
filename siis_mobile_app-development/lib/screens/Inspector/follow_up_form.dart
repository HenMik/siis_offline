import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:siis_offline/constants.dart';
import 'package:siis_offline/models/recommendationUpdate.dart';
import 'package:siis_offline/services/keyEvidenceService.dart';
import '../../models/key_evidence.dart';
import '../../models/user.dart';
import '../../services/RecommendationService.dart';
import '../../utils/account_provider.dart';
import 'package:provider/provider.dart';
import '../../models/Inspection.dart';
import '../../models/district.dart';
import '../../models/division.dart';
import '../../models/school.dart';
import '../../models/zone.dart';
import '../../services/InspectionService.dart';

class FollowUpForm extends StatefulWidget {
  @override
  _FollowUpFormState createState() => _FollowUpFormState();
}

class _FollowUpFormState extends State<FollowUpForm> {
  bool hide = false;
  late Iterable<User> inspectors = [];
  late Iterable<Division>? divisions = [];
  late Iterable<District>? districts = [];
  late Iterable<Zone>? zones = [];
  late Iterable<School>? schools = [];
  late Iterable<School>? schoolVisits = [];
  late List<String> year = [];
  String? selectedDivisionValue;
  String? selectedDistrictValue;
  String? selectedClusterValue;
  String? selectedSchoolValue;
  String? selectedVisitTypeValue;
  String? selectedYOEValue;
  String? selectedAPDate;
  String? selectedNxtInspDate;
  final List<TextEditingController> _followUpComment = [
    TextEditingController()
  ];
  String? selectedInspectorId;
  String? selectedFirstInspectorId;
  String? selectedSecondInspectorId;
  var _otherInspectors = [];

  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late List<Inspection> _inspectionList = <Inspection>[];
  List<Inspection> currentInspectionList = <Inspection>[];
  final _inspectionService = InspectionService();
  var _headTeacherController = TextEditingController();
  var _headPhonenumber = TextEditingController();
  var _extraFollowUpComment = TextEditingController();
  var _nofqTeachers = TextEditingController();
  var _noufqTeachers = TextEditingController();
  var _totalEnrolledBoys = TextEditingController();
  var _totalEnrolledGirls = TextEditingController();
  var _totalAttendanceBoys = TextEditingController();
  var _totalAttendanceGirls = TextEditingController();
  var _leadInspectorName = TextEditingController();
  var _firstInspectorName = TextEditingController();
  var _secondInspectorName = TextEditingController();
  var _thirdInspectorName = TextEditingController();
  var _fourthInspectorName = TextEditingController();

  var _advisor = TextEditingController();
  var _schoolGovernanceChair = TextEditingController();
  late var id;
  late var name;
  var schoolVisit;
  String? keyStatus = '0';
  int _currentStep = 0;
  var _recomService = KeyEvidenceService();
  var _recommService = RecommendationService();
  late List<KeyEvidenceModel> _recommendationList = <KeyEvidenceModel>[];
  final List<String?> _status = [];

  getAllInspectionDetails(String visitId) async {
    var inspections =
        await _inspectionService.readAllInspectionsByVisitId(visitId);
    _inspectionList = <Inspection>[];
    inspections.forEach((inspection) {
      setState(() {
        var inspectionModel = Inspection();
        inspectionModel.id = inspection['visit_id'];
        inspectionModel.divisionId = inspection['division_id'];
        inspectionModel.districtId = inspection['district_id'];
        inspectionModel.districtName = inspection['district_name'];
        inspectionModel.divisionName = inspection['division_name'];
        inspectionModel.clusterName = inspection['zone_name'];
        inspectionModel.actionPlanDate = inspection['action_plan_date'];
        inspectionModel.visitType = inspection['visit_type_id'];
        inspectionModel.nextInspectionDate = inspection['next_inspection_date'];
        inspectionModel.schoolName = inspection['school_name'];
        inspectionModel.postAddress = inspection['school_address'];
        inspectionModel.headTeacher = inspection['head_teacher'];
        inspectionModel.headPhonenumber = inspection['phone_number'];
        inspectionModel.nofqTeachers = inspection['number_of_teachers'];
        inspectionModel.noufqTeachers = inspection['unqualified_teachers'];
        inspectionModel.totalEnrolledBoys = inspection['enrolment_boys'];
        inspectionModel.totalAttendanceBoys = inspection['attendance_boys'];
        inspectionModel.totalEnrolledGirls = inspection['enrolment_girls'];
        inspectionModel.totalAttendanceGirls = inspection['attendance_girls'];
        inspectionModel.advisor = inspection['lead_advisor_id'];
        inspectionModel.schoolGovernanceChair = inspection['govt_chair_id'];
        inspectionModel.presentVisitationDate =
            inspection['present_visitation_date'];
        inspectionModel.yearOfEstablishment = inspection['establishment_year'];
        inspectionModel.leadInspectorName = inspection['lead_inspector_id'];
        _inspectionList.add(inspectionModel);
        setState(() {
          schoolVisit = inspection;
        });
      });
    });
  }

  getAllRecommendationDetails(String visitId) async {
    var recommendations = await _recomService.readAllKeyEvidencesByNes(visitId);
    _recommendationList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    recommendations.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = int.parse(key_evidence['nes_id']);
        keyEvidenceModel.recomId = key_evidence['recommendation_id'];
        keyEvidenceModel.nesLevelId = key_evidence['nes_level_id'];
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

  getAllDivisionDetails() async {
    Iterable<Division>? d = await DivisionProvider().getAll();
    setState(() {
      divisions = d;
    });
  }

  getAllDistrictDetails(String? division_id) async {
    Iterable<District>? d = await DistrictProvider().getByDivision(division_id);
    setState(() {
      districts = d;
    });
  }

  getAllZoneDetails(String? district_id, String? sector_id) async {
    Iterable<Zone>? z =
        await ZoneProvider().getByDistrict(district_id, sector_id);
    setState(() {
      zones = z;
    });
  }

  getAllSchoolVisitDetails(String? emis) async {
    Iterable<School>? sv = await SchoolProvider().getByZoneAndVisitType(emis);
    setState(() {
      schoolVisits = sv;
    });
  }

  getAllSchoolDetails(String? zone_id) async {
    Iterable<School>? s = await SchoolProvider().getByZone(zone_id);
    setState(() {
      schools = s;
    });
  }

  displayYears() async {
    for (var i = 1900; i <= 2022; i++) {
      List<String> y = [i.toString()];
      setState(() {
        year = y;
      });
    }
  }

  DateTime selectedDate = DateTime.now();
  DateTime selectedNIDate = DateTime.now();

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
        selectedAPDate = picked.toString();
        selectedDate = picked;
      });
    }
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
        selectedNxtInspDate = picked.toString();
        selectedNIDate = picked;
      });
    }
  }

  StepperType stepperType = StepperType.horizontal;
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [];
    return menuItems;
  }

  @override
  void initState() {
    var user = context.read<AccountProvider>().user;
    getAllInspectorDetails(user!['sector_id'].toString());
    getAllDivisionDetails();
    displayYears();
    super.initState();
  }

  List<DropdownMenuItem<String>> get year_list {
    List<DropdownMenuItem<String>> dropDownItems = [];

    for (var i = 2022; i >= 1900; i--) {
      var newDropdown = DropdownMenuItem(
        child: Text(i.toString()),
        value: i.toString(),
      );

      dropDownItems.add(newDropdown);
    }
    return dropDownItems;
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

  TextEditingController textarea = TextEditingController();
  var _formKeySchoolVisit = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Follow-up Form'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(children: [
        Form(
          key: _formKeySchoolVisit,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                    labelText: 'Divisions',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (value) =>
                      value == null ? "Select a Division name" : null,
                  value: selectedDivisionValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDivisionValue = newValue;
                      getAllDistrictDetails(newValue);
                    });
                  },
                  items: divisions?.map((item) {
                    return DropdownMenuItem(
                      value: item.divisionId.toString(),
                      child: Text(item.divisionName.toString()),
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
                    labelText: 'District Name',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (value) =>
                      value == null ? "Select a District name" : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      var user = context.read<AccountProvider>().user;
                      getAllZoneDetails(
                          newValue, user!['sector_id'].toString());
                      selectedDistrictValue = newValue;
                    });
                  },
                  items: districts?.map((item) {
                    return DropdownMenuItem(
                      value: item.districtId.toString(),
                      child: Text(item.districtName.toString()),
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
                      labelText: 'Cluster Name',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) =>
                        value == null ? "Select a Cluster name" : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        getAllSchoolDetails(newValue);
                        selectedClusterValue = newValue;
                      });
                    },
                    items: zones?.map((item) {
                      return DropdownMenuItem(
                        value: item.zoneId.toString(),
                        child: Text(item.zoneName.toString()),
                      );
                    }).toList()),
                SizedBox(
                  height: 25.0,
                ),
                DropdownButtonFormField(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                      labelText: 'School Name',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) =>
                        value == null ? "Select a School name" : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        getAllSchoolVisitDetails(newValue);
                        selectedSchoolValue = newValue;
                      });
                    },
                    items: schools?.map((item) {
                      return DropdownMenuItem(
                        value: item.emisId.toString(),
                        child: Text("${item.schoolName.toString()}"),
                      );
                    }).toList()),
                SizedBox(
                  height: 25.0,
                ),
                DropdownButtonFormField(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                      labelText: 'School Vist',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) =>
                        value == null ? "Select a School visit" : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        getAllRecommendationDetails(newValue!);
                        getAllInspectionDetails(newValue);
                        selectedSchoolValue = newValue;
                      });
                    },
                    items: schoolVisits?.map((item) {
                      return DropdownMenuItem(
                        value: item.visitId.toString(),
                        child: Text(
                            "${item.schoolName.toString()} conducted on ${item.visitationDate}"),
                      );
                    }).toList()),
                SizedBox(
                  height: 25.0,
                ),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                    labelText: 'Lead Inspector Name',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
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
                  items: inspectors
                      .where((d) =>
                          selectedInspectorId != d.userId.toString() &&
                          selectedFirstInspectorId != d.userId.toString() &&
                          selectedSecondInspectorId != d.userId.toString())
                      .map((e) => MultiSelectItem(e.userId.toString(),
                          "${e.firstName.toString()} ${e.lastName.toString()}"))
                      .toList(),
                  onConfirm: (results) {
                    _otherInspectors = results;
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
                          label:
                              Text('STATUS', style: TextStyle(fontSize: 12))),
                    ],
                    rows: _recommendationList.map((item) {
                      var index = _recommendationList.indexOf(item);
                      _followUpComment.add(TextEditingController());
                      _status.add('');
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: 100,
                              child: Text(item.nesId.toString()),
                            ),
                          ),
                          DataCell(Text(item.visitId)),
                          DataCell(
                            TextField(
                              controller: _followUpComment[index],
                              keyboardType: TextInputType.multiline,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Followup comment',
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
                                validator: (value) =>
                                    value == null ? "Select a Status" : null,
                                onChanged: (String? newValue) {
                                  keyStatus = newValue;
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
                TextField(
                  controller: _extraFollowUpComment,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Extra Followup Comment',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.teal,
                      textStyle: const TextStyle(fontSize: 15)),
                  onPressed: () async {
                    if (_formKeySchoolVisit.currentState!.validate()) {
                      var _inspection = Inspection();
                      var user = context.read<AccountProvider>().user;

                      _inspection.headTeacher = schoolVisit['head_teacher'];
                      _inspection.divisionName = schoolVisit['division_id'];
                      _inspection.clusterName = schoolVisit['zone_id'];
                      _inspection.schoolName = schoolVisit['emis_id'];
                      _inspection.districtName = schoolVisit['district_id'];
                      _inspection.headPhonenumber = schoolVisit['phone_number'];
                      _inspection.postAddress = schoolVisit['school_address'];
                      _inspection.nofqTeachers =
                          schoolVisit['number_of_teachers'];
                      _inspection.noufqTeachers =
                          schoolVisit['unqualified_teachers'];
                      _inspection.totalEnrolledBoys =
                          schoolVisit['enrolment_boys'];
                      _inspection.totalEnrolledGirls =
                          schoolVisit['enrolment_girls'];
                      _inspection.totalAttendanceBoys =
                          schoolVisit['attendance_boys'];
                      _inspection.totalAttendanceGirls =
                          schoolVisit['attendance_girls'];
                      _inspection.visitType = '2';
                      _inspection.sync = '';
                      _inspection.presentVisitationDate = currentDate;
                      _inspection.yearOfEstablishment =
                          schoolVisit['establishment_year'];
                      _inspection.actionPlanDate =
                          schoolVisit['action_plan_date'];
                      _inspection.nextInspectionDate =
                          schoolVisit['next_inspection_date'];
                      _inspection.advisor = schoolVisit['lead_advisor_id'];
                      _inspection.schoolGovernanceChair =
                          schoolVisit['govt_chair_id'];
                      _inspection.leadInspectorName = selectedInspectorId;
                      _inspection.firstInspectorName = selectedFirstInspectorId;
                      _inspection.secondInspectorName =
                          selectedSecondInspectorId;
                      _inspection.previousVisitationDate =
                          schoolVisit['prev_visitation_date'];
                      _inspection.asocVisit = schoolVisit['visit_id'];
                      _inspection.sector_id = user!['sector_id'].toString();

                      _otherInspectors.length <= 0
                          ? ''
                          : _inspection.thirdInspectorName =
                              _otherInspectors[0];
                      _otherInspectors.length <= 1
                          ? ''
                          : _inspection.fourthInspectorName =
                              _otherInspectors[1];
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

                      var result =
                          await _inspectionService.SaveInspection(_inspection);
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                  child: Text(hide == true ? '' : 'SUBMIT'),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}
