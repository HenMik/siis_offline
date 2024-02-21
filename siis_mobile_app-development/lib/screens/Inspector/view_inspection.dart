import 'dart:convert';

import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/constants.dart';
import 'package:siis_offline/screens/Inspector/school_visits.dart';
import 'package:siis_offline/utils/account_provider.dart';

import '../../components/AppDrawer.dart';
import '../../models/Inspection.dart';
import '../../services/InspectionService.dart';
import 'edit_inspection.dart';
import 'control_panel.dart';

class ViewInspection extends StatefulWidget {
  final Inspection inspection;

  const ViewInspection({Key? key, required this.inspection}) : super(key: key);

  @override
  State<ViewInspection> createState() => _ViewInspectionState();
}

class _ViewInspectionState extends State<ViewInspection> {
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

  _deleteFormDialog(BuildContext context, inspectionId) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: const Text(
              'Are You Sure to Delete this Inpection?',
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
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (body) => AppDrawer(
                              child: SchoolVisits(),
                            ),
                          ),
                        );
                      });
                      setState(() {
                        getAllInspectionDetails();
                      });
                      _showSuccessSnackBar('Inspection Deleted Successfully');
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
        .readAllInspections(user!['sector_id'].toString());
    _inspectionList = <Inspection>[];
    inspections.forEach((inspection) {
      setState(() {
        var inspectionModel = Inspection();
        inspectionModel.id = inspection['visit_id'];
        inspectionModel.leadInspectorName = inspection['lead_inspector_id'];
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
        inspectionModel.presentVisitationDate =
            inspection['present_visitation_date'];
        _inspectionList.add(inspectionModel);
      });
    });
  }

  late bool _viewAddInspectionButton = true;
  @override
  void initState() {
    var user = context.read<AccountProvider>().user;
    if (user!['user_role'] == 'Secondary Advisor') {
      _viewAddInspectionButton = false;
    }
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
            var user = context.read<AccountProvider>().user;
            var date = DateTime.parse(widget.inspection.presentVisitationDate);
            var expiry = DateTime(date.year, date.month, date.day + 14);
            DateFormat formatter = DateFormat('dd/MM/yyyy');
            final String formatted = formatter.format(date);
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Complete Details",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        fontSize: 20),
                  ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Divider(color: Colors.grey)),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text('School Name:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Text(
                              widget.inspection.schoolName.toString() ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Postal Address:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.postAddress ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Head Teacher:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.headTeacher ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text("Head Teacher's Phone:",
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.headPhonenumber ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Number of Qualified Teachers:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.nofqTeachers ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Number of Un-Qualified:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.noufqTeachers ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Total Enrolled Boys:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(widget.inspection.totalEnrolledBoys ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Total Attendance Boys:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                              widget.inspection.totalAttendanceBoys ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Total Enrolled Girls:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                              widget.inspection.totalEnrolledGirls ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Total Attendance Girls:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                              widget.inspection.totalAttendanceGirls ?? '',
                              style: TextStyle(fontSize: 16)),
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
                        child: Text('Inspection Visitation Date:',
                            style: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(formatted ?? '',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Divider(color: Colors.grey)),
                  _viewAddInspectionButton
                      ? Row(
                          children: <Widget>[
                            ((user!['user_id'] ==
                                            widget
                                                .inspection.leadInspectorName ||
                                        user!['user_id'] ==
                                            widget.inspection
                                                .firstInspectorName ||
                                        user!['user_id'] ==
                                            widget.inspection
                                                .secondInspectorName ||
                                        user!['user_id'] ==
                                            widget.inspection
                                                .thirdInspectorName ||
                                        user!['user_id'] ==
                                            widget.inspection
                                                .fourthInspectorName) &&
                                    expiry > DateTime.now())
                                ? Expanded(
                                    child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 12, 12, 0),
                                          child: Hero(
                                            tag: "edit",
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditInspection(
                                                              inspection: widget
                                                                  .inspection,
                                                            ))).then((data) {
                                                  if (data != null) {
                                                    setState(() {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (body) =>
                                                              AppDrawer(
                                                            child:
                                                                SchoolVisits(),
                                                          ),
                                                        ),
                                                      );
                                                    });

                                                    _showSuccessSnackBar(
                                                        'Inspection Updated Successfully');
                                                  }
                                                });
                                              },
                                              icon: Icon(
                                                // <-- Icon
                                                Icons.edit,
                                                size: 24.0,
                                              ),
                                              label: Text('Edit'), // <-- Text
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 12, 12, 0),
                                          child: Hero(
                                            tag: "delete",
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () {
                                                _deleteFormDialog(context,
                                                    widget.inspection.id);
                                              },
                                              icon: Icon(
                                                // <-- Icon
                                                Icons.delete_forever,
                                                size: 24.0,
                                              ),
                                              label: Text('Delete'), // <-- Text
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                                : Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(),
                                        ),
                                        Expanded(
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                child: Hero(
                                  tag: "MORE OPTIONS",
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      // <-- Text
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ControlPanel(
                                              inspection: widget.inspection,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "MORE OPTIONS".toUpperCase(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                child: Hero(
                                  tag: "MORE OPTIONS",
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      // <-- Text
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ControlPanel(
                                              inspection: widget.inspection,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "MORE OPTIONS".toUpperCase(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            );
          }),
    );
  }
}
