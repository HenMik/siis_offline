import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siis_offline/constants.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:siis_offline/models/inspector_model.dart';
import 'package:siis_offline/utils/inspection_provider.dart';

import '../../models/Inspection.dart';
import '../../models/district.dart';
import '../../models/division.dart';
import '../../models/school.dart';
import '../../models/user.dart';
import '../../models/zone.dart';
import '../../preferences_services.dart';
import '../../services/InspectionService.dart';
import '../../utils/account_provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';

class InspectionForm extends StatefulWidget {
  @override
  _InspectionFormState createState() => _InspectionFormState();
}

class Animal {
  final int id;
  final String name;

  Animal({
    required this.id,
    required this.name,
  });
}

class _InspectionFormState extends State<InspectionForm> {
  final _preferencesService = PreferencesService();
  bool hide = false;
  late Iterable<User> inspectors = [];
  late Iterable<Division>? divisions = [];
  late Iterable<District>? districts = [];
  late Iterable<Zone>? zones = [];
  late Iterable<School>? schools = [];
  late Iterable<School>? schoolVisitsByDate = [];
  late List<String> year = [];
  var _otherInspectors = [];
  String? selectedDivisionValue;
  String? selectedPVD;
  String? selectedDistrictValue;
  String? selectedClusterValue;
  String? selectedSchoolValue;
  String? selectedVisitTypeValue;
  String? selectedYOEValue;
  String? selectedAPDate;
  String? selectedNxtInspDate;
  String? selectedInspectorId;
  String? selectedFirstInspectorId;
  String? selectedSecondInspectorId;
  String? selectedEstablishmentValue;
  String? sectotId;
  String? emis_id;
  late var form;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var _headTeacherController = TextEditingController();
  var _headPhonenumber = TextEditingController();
  var _postAddress = TextEditingController();
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
  var _inspectionService = InspectionService();
  late var id;
  late var name;

  int _currentStep = 0;

  Future<void> insertToForm({required key, required value}) async {
    final SharedPreferences prefs = await _prefs;
    form = prefs.setString(key, value);
  }

  getAllInspectorDetails(String? sector_id) async {
    Iterable<User>? u = await UserProvider().getAll(sector_id.toString());
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

  getAllSchoolDetails(String? zone_id) async {
    Iterable<School>? s = await SchoolProvider().getByZone(zone_id);
    setState(() {
      schools = s;
    });
  }

  getAllSchoolDetailsByDate(String? date, String? emis) async {
    Iterable<School>? svbd = await SchoolProvider().getByDate(date, emis);
    setState(() {
      schoolVisitsByDate = svbd;
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
  DateTime selectedPdate = DateTime.now();

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
        _saveSettings();
        getAllSchoolDetailsByDate(
            selectedNxtInspDate ?? currentDate, selectedSchoolValue);
      });
    }
  }

  Future<void> _previousInspectionDate(BuildContext context) async {
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
        initialDate: selectedPdate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedPdate) {
      setState(() {
        selectedPVD = picked.toString();
        selectedPdate = picked;
        _saveSettings();
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
    _populateFields();
    super.initState();
  }

  void _populateFields() async {
    final settings = await _preferencesService.getSettings();
    setState(() {
      selectedPVD = settings.previousVisitationDate ?? currentDate;
      selectedAPDate = currentDate;
      selectedNxtInspDate = settings.presentVisitationDate ?? currentDate;
      _postAddress.text = settings.schoolAddress;
      settings!.yearOfEstablishment!.isEmpty
          ? selectedYOEValue = null
          : selectedYOEValue = settings!.yearOfEstablishment;
      settings!.leadInspectorName!.isEmpty
          ? selectedInspectorId = null
          : selectedInspectorId = settings!.leadInspectorName;
      settings!.firstInspectorName!.isEmpty
          ? selectedFirstInspectorId = null
          : selectedFirstInspectorId = settings!.firstInspectorName;
      settings!.secondInspectorName!.isEmpty
          ? selectedSecondInspectorId = null
          : selectedSecondInspectorId = settings!.secondInspectorName;
      settings!.establishment!.isEmpty
          ? selectedEstablishmentValue = null
          : selectedEstablishmentValue = settings!.establishment;
      settings!.divisionId!.isEmpty
          ? selectedDivisionValue = null
          : selectedDivisionValue = settings!.divisionId.toString();
      getAllDistrictDetails(settings!.divisionId.toString());
      settings!.districtId!.isEmpty
          ? selectedDistrictValue = null
          : selectedDistrictValue = settings!.districtId;
      var user = context.read<AccountProvider>().user;
      getAllZoneDetails(
          settings!.districtId.toString(), user!['sector_id'].toString());
      settings!.zoneId!.isEmpty
          ? selectedClusterValue = null
          : selectedClusterValue = settings!.zoneId;
      getAllSchoolDetails(settings!.zoneId);
      getAllSchoolDetailsByDate(
          settings.presentVisitationDate ?? currentDate, settings.schoolId);
      settings!.schoolId!.isEmpty
          ? selectedSchoolValue = null
          : selectedSchoolValue = settings!.schoolId;
      _headTeacherController.text = settings.headTeacher;
      _headPhonenumber.text = settings.phoneNumber;
      _nofqTeachers.text = settings.nofqTeachers;
      _noufqTeachers.text = settings.noufqTeachers;
      _totalEnrolledBoys.text = settings.totalEnrolledBoys;
      _totalEnrolledGirls.text = settings.totalEnrolledGirls;
      _totalAttendanceBoys.text = settings.totalAttendanceBoys;
      _totalAttendanceGirls.text = settings.totalAttendanceGirls;
      _advisor.text = settings.advisor;
      _schoolGovernanceChair.text = settings.schoolGovernanceChair;
      selectedNIDate = DateTime.parse(settings.presentVisitationDate);
      selectedPdate = DateTime.parse(settings.previousVisitationDate);
    });
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

  List<DropdownMenuItem<String>> get establishment {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Form 1-4"), value: "Form 1-4"),
      DropdownMenuItem(child: Text("Form 1-2"), value: "Form 1-2"),
      DropdownMenuItem(child: Text("Form 3-4"), value: "Form 3-4"),
    ];
    return menuItems;
  }

  List<GlobalKey<FormState>> _formKeySchoolVisit = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  TextEditingController textarea = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspection Form'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Theme(
                data: ThemeData(
                  colorScheme: Theme.of(context)
                      .colorScheme
                      .copyWith(primary: Colors.teal),
                ),
                child: Stepper(
                  controlsBuilder: (BuildContext ctx, ControlsDetails dtl) {
                    return Row(
                      children: <Widget>[
                        if (_currentStep == 2)
                          Row(children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.teal,
                                  textStyle: const TextStyle(fontSize: 15)),
                              onPressed: () async {
                                if (_formKeySchoolVisit[_currentStep]
                                    .currentState!
                                    .validate()) {
                                  if (schoolVisitsByDate != null) {
                                    SweetAlertV2.show(context,
                                        title: "error",
                                        subtitle:
                                            "School visit with the same date already exists",
                                        style: SweetAlertV2Style.error);
                                  } else {
                                    var _inspection = Inspection();
                                    var user =
                                        context.read<AccountProvider>().user;
                                    _inspection.headTeacher =
                                        _headTeacherController.text;
                                    _inspection.divisionName =
                                        selectedDivisionValue;
                                    _inspection.clusterName =
                                        selectedClusterValue;
                                    _inspection.schoolName =
                                        selectedSchoolValue;
                                    _inspection.districtName =
                                        selectedDistrictValue;
                                    _inspection.headPhonenumber =
                                        _headPhonenumber.text;
                                    _inspection.postAddress = _postAddress.text;
                                    _inspection.nofqTeachers =
                                        _nofqTeachers.text;
                                    _inspection.noufqTeachers =
                                        _noufqTeachers.text;
                                    _inspection.totalEnrolledBoys =
                                        _totalEnrolledBoys.text;
                                    _inspection.totalEnrolledGirls =
                                        _totalEnrolledGirls.text;
                                    _inspection.totalAttendanceBoys =
                                        _totalAttendanceBoys.text;
                                    _inspection.totalAttendanceGirls =
                                        _totalAttendanceGirls.text;
                                    _inspection.visitType = '1';
                                    _inspection.nextInspectionDate =
                                        currentDate;
                                    _inspection.yearOfEstablishment =
                                        selectedYOEValue;
                                    _inspection.actionPlanDate = selectedAPDate;
                                    _inspection.presentVisitationDate =
                                        selectedNxtInspDate;
                                    _inspection.advisor = _advisor.text;
                                    _inspection.schoolGovernanceChair =
                                        _schoolGovernanceChair.text;
                                    _inspection.leadInspectorName =
                                        selectedInspectorId;
                                    _inspection.firstInspectorName =
                                        selectedFirstInspectorId;
                                    _inspection.secondInspectorName =
                                        selectedSecondInspectorId;
                                    _inspection.previousVisitationDate =
                                        selectedPVD;
                                    _otherInspectors.length <= 0
                                        ? ''
                                        : _inspection.thirdInspectorName =
                                            _otherInspectors[0];
                                    _otherInspectors.length <= 1
                                        ? ''
                                        : _inspection.fourthInspectorName =
                                            _otherInspectors[1];
                                    _inspection.sector_id =
                                        user!['sector_id'].toString();
                                    _inspection.sync = '1';
                                    _inspection.establishment =
                                        selectedEstablishmentValue;
                                    var result =
                                        await _inspectionService.SaveInspection(
                                            _inspection);
                                    final SharedPreferences settings =
                                        await SharedPreferences.getInstance();
                                    settings.clear();
                                    Navigator.pop(context, result);
                                  }
                                }
                              },
                              child: Text(hide == true ? '' : 'SUBMIT'),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  primary: Colors.white,
                                  backgroundColor: Colors.red,
                                  textStyle: const TextStyle(fontSize: 15)),
                              onPressed: dtl.onStepCancel,
                              child: Text(hide == true ? '' : 'BACK'),
                            ),
                          ]),
                        if (_currentStep == 0)
                          TextButton(
                            style: TextButton.styleFrom(
                                primary: Colors.white,
                                backgroundColor: Colors.teal,
                                textStyle: const TextStyle(fontSize: 15)),
                            onPressed: dtl.onStepContinue,
                            child: Text(hide == true ? '' : 'NEXT'),
                          ),
                        if (_currentStep == 1)
                          Row(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.teal,
                                    textStyle: const TextStyle(fontSize: 15)),
                                onPressed: dtl.onStepContinue,
                                child: Text(hide == true ? '' : 'NEXT'),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: Colors.red,
                                    textStyle: const TextStyle(fontSize: 15)),
                                onPressed: dtl.onStepCancel,
                                child: Text(hide == true ? '' : 'BACK'),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                  type: stepperType,
                  physics: ScrollPhysics(),
                  currentStep: _currentStep,
                  onStepTapped: (step) => tapped(step),
                  onStepContinue: () {
                    setState(() {
                      if (_formKeySchoolVisit[_currentStep]
                          .currentState!
                          .validate()) {
                        _currentStep++;
                      }
                    });
                  },
                  onStepCancel: cancel,
                  steps: <Step>[
                    Step(
                      title: new Text('School location'),
                      content: Form(
                        key: _formKeySchoolVisit[0],
                        child: Column(
                          children: <Widget>[
                            DropdownButtonFormField(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 6),
                                labelText: 'Divisions',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              validator: (value) => value == null
                                  ? "Select a Division name"
                                  : null,
                              value: selectedDivisionValue,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedDivisionValue = newValue;
                                  selectedDistrictValue = null;
                                  selectedClusterValue = null;
                                  selectedSchoolValue = null;
                                  getAllDistrictDetails(newValue);
                                });
                                _saveSettings();
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
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 6),
                                labelText: 'District Name',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              value: selectedDistrictValue,
                              validator: (value) => value == null
                                  ? "Select a District name"
                                  : null,
                              onChanged: (String? newValue) {
                                setState(() {
                                  var user =
                                      context.read<AccountProvider>().user;
                                  getAllZoneDetails(
                                      newValue, user!['sector_id'].toString());
                                  selectedDistrictValue = newValue;
                                  selectedClusterValue = null;
                                  selectedSchoolValue = null;
                                });
                                _saveSettings();
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
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 6),
                                  labelText: 'Cluster Name',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                validator: (value) => value == null
                                    ? "Select a Cluster name"
                                    : null,
                                value: selectedClusterValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    getAllSchoolDetails(newValue);
                                    selectedClusterValue = newValue;
                                    selectedSchoolValue = null;
                                  });
                                  _saveSettings();
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
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 6),
                                  labelText: 'School Name',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                value: selectedSchoolValue,
                                validator: (value) => value == null
                                    ? "Select a School name"
                                    : null,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedSchoolValue = newValue;
                                    getAllSchoolDetailsByDate(
                                        selectedNxtInspDate ?? currentDate,
                                        newValue);
                                  });
                                  _saveSettings();
                                },
                                items: schools?.map((item) {
                                  return DropdownMenuItem(
                                    value: item.emisId.toString(),
                                    child: Text(item.schoolName.toString()),
                                  );
                                }).toList()),
                            SizedBox(
                              height: 25.0,
                            ),
                            DropdownButtonFormField(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 6),
                                  labelText: 'Year Of Establishment',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                validator: (value) => value == null
                                    ? "Select a Year Of Establishment"
                                    : null,
                                value: selectedYOEValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedYOEValue = newValue;
                                  });
                                  _saveSettings();
                                },
                                items: year_list),
                            SizedBox(
                              height: 25.0,
                            ),
                            DropdownButtonFormField(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 6),
                                  labelText: 'Establishment',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                validator: (value) => value == null
                                    ? "Select a Establishment"
                                    : null,
                                value: selectedEstablishmentValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedEstablishmentValue = newValue;
                                  });
                                  _saveSettings();
                                },
                                items: establishment),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return ("Postal address is required");
                                }
                              },
                              controller: _postAddress,
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Postal Adress',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => {_saveSettings()},
                            ),
                          ],
                        ),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 0
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: new Text('Stuff and Student details'),
                      content: Form(
                        key: _formKeySchoolVisit[1],
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return ("Headteacher name is required");
                                }
                              },
                              controller: _headTeacherController,
                              //  initialValue: form['head_teacher'],
                              decoration: InputDecoration(
                                labelText: 'Head Teacher',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => {_saveSettings()},
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return ("Phone number is required");
                                }
                              },
                              controller: _headPhonenumber,
                              //   initialValue: form['head_number'],
                              decoration: InputDecoration(
                                labelText: "Head Teacher's Phone",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => {_saveSettings()},
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return ("Number of qualified teachers is required");
                                      }
                                    },
                                    controller: _nofqTeachers,
                                    //  initialValue: form['qualified_teachers'],
                                    decoration: InputDecoration(
                                      labelText: 'Number of Qualified Teachers',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => {_saveSettings()},
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 25.0,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return ("Number of unqualified teachers is required");
                                      }
                                    },
                                    controller: _noufqTeachers,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Number of Un-Qualified Teachers',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => {_saveSettings()},
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return ("Total number of enrolled boys is required");
                                      }
                                    },
                                    controller: _totalEnrolledBoys,
                                    decoration: InputDecoration(
                                      labelText: 'Total Enrolled Boys',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => {_saveSettings()},
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 25.0,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return ("Total number of attendance boys is required");
                                      }
                                    },
                                    controller: _totalAttendanceBoys,
                                    decoration: InputDecoration(
                                      labelText: 'Total Attendance(Boys) ',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => {_saveSettings()},
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return ("Total number of enrolled girls is required");
                                      }
                                    },
                                    controller: _totalEnrolledGirls,
                                    decoration: InputDecoration(
                                      labelText: 'Total Enrolled Girls',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    onChanged: (value) => {
                                      insertToForm(
                                          key: 'total_enrolleld_girls',
                                          value: value),
                                      _saveSettings()
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 25.0,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return ("Total number of attendance girls is required");
                                      }
                                    },
                                    controller: _totalAttendanceGirls,
                                    decoration: InputDecoration(
                                      labelText: 'Total Attendance(Girls)',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) => {_saveSettings()},
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: false),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 1
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                    Step(
                      title: new Text('Inspection details'),
                      content: Form(
                          key: _formKeySchoolVisit[2],
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                    text: selectedNIDate
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0]),
                                decoration: InputDecoration(
                                  labelText: "Present VIsitation Date",
                                  border: OutlineInputBorder(),
                                ),
                                onTap: () {
                                  _nextInspectionDate(context);
                                },
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                    text: selectedPdate
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0]),
                                decoration: InputDecoration(
                                  labelText: "Previous Inspection Date",
                                  border: OutlineInputBorder(),
                                ),
                                onTap: () {
                                  _previousInspectionDate(context);
                                },
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Advisor is required");
                                  }
                                },
                                controller: _advisor,
                                decoration: InputDecoration(
                                  labelText: "Advisor",
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) => {_saveSettings()},
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Governance chair is required");
                                  }
                                },
                                controller: _schoolGovernanceChair,
                                decoration: InputDecoration(
                                  labelText: "School Governance chair",
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) => {_saveSettings()},
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 6),
                                  labelText: 'Lead Inspector Name',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                value: selectedInspectorId,
                                validator: (value) => value == null
                                    ? "Select inspector name"
                                    : null,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    var user =
                                        context.read<AccountProvider>().user;
                                    selectedInspectorId = newValue;
                                    getAllInspectorDetails(
                                        user!['sector_id'].toString());
                                    _saveSettings();
                                  });
                                },
                                items: inspectors
                                    ?.where((d) =>
                                        selectedFirstInspectorId !=
                                            d.userId.toString() &&
                                        selectedSecondInspectorId !=
                                            d.userId.toString())
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
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 6),
                                  labelText: 'First Inspector Name',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                value: selectedFirstInspectorId,
                                validator: (value) => value == null
                                    ? "Select inspector name"
                                    : null,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    var user =
                                        context.read<AccountProvider>().user;
                                    selectedFirstInspectorId = newValue;
                                    getAllInspectorDetails(
                                        user!['sector_id'].toString());
                                    _saveSettings();
                                  });
                                },
                                items: inspectors
                                    ?.where((d) =>
                                        selectedInspectorId !=
                                        d.userId.toString())
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
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 6),
                                  labelText: 'second Inspector Name',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                ),
                                value: selectedSecondInspectorId,
                                validator: (value) => value == null
                                    ? "Select inspector name"
                                    : null,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    var user =
                                        context.read<AccountProvider>().user;
                                    selectedSecondInspectorId = newValue;
                                    getAllInspectorDetails(
                                        user!['sector_id'].toString());
                                    _saveSettings();
                                  });
                                },
                                items: inspectors
                                    ?.where((d) =>
                                        selectedInspectorId !=
                                            d.userId.toString() &&
                                        selectedFirstInspectorId !=
                                            d.userId.toString())
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
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
                                        selectedInspectorId !=
                                            d.userId.toString() &&
                                        selectedFirstInspectorId !=
                                            d.userId.toString() &&
                                        selectedSecondInspectorId !=
                                            d.userId.toString())
                                    .map((e) => MultiSelectItem(
                                        e.userId.toString(),
                                        "${e.firstName.toString()} ${e.lastName.toString()}"))
                                    .toList(),
                                onConfirm: (results) {
                                  _otherInspectors = results;
                                },
                              ),
                              SizedBox(
                                height: 25.0,
                              ),
                            ],
                          )),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 2
                          ? StepState.complete
                          : StepState.disabled,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.list),
        backgroundColor: kPrimaryColor,
        onPressed: switchStepsType,
      ),
    );
  }

  void _saveSettings() {
    var xul, district, zone, lead, first, second;
    selectedSchoolValue == null ? xul = '' : xul = selectedSchoolValue;
    selectedDistrictValue == null
        ? district = ''
        : district = selectedDistrictValue;
    selectedClusterValue == null ? zone = '' : zone = selectedClusterValue;
    selectedInspectorId == null ? lead = '' : lead = selectedInspectorId;
    selectedFirstInspectorId == null
        ? first = ''
        : first = selectedFirstInspectorId;
    selectedSecondInspectorId == null
        ? second = ''
        : second = selectedSecondInspectorId;
    final newSettings = InspectorModel(
      schoolAddress: _postAddress.text,
      headTeacher: _headTeacherController.text,
      phoneNumber: _headPhonenumber.text,
      nofqTeachers: _nofqTeachers.text,
      noufqTeachers: _noufqTeachers.text,
      totalEnrolledBoys: _totalEnrolledBoys.text,
      totalEnrolledGirls: _totalEnrolledGirls.text,
      totalAttendanceBoys: _totalAttendanceBoys.text,
      totalAttendanceGirls: _totalAttendanceGirls.text,
      advisor: _advisor.text,
      schoolGovernanceChair: _schoolGovernanceChair.text,
      yearOfEstablishment: selectedYOEValue,
      establishment: selectedEstablishmentValue,
      divisionId: selectedDivisionValue,
      districtId: district,
      leadInspectorName: lead,
      firstInspectorName: first,
      secondInspectorName: second,
      zoneId: zone,
      schoolId: xul,
      presentVisitationDate: selectedNxtInspDate,
      previousVisitationDate: selectedPVD,
    );
    _preferencesService.saveSettings(newSettings);
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 2 ? setState(() => _currentStep += 1) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }
}
