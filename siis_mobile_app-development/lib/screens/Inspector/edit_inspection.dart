import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/constants.dart';
import 'package:siis_offline/models/Inspection.dart';

import '../../models/user.dart';
import '../../services/InspectionService.dart';
import '../../utils/account_provider.dart';

class EditInspection extends StatefulWidget {
  final Inspection inspection;
  const EditInspection({Key? key, required this.inspection}) : super(key: key);

  @override
  State<EditInspection> createState() => _EditInspectionState();
}

class _EditInspectionState extends State<EditInspection> {
  String? selectedInspectorId;
  String? selectedFirstInspectorId;
  String? selectedSecondInspectorId;
  String? selectedYOEValue;
  String? selectedEstablishmentValue;
  late Iterable<User> inspectors = [];
  var _otherInspectors = [];
  var selectedDivisionValue;
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
  DateTime selectedDate = DateTime.now();
  DateTime selectedNIDate = DateTime.now();
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
      DropdownMenuItem(child: Text(""), value: "null"),
      DropdownMenuItem(child: Text("Form 1-4"), value: "Form 1-4"),
      DropdownMenuItem(child: Text("Form 1-2"), value: "Form 1-2"),
      DropdownMenuItem(child: Text("Form 3-4"), value: "Form 3-4"),
    ];
    return menuItems;
  }

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

  late List<String> _initial;
  @override
  void initState() {
    setState(() {
      selectedEstablishmentValue = widget.inspection.establishment ?? '';
      selectedYOEValue = widget.inspection.yearOfEstablishment ?? '';
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
      var user = context.read<AccountProvider>().user;
      getAllInspectorDetails(user!['sector_id'].toString());
      if (widget.inspection.thirdInspectorName == null &&
          widget.inspection.fourthInspectorName == null) {
        _initial = [];
      }
      if ((widget.inspection.thirdInspectorName == '' ||
              widget.inspection.thirdInspectorName == null) &&
          (widget.inspection.fourthInspectorName == '' ||
              widget.inspection.fourthInspectorName == null)) {
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
              DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                    labelText: 'Year Of Establishment',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  value: widget.inspection.yearOfEstablishment.toString(),
                  validator: (value) =>
                      value == null ? "Select a Year Of Establishment" : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYOEValue = newValue;
                    });
                  },
                  items: year_list),
              SizedBox(
                height: 25.0,
              ),
              DropdownButtonFormField(
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                    labelText: 'Establishment',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  value: widget.inspection.establishment.toString() == ''
                      ? 'null'
                      : widget.inspection.establishment.toString(),
                  validator: (value) =>
                      value == null ? "Select a Establishment" : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedEstablishmentValue = newValue;
                    });
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
              ),
              SizedBox(
                height: 25.0,
              ),
              TextFormField(
                controller: _headTeacher,
                decoration: InputDecoration(
                  labelText: 'Head Teacher',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              TextFormField(
                controller: _headPhonenumber,
                decoration: InputDecoration(
                  labelText: "Head Teacher's Phone",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              SizedBox(
                height: 25.0,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _nofqTeachers,
                      decoration: InputDecoration(
                        labelText: 'Number of Qualified Teachers',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 25.0,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _noufqTeachers,
                      decoration: InputDecoration(
                        labelText: 'Number of Un-Qualified Teachers',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
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
                      controller: _totalEnrolledBoys,
                      decoration: InputDecoration(
                        labelText: 'Total Enrolled Boys',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 25.0,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _totalAttendanceBoys,
                      decoration: InputDecoration(
                        labelText: 'Total Attendance(Boys) ',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
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
                      controller: _totalEnrolledGirls,
                      decoration: const InputDecoration(
                        labelText: 'Total Enrolled Girls',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 25.0,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _totalAttendanceGirls,
                      decoration: InputDecoration(
                        labelText: 'Total Attendance(Girls)',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                      ),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Action Plan Date",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                ),
                onTap: () {
                  _selectDate(context);
                },
                controller: TextEditingController(
                    text: selectedDate.toLocal().toString().split(' ')[0]),
              ),
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
              SizedBox(
                height: 25.0,
              ),
              TextFormField(
                controller: _advisor,
                decoration: InputDecoration(
                  labelText: "Advisor",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              TextFormField(
                controller: _schoolGovernanceChair,
                decoration: InputDecoration(
                  labelText: "School Governance chair",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                ),
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
                    _initial.clear();
                    _otherInspectors = results;
                  });
                },
              ),
              SizedBox(
                height: 25.0,
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
                        _inspection.yearOfEstablishment = selectedYOEValue;
                        _inspection.actionPlanDate = actionPlanDate.toString();
                        _inspection.nextInspectionDate =
                            nextInspectionDate.toString();
                        _inspection.advisor = _advisor.text;
                        _inspection.schoolGovernanceChair =
                            _schoolGovernanceChair.text;
                        _inspection.visitType = '1';
                        _inspection.presentVisitationDate =
                            selectedNIDate.toString().split(' ')[0];
                        _inspection.previousVisitationDate =
                            widget.inspection.previousVisitationDate;
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
                        _inspection.establishment = selectedEstablishmentValue;
                        var result = await _inspectionService.UpdateInspection(
                            _inspection);
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
