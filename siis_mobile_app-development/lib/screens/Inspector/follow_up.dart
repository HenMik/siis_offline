import 'dart:convert';

import 'package:dart_date/dart_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:siis_offline/screens/Inspector/edit_inspection.dart';
import 'package:siis_offline/screens/Inspector/follow_up_report.dart';
import 'package:siis_offline/screens/Inspector/view_inspection.dart';
import 'package:siis_offline/screens/Inspector/control_panel.dart';

import '../../components/AppDrawer.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/user.dart';
import '../../services/InspectionService.dart';
import '../../utils/account_provider.dart';
import 'edit_followup.dart';
import 'follow_up_form.dart';
import 'inspection_form.dart';

class FollowUp extends StatefulWidget {
  const FollowUp({Key? key}) : super(key: key);
  @override
  _FollowUpState createState() => _FollowUpState();
}

class _FollowUpState extends State<FollowUp> {
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Follow-up Inspection');
  late List<Inspection> _inspectionList = <Inspection>[];
  List<Inspection> currentInspectionList = <Inspection>[];
  final _inspectionService = InspectionService();
  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(message),
      ),
    );
  }

  int page = 1;
  int pageCount = 10;
  int startAt = 0;
  late int endAt;
  int totalPages = 0;
  _deleteFormDialog(BuildContext context, inspectionId) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: const Text(
              'Are You Sure to Delete this Followup?',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.red),
                  onPressed: () async {
                    var result =
                        await _inspectionService.deleteInspection(inspectionId);
                    if (result != null) {
                      Navigator.of(context, rootNavigator: true).pop();
                      setState(() {
                        getAllInspectionDetails();
                      });
                      _showSuccessSnackBar('Followup Deleted Successfully');
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

  getAllInspectionDetails() async {
    var user = context.read<AccountProvider>().user;
    var inspections = await _inspectionService
        .readAllInspectionsByVisitType(user!['sector_id'].toString());
    _inspectionList = <Inspection>[];
    inspections.forEach((inspection) {
      setState(() {
        var inspectionModel = Inspection();
        inspectionModel.id = inspection['visit_id'];
        inspectionModel.districtName = inspection['district_id'];
        inspectionModel.divisionName = inspection['division_id'];
        inspectionModel.clusterName = inspection['zone_id'];
        inspectionModel.actionPlanDate = inspection['action_plan_date'];
        inspectionModel.visitType = inspection['visit_type_id'];
        inspectionModel.nextInspectionDate = inspection['next_inspection_date'];
        inspectionModel.schoolName = inspection['school_name'];
        inspectionModel.postAddress = inspection['school_address'];
        inspectionModel.emisId = inspection['emis_id'];
        inspectionModel.headTeacher = inspection['head_teacher'];
        inspectionModel.headPhonenumber = inspection['phone_number'];
        inspectionModel.nofqTeachers = inspection['number_of_teachers'];
        inspectionModel.noufqTeachers = inspection['unqualified_teachers'];
        inspectionModel.totalEnrolledBoys = inspection['enrolment_boys'];
        inspectionModel.totalAttendanceBoys = inspection['attendance_boys'];
        inspectionModel.totalEnrolledGirls = inspection['enrolment_girls'];
        inspectionModel.totalAttendanceGirls = inspection['attendance_girls'];
        inspectionModel.leadInspectorName = inspection['lead_inspector_id'];
        inspectionModel.firstInspectorName = inspection['first_inspector_id'];
        inspectionModel.asocVisit = inspection['assoc_visit'];
        inspectionModel.secondInspectorName = inspection['second_inspector_id'];
        inspectionModel.advisor = inspection['lead_advisor_id'];
        inspectionModel.schoolGovernanceChair = inspection['govt_chair_id'];
        inspectionModel.presentVisitationDate =
            inspection['present_visitation_date'];
        inspectionModel.yearOfEstablishment = inspection['establishment_year'];
        inspectionModel.thirdInspectorName = inspection['third_inspector_id'];
        inspectionModel.fourthInspectorName = inspection['fourth_inspector_id'];
        _inspectionList.add(inspectionModel);
        _isLoading = false;
      });
    });
    if (_inspectionList.length <= 10) {
      currentInspectionList = _inspectionList;
    } else {
      endAt = startAt + pageCount;
      totalPages = (_inspectionList.length / pageCount).floor();
      if (_inspectionList.length / pageCount > totalPages) {
        totalPages = totalPages + 1;
      }

      currentInspectionList = _inspectionList.getRange(startAt, endAt).toList();
    }
  }

  late bool _isLoading = true;

  @override
  void initState() {
    getAllInspectionDetails();
    super.initState();
  }

  void loadPreviousPage() {
    if (page > 1) {
      setState(() {
        startAt = startAt - pageCount;
        endAt = page == totalPages
            ? endAt - currentInspectionList.length
            : endAt - pageCount;
        currentInspectionList =
            _inspectionList.getRange(startAt, endAt).toList();
        page = page - 1;
      });
    }
  }

  void loadNextPage() {
    if (page < totalPages) {
      setState(() {
        startAt = startAt + pageCount;
        endAt = _inspectionList.length > endAt + pageCount
            ? endAt + pageCount
            : _inspectionList.length;
        currentInspectionList =
            _inspectionList.getRange(startAt, endAt).toList();
        page = page + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
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
        actions: [
          IconButton(
            onPressed: () {
              if (customIcon.icon == Icons.search) {
                setState(() {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = const ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    title: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                });
              } else {
                setState(() {
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Follow-up Inspection');
                });
              }
            },
            icon: customIcon,
          )
        ],
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
                  Text('Follow-up Inspection Visit',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text("School Inspection's Management",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Hero(
                    tag: "new_inspection_btn",
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FollowUpForm()))
                            .then((data) {
                          if (data != null) {
                            getAllInspectionDetails();
                            _showSuccessSnackBar(
                                'Inspection Added Successfully');
                          }
                        });
                      },
                      icon: Icon(
                        // <-- Icon
                        Icons.add,
                        size: 24.0,
                      ),
                      label: Text('New Follow-up Visit'), // <-- Text
                    ),
                  ),
                ),
              ],
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(color: Colors.grey)),
            _isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.white,
                    child: ListView.builder(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              //padding: new EdgeInsets.all(4.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(width: 15),
                                  Container(
                                    height: 45,
                                    width: 45,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 5),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(2)),
                                              color: Colors.grey,
                                            ),
                                            height: 18,
                                            child: Row(),
                                          ),
                                          SizedBox(height: 7),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(2)),
                                                  color: Colors.grey,
                                                ),
                                                height: 18,
                                                child: Row(),
                                              )),
                                              Expanded(
                                                  child: Container(
                                                height: 18,
                                              )),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        }),
                  )
                : ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: currentInspectionList.length,
                    itemBuilder: (context, index) {
                      var user = context.read<AccountProvider>().user;
                      var date = DateTime.parse(
                          currentInspectionList[index].presentVisitationDate);
                      var expiry =
                          DateTime(date.year, date.month, date.day + 15);
                      DateFormat formatter = DateFormat('dd/MM/yyyy');
                      final String formatted = formatter.format(date);
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FollowupReport(
                                          inspection:
                                              currentInspectionList[index],
                                        )));
                          },
                          leading: const Icon(Icons.list_alt_rounded),
                          title: Text(
                              "${currentInspectionList[index].schoolName} Followup Visit" ??
                                  ''),
                          subtitle: Text(formatted.split(' ')[0] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ((user!['user_id'] ==
                                              currentInspectionList[index]
                                                  .leadInspectorName ||
                                          user!['user_id'] ==
                                              currentInspectionList[index]
                                                  .firstInspectorName ||
                                          user!['user_id'] ==
                                              currentInspectionList[index]
                                                  .secondInspectorName ||
                                          user!['user_id'] ==
                                              currentInspectionList[index]
                                                  .thirdInspectorName ||
                                          user!['user_id'] ==
                                              currentInspectionList[index]
                                                  .fourthInspectorName) &&
                                      expiry > DateTime.now())
                                  ? Row(children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditFollowUp(
                                                          inspection:
                                                              currentInspectionList[
                                                                  index],
                                                        ))).then((data) {
                                              if (data != null) {
                                                getAllInspectionDetails();
                                                _showSuccessSnackBar(
                                                    'Inspection Updated Successfully');
                                              }
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.teal,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            _deleteFormDialog(
                                                context,
                                                currentInspectionList[index]
                                                    .id);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )),
                                    ])
                                  : Text(''),
                              if (currentInspectionList[index].sync == '1' ||
                                  currentInspectionList[index].sync == '3')
                                Tooltip(
                                  triggerMode: TooltipTriggerMode.tap,
                                  showDuration: const Duration(seconds: 2),
                                  message: 'This inspection is offline',
                                  child: Image.asset(
                                    "assets/images/offline.jpg",
                                    width: 43,
                                  ),
                                ),
                              if (currentInspectionList[index].sync != '1' &&
                                  currentInspectionList[index].sync != '3')
                                Container(),
                            ],
                          ),
                        ),
                      );
                    }),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: page > 1 ? loadPreviousPage : null,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 35,
                  ),
                ),
                Text("$page / $totalPages"),
                IconButton(
                  onPressed: page < totalPages ? loadNextPage : null,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 35,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
