import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/actionPlan.dart';
import '../../models/inspUpdate.dart';
import '../../models/recommendation.dart';
import '../../services/ActionPlanService.dart';
import '../../services/InspectionService.dart';
import '../../services/RecommendationService.dart';
import '../../utils/account_provider.dart';
import 'ActionPlanForm.dart';
import 'Edit_ActionPlan.dart';

class Recommendations extends StatefulWidget {
  final Inspection inspection;

  const Recommendations({Key? key, required this.inspection}) : super(key: key);

  get recommendation => null;

  @override
  _Recommendations createState() => _Recommendations();
}

class _Recommendations extends State<Recommendations> {
  String? selectedStartDate;
  String? selectedDueDate;
  String? selectedActivityStatus;
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
  var startDateEndDate;
  late List<Recommendation> _recommendationList = <Recommendation>[];
  late List<ActionPlanModel> _actionPlanList = <ActionPlanModel>[];

  getAllRecommendationDetails() async {
    var recommendations = await _recomService
        .readAllRecommendationsByVisitId(widget.inspection.id.toString());
    _recommendationList = <Recommendation>[];
    recommendations.forEach((recommendation) async {
      var dates = await getStartDateAndEndDate(recommendation['recommendation_id'].toString());
      setState(() {
        var recommendationModel = Recommendation();
        recommendationModel.id = recommendation['recommendation_id'];
        recommendationModel.createdAt = recommendation['created_at'];
        recommendationModel.description =
            recommendation['recommendation_description'];
        recommendationModel.startDate = dates[0]['start_date'];
        recommendationModel.endDate = dates[0]['end_date'];
        recommendationModel.nesCategory = recommendation['category_id'];
        recommendationModel.visitId = recommendation['visit_id'];
        _recommendationList.add(recommendationModel);

      });

    });
  }

  getStartDateAndEndDate(String recomId) async {
    var recommendations = await _recomService.readStartAndEndDate(recomId);
    return recommendations;
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


  late bool _viewTile = true;
  late bool _viewButton = true;
  late bool viewIconButton = true;
  var _formKeySchoolVisit = GlobalKey<FormState>();
  var _inspectionService = InspectionService();
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
    getAllActions();
    getAllRecommendationDetails();
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
                        getAllActions();
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
                    Navigator.of(context, rootNavigator: true).pop();;
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
                        getAllActions();
                        getAllRecommendationDetails();
                      });
                      Navigator.of(context, rootNavigator: true).pop();
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
        title: Text('Recommendations'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
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
                  Text('Recommendations',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text("Recommendations Management",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            _viewTile
                ? Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: Hero(
                          tag: "new_inspection_btn",
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                            ),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.0))),
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
                                          child: Form(
                                            key: _formKeySchoolVisit,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text('Add New Recommendation',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    )),
                                                SizedBox(
                                                  height: 25.0,
                                                ),
                                                TextFormField(
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return ("Description is required");
                                                    }
                                                  },
                                                  controller: _description,
                                                  maxLines: 6,
                                                  decoration: InputDecoration(
                                                    labelText: "Description",
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 25.0,
                                                ),
                                                DropdownButtonFormField(
                                                    decoration: InputDecoration(
                                                      labelText: 'NES Category',
                                                      border:
                                                          OutlineInputBorder(),
                                                      filled: true,
                                                    ),
                                                    validator: (value) =>
                                                        value == null
                                                            ? "Select a NES"
                                                            : null,
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        selectedNESValue =
                                                            newValue;
                                                      });
                                                    },
                                                    items: nes),
                                                SizedBox(
                                                  height: 25.0,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                          primary: Colors.white,
                                                          backgroundColor:
                                                              Colors.deepPurple,
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      15)),
                                                      onPressed: () async {
                                                        if (_formKeySchoolVisit
                                                            .currentState!
                                                            .validate()) {
                                                          var _recommendation =
                                                              Recommendation();
                                                          var inspection = InspectionUp();
                                                          _recommendation
                                                                  .description =
                                                              _description.text;

                                                          _recommendation
                                                                  .nesCategory =
                                                              selectedNESValue;
                                                          _recommendation
                                                                  .visitId =
                                                              widget
                                                                  .inspection.id
                                                                  .toString();
                                                          _recommendation
                                                                  .recommendationType =
                                                              "Major";
                                                          _recommendation
                                                                  .createdAt =
                                                              currentDate;
                                                          var result =
                                                              await _recomService
                                                                  .SaveRecommendation(
                                                                      _recommendation);
                                                          setState(() {
                                                            getAllRecommendationDetails();
                                                            _description.text =
                                                                '';
                                                          });
                                                          _showSuccessSnackBar(
                                                              'Recommendation added Successfully');
                                                          Navigator.pop(
                                                              context, result);
                                                        }
                                                      },
                                                      child: Text('SUBMIT'),
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                          primary: Colors.white,
                                                          backgroundColor:
                                                              Colors.red,
                                                          textStyle:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      15)),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text('Cancel'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(
                              // <-- Icon
                              Icons.add,
                              size: 24.0,
                            ),
                            label: Text('New Recommendation'), // <-- Text
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(color: Colors.grey)),
            ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: _recommendationList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 0),
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Row(children: [
                                Text(
                                  "Start Date: ${_recommendationList[index].startDate!=null?_recommendationList[index].startDate.split(' ')[0]??'N/A':'N/A'}",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(' '),
                                SizedBox(width: 20),
                                Text(
                                  "Finish Date: ${_recommendationList[index].endDate!=null?_recommendationList[index].endDate.split(' ')[0]??'N/A':'N/A'}",
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
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20.0))),
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
                                                          'Edit Major Recommendation',
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
                                                      DropdownButtonFormField(
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'NES Category',
                                                            border:
                                                                OutlineInputBorder(),
                                                            filled: true,
                                                          ),
                                                          value: _recommendationList[index].nesCategory.toString(),
                                                          validator: (value) =>
                                                              value == null
                                                                  ? "Select a NES"
                                                                  : null,
                                                          onChanged: (String?
                                                              newValue) {
                                                            setState(() {
                                                              selectedNESValue =
                                                                  newValue;
                                                            });
                                                          },
                                                          items: nes),
                                                      SizedBox(
                                                        height: 25.0,
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                                primary: Colors
                                                                    .white,
                                                                backgroundColor:
                                                                    Colors.teal,
                                                                textStyle:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            15)),
                                                            onPressed:
                                                                () async {
                                                              var _recommendation =
                                                                  Recommendation();
                                                              _recommendation
                                                                      .id =
                                                                  _recommendationList[
                                                                          index]
                                                                      .id;
                                                              _recommendation
                                                                      .description =
                                                                  _description
                                                                      .text;
                                                              _recommendation
                                                                      .visitId =
                                                                  widget
                                                                      .inspection
                                                                      .id
                                                                      .toString();
                                                              _recommendation
                                                                      .createdAt =
                                                                  _recommendationList[
                                                                          index]
                                                                      .createdAt;
                                                              _recommendation
                                                                  .recommendationType =
                                                              "Major";
                                                              _recommendation.nesCategory = selectedNESValue;
                                                              var result =
                                                                  await _recomService
                                                                      .UpdateRecommendation(
                                                                          _recommendation);
                                                              setState(() {
                                                                _description
                                                                    .text = '';
                                                                getAllRecommendationDetails();
                                                              });
                                                              Navigator.pop(context, result);
                                                              _showSuccessSnackBar(
                                                                  'Recommendation updated Successfully');
                                                              //Navigator.pop(context, result);
                                                            },
                                                            child:
                                                                Text('UPDATE'),
                                                          ),
                                                          const SizedBox(
                                                            width: 10.0,
                                                          ),
                                                          TextButton(
                                                            style: TextButton.styleFrom(
                                                                primary: Colors
                                                                    .white,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textStyle:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            15)),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child:
                                                                Text('Cancel'),
                                                          ),
                                                        ],
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
                                                  inspection: widget.inspection,
                                                  recommendation:
                                                      _recommendationList[
                                                          index],
                                                ))).then(
                                      (data) {
                                        if (data != null) {
                                          getAllActions();
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
                              headingRowColor: MaterialStateColor.resolveWith(
                                  (states) => Color(0xFFF3EDE8)),
                              border: const TableBorder(
                                top: BorderSide(color: Colors.grey, width: 0.5),
                                bottom: BorderSide(
                                    color: Color(0xD8E38282), width: 1.5),
                                left:
                                    BorderSide(color: Colors.grey, width: 0.5),
                                right:
                                    BorderSide(color: Colors.grey, width: 0.5),
                                horizontalInside:
                                    BorderSide(color: Colors.grey, width: 0.5),
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
                                          _deleteAPFormDialog(context, item.id,
                                              item.activityName)
                                        },
                                    cells: [
                                      DataCell(
                                    Container(
                                    width: 170,

                                    child: Text(item.activityName))),
                                      DataCell(Text(item.activityStartDate
                                          .split(' ')[0])),
                                      DataCell(Text(item.activityFinishDate
                                          .split(' ')[0])),
                                      DataCell(
                                          Text('MWK ${item.activityBudget}')),
                                      DataCell(Text(progress)),
                                      DataCell(Text(item.statusRemarks??'')),
                                      DataCell(_viewButton
                                          ?IconButton(
                                                  onPressed: () async {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditActionPlanForm(
                                                                  inspection: widget
                                                                      .inspection,
                                                                  recommendation:
                                                                      _recommendationList[
                                                                          index],
                                                                  actionPlan: item,
                                                                ))).then(
                                                      (data) {
                                                        if (data != null) {
                                                          getAllActions();
                                                          _showSuccessSnackBar(
                                                              'Activity Updated Successfully');
                                                        }
                                                      },
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
                                                _deleteAPFormDialog(context,
                                                    item.id, item.activityName);
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
