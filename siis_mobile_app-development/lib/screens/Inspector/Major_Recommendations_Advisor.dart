import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../components/AppDrawer.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/actionPlan.dart';
import '../../models/recommendation.dart';
import '../../services/ActionPlanService.dart';
import '../../services/InspectionService.dart';
import '../../services/RecommendationService.dart';
import '../../utils/account_provider.dart';
import 'ActionPlanForm.dart';

class Recommendations extends StatefulWidget {
  const Recommendations({Key? key}) : super(key: key);

  get recommendation => null;

  @override
  _Recommendations createState() => _Recommendations();
}

class _Recommendations extends State<Recommendations> {
  String? selectedStartDate;
  String? selectedDueDate;
  String? selectedActivityStatus;
  String? selectedPriorityLevel;
  String? visit_id;
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
  late List<Inspection> _inspectionList = <Inspection>[];
  final _inspectionService = InspectionService();

  getAllInspectionDetails() async {
    var user = context.read<AccountProvider>().user;
    var inspections = await _inspectionService.readAllInspectionsByZoneId(
        user!['sector_id'].toString(), user!['zone_id']);
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
      });
    });
  }

  getAllRecommendationDetails(String visitId) async {
    var recommendations =
        await _recomService.readAllRecommendationsByVisitId(visitId);
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

  getAllActions(String visitId) async {
    var actionsplans = await _actionPlanService.readAllActionPlans(visitId);
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
        initialDate: startDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != startDate) {
      setState(() {
        selectedStartDate = picked.toString();
        startDate = picked;
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
        initialDate: dueDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != dueDate) {
      setState(() {
        selectedDueDate = picked.toString();
        dueDate = picked;
      });
    }
  }

  late bool _viewTile = true;
  late bool _viewButton = true;
  late bool viewIconButton = true;
  @override
  void initState() {
    var user = context.read<AccountProvider>().user;
    if (user!['user_role'] == 'Secondary Advisor') {
      _viewTile = false;
    }
    if (user!['user_role'] == 'Inspector') {
      _viewButton = false;
      viewIconButton = false;
    }
    getAllInspectionDetails();
    super.initState();
  }

  List<DropdownMenuItem<String>> get nes {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("1. Outcomes for students"), value: "1"),
      DropdownMenuItem(child: Text("2. The teaching process"), value: "2"),
      DropdownMenuItem(child: Text("3. Leadership"), value: "3"),
      DropdownMenuItem(child: Text("4. Management"), value: "4"),
    ];
    return menuItems;
  }

  _deleteAPFormDialog(
      BuildContext context, actionplan_id, _actionPlan_description) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: Text(
              'Are You Sure to Delete ${_actionPlan_description}?',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.red),
                  onPressed: () async {
                    var result = await _actionPlanService
                        .deleteActionplan(actionplan_id);
                    if (result != null) {
                      setState(() {
                        getAllActions(visit_id!);
                        Navigator.of(context, rootNavigator: true).pop();
                      });
                      _showSuccessSnackBar('Action plan Deleted Successfully');
                    }
                  },
                  child: const Text('Delete')),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }

  _deleteFormDialog(
      BuildContext context, recommendation_id, recommendation_description) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: Text(
              'Are You Sure to Delete ${recommendation_description}?',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.red),
                  onPressed: () async {
                    var result = await _recomService
                        .deleteRecommendation2(recommendation_id);
                    var result2 = await _recomService
                        .deleteActionByRecommendation(recommendation_id);
                    if (result != null && result2 != null) {
                      setState(() {
                        getAllActions(visit_id!);
                        Navigator.of(context, rootNavigator: true).pop();
                      });
                      _showSuccessSnackBar(
                          'Recommendation Deleted Successfully');
                    }
                  },
                  child: const Text('Delete')),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }

  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Action plans'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        leading: Builder(
          builder: (BuildContext appBarContext) {
            return IconButton(
                onPressed: () {
                  AppDrawer.of(appBarContext)?.toggle();
                },
                icon: Icon(Icons.menu_rounded));
          },
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: <Widget>[
                  Text('Home',
                      style: TextStyle(
                        fontSize: 15,
                      )),
                  Icon(Icons.arrow_right),
                  Text('Action plans',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text("Action plans",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                        labelText: 'INSPECTION NAME',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      validator: (value) =>
                          value == null ? "Select a Inspection name" : null,
                      onChanged: (String? newValue) {
                        setState(() {
                          getAllRecommendationDetails(newValue!);
                          visit_id = newValue;
                          getAllActions(visit_id!);
                        });
                      },
                      items: _inspectionList?.map((item) {
                        return DropdownMenuItem(
                          value: item.id.toString(),
                          child: Text(
                              "${item.schoolName.toString()} conducted on ${item.presentVisitationDate}"),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
            Divider(color: Colors.grey),
            _recommendationList.isEmpty
                ? Center(
                    child: Image.asset("assets/images/empty.png"),
                  )
                : ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _recommendationList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 30, horizontal: 0),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          textColor: Colors.teal,
                          title: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${_recommendationList[index].description}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Row(children: [
                                    Text(
                                      "Start Date:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(' '),
                                    SizedBox(width: 20),
                                    Text(
                                      "End Date:",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      ' ',
                                    ),
                                  ]),
                                ],
                              )
                            ],
                          ),
                          trailing: _viewTile
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _description.text =
                                                _recommendationList[index]
                                                    .description;
                                          });
                                          showModalBottomSheet<void>(
                                            isScrollControlled: true,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            20.0))),
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Wrap(
                                                children: [
                                                  Center(
                                                    child: Padding(
                                                      padding: EdgeInsets.fromLTRB(
                                                          20,
                                                          20,
                                                          20,
                                                          MediaQuery.of(context)
                                                                  .viewInsets
                                                                  .bottom +
                                                              20),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Text(
                                                              'Edit Major Strength',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                              )),
                                                          SizedBox(
                                                            height: 25.0,
                                                          ),
                                                          TextFormField(
                                                            controller:
                                                                _description,
                                                            keyboardType:
                                                                TextInputType
                                                                    .multiline,
                                                            maxLines: 4,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  'Description',
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 25.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.teal,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          _deleteFormDialog(
                                              context,
                                              _recommendationList[index].id,
                                              _recommendationList[index]
                                                  .description);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        )),
                                    Icon(
                                      _customTileExpanded
                                          ? Icons.arrow_drop_down_circle
                                          : Icons.arrow_drop_down,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _customTileExpanded
                                          ? Icons.arrow_drop_down_circle
                                          : Icons.arrow_drop_down,
                                    ),
                                  ],
                                ),
                          children: [
                            Row(children: <Widget>[
                              viewIconButton
                                  ? IconButton(
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ActionPlanForm(
                                                      inspection:
                                                          _inspectionList[
                                                              index],
                                                      recommendation:
                                                          _recommendationList[
                                                              index],
                                                    ))).then(
                                          (data) {
                                            if (data != null) {
                                              getAllActions(visit_id!);
                                              _showSuccessSnackBar(
                                                  'Activity Added Successfully');
                                            }
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.red,
                                      ),
                                    )
                                  : Container(),
                            ]),
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  sortAscending: true,
                                  sortColumnIndex: 0,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => Color(0xFFF3EDE8)),
                                  border: const TableBorder(
                                    top: BorderSide(
                                        color: Colors.grey, width: 0.5),
                                    bottom: BorderSide(
                                        color: Color(0xD8E38282), width: 1.5),
                                    left: BorderSide(
                                        color: Colors.grey, width: 0.5),
                                    right: BorderSide(
                                        color: Colors.grey, width: 0.5),
                                    horizontalInside: BorderSide(
                                        color: Colors.grey, width: 0.5),
                                    verticalInside: BorderSide(
                                        color: Color(0xD8E38282), width: 1.5),
                                  ),
                                  columns: [
                                    DataColumn(
                                        label: Text('Activity',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14))),
                                    DataColumn(
                                        label: Text('Start Date',
                                            style: TextStyle(fontSize: 14))),
                                    DataColumn(
                                        label: Text('End Date',
                                            style: TextStyle(fontSize: 14))),
                                    DataColumn(
                                        label: Text('Budget',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ))),
                                    DataColumn(
                                        label: Text('Progress',
                                            style: TextStyle(fontSize: 14))),
                                    DataColumn(
                                        label: Text('Status Remarks',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                            ))),
                                    DataColumn(
                                        label: Text('Edit',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ))),
                                    DataColumn(
                                        label: Text('Delete',
                                            style: TextStyle(fontSize: 14))),
                                  ],
                                  rows: _actionPlanList
                                      .where((d) =>
                                          d.recommendationId ==
                                          _recommendationList[index].id)
                                      .map((item) {
                                    if (item.activityStatus == '0') {
                                      progress = '0%';
                                    }
                                    if (item.activityStatus == '1') {
                                      progress = '25%';
                                    }
                                    if (item.activityStatus == '2') {
                                      progress = '50%';
                                    }
                                    if (item.activityStatus == '3') {
                                      progress = '75%';
                                    }
                                    if (item.activityStatus == '4') {
                                      progress = '100%';
                                    }

                                    return DataRow(
                                        onLongPress: () => {
                                              _deleteAPFormDialog(context,
                                                  item.id, item.activityName)
                                            },
                                        cells: [
                                          DataCell(Text(item.activityName)),
                                          DataCell(Text(item.activityStartDate
                                              .split(' ')[0])),
                                          DataCell(Text(item.activityFinishDate
                                              .split(' ')[0])),
                                          DataCell(Text(
                                              'MWK ${item.activityBudget}')),
                                          DataCell(Text(progress)),
                                          DataCell(Text(item.statusRemarks)),
                                          DataCell(_viewButton
                                              ? IconButton(
                                                  onPressed: () async {
                                                    IconButton(
                                                      onPressed: () async {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ActionPlanForm(
                                                                          inspection:
                                                                              _inspectionList[index],
                                                                          recommendation:
                                                                              _recommendationList[index],
                                                                        ))).then(
                                                          (data) {
                                                            if (data != null) {
                                                              getAllActions(
                                                                  visit_id!);
                                                              _showSuccessSnackBar(
                                                                  'Activity Added Successfully');
                                                            }
                                                          },
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons.add,
                                                        color: Colors.red,
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.teal,
                                                  ),
                                                )
                                              : Container()),
                                          DataCell(_viewButton
                                              ? IconButton(
                                                  onPressed: () async {
                                                    _deleteAPFormDialog(
                                                        context,
                                                        item.id,
                                                        item.activityName);
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : Container()),
                                          // DataCell(Text("1")),
                                          // DataCell(Text("1")),
                                          // DataCell(Text("1")),
                                        ]);
                                  }).toList(),
                                )),
                          ],
                          onExpansionChanged: (bool expanded) {
                            setState(() => _customTileExpanded = expanded);
                          },
                        ),
                      );
                    }),
          ],
        ),
      ),
    );
  }
}
