import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:siis_offline/screens/Inspector/edit_inspection.dart';
import 'package:siis_offline/screens/Inspector/view_inspection.dart';
import 'package:siis_offline/screens/Inspector/control_panel.dart';

import '../../components/AppDrawer.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/user.dart';
import '../../services/InspectionService.dart';
import '../../utils/account_provider.dart';
import 'inspection_form.dart';

class Search extends StatefulWidget {
  final List<Inspection> inspection;
  const Search({Key? key, required this.inspection}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Full Inspection');
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
                      Navigator.of(context, rootNavigator: true).pop();
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

  List<Inspection> inspectionSearched = [];
  Finder(String qry) {
    qry = qry.toLowerCase();
    print(qry);
    setState(() {
      inspectionSearched = _inspectionList
          .where((element) =>
              element.schoolName.toLowerCase().contains(qry) ||
              element.headTeacher.toLowerCase().contains(qry) ||
              element.leadInspectorName.toLowerCase().contains(qry) ||
              element.advisor.toLowerCase().contains(qry) ||
              element.divisionName.toLowerCase().contains(qry) ||
              element.districtName.toLowerCase().contains(qry) ||
              element.clusterName.toLowerCase().contains(qry) ||
              element.presentVisitationDate.toLowerCase().contains(qry))
          .toList();
    });
  }

  var _searchController = TextEditingController();
  getAllInspectionDetails() async {
    var user = context.read<AccountProvider>().user;
    var inspections = await _inspectionService
        .readAllInspections(user!['sector_id'].toString());
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
        _isLoading = false;
      });
    });

    if (_inspectionList.length <= 10) {
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
        actions: [
          IconButton(
            onPressed: () {
              if (customIcon.icon == Icons.search) {
                setState(() {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    title: TextField(
                      controller: _searchController,
                      onEditingComplete: () {
                        Finder(_searchController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Search(inspection: inspectionSearched);
                            },
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
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
                  customSearchBar = const Text('Full Inspection');
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
                    itemCount: widget.inspection.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewInspection(
                                          inspection: widget.inspection[index],
                                        )));
                          },
                          leading: const Icon(Icons.list_alt_rounded),
                          title: Text(
                              "${widget.inspection[index].schoolName} Inspection Visit" ??
                                  ''),
                          subtitle: Text(
                              widget.inspection[index].presentVisitationDate ??
                                  ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditInspection(
                                                  inspection:
                                                      widget.inspection[index],
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
                                        context, widget.inspection[index].id);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ))
                            ],
                          ),
                        ),
                      );
                    }),

            /*ExpansionTile(
                            title: Text('School Name'),
                            subtitle: Text('Date: 16/09/22'),
                            children: <Widget>[
                              ListTile(title: Text('Head Teacher:')),
                              ListTile(title: Text('Lead Inspector:')),
                              ListTile(title: Text('Advisor:')),
                              ListTile(title: Text('Cluster')),
                              ListTile(title: Text('District:')),
                              ListTile(title: Text('Division:')),
                              Row(
                                children: <Widget>[

                                  Expanded(child:  Container(
                                    padding:const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                    child: Hero(
                                      tag: "edit",
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return InspectionForm();
                                              },
                                            ),
                                          );
                                        },
                                        icon: Icon( // <-- Icon
                                          Icons.edit,
                                          size: 24.0,
                                        ),
                                        label: Text('Edit'), // <-- Text
                                      ),
                                    ),
                                  ),),
                                  Expanded(child:  Container(
                                    padding:const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                    child: Hero(
                                      tag: "delete",
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,),
                                        onPressed: () {

                                        },
                                        icon: Icon( // <-- Icon
                                          Icons.delete_forever,
                                          size: 24.0,
                                        ),
                                        label: Text('Delete'), // <-- Text
                                      ),
                                    ),
                                  ),),
                                  Expanded(
                                    child: Container(
                                      padding:const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                      child: Hero(
                                        tag: "MORE OPTIONS",
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(

                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                            // <-- Text
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return ControlPanel();
                                                },
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "MORE OPTIONS".toUpperCase(),
                                          ),
                                        ),
                                      ),
                                    ),),

                                ],
                              ),
                            ],
                          ),*/
          ],
        ),
      ),
    );
  }
}
