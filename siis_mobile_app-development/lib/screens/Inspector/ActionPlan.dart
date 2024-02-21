import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/recommendation.dart';
import '../../services/RecommendationService.dart';
import 'ActionPlanForm.dart';
import '../../services/ActionPlanService.dart';
import '../../models/actionPlan.dart';

class ActionPlan extends StatefulWidget {
  final Recommendation recommendation;
  final Inspection inspection;

  const ActionPlan(
      {Key? key, required this.inspection, required this.recommendation})
      : super(key: key);

  @override
  _ActionPlan createState() => _ActionPlan();
}

class _ActionPlan extends State<ActionPlan> {
  String? selectedNESValue;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var school_id;
  bool _customTileExpanded = false;
  var _description = TextEditingController();
  var _recomService = RecommendationService();
  late List<Recommendation> _recommendationList = <Recommendation>[];

  late final Recommendation recommendation;
  late List<ActionPlanModel> _actionPlanList = <ActionPlanModel>[];
  final _ActionPlanService = ActionPlanService();
  final _actionPlanService = ActionPlanService();
  String? schools;
  int page = 1;
  int pageCount = 10;
  int startAt = 0;
  late int endAt;
  int totalPages = 0;
  getAllActions() async {
    var actionsplans = await _actionPlanService
        .readAllActionPlans(widget.recommendation.id.toString());
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
        _actionPlanList.add(actionPlanModel);
      });
    });
  }

  @override
  void initState() {
    getAllActions();
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
          title: Text('Action Plan'),
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
                    Text('Action Plan',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(14),
                child: Text("Action Plan Management",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  builder: (context) => ActionPlanForm(
                                        inspection: widget.inspection,
                                        recommendation: widget.recommendation,
                                      ))).then(
                            (data) {
                              if (data != null) {
                                getAllActions();
                                _showSuccessSnackBar(
                                    'Inspection Added Successfully');
                              }
                            },
                          );
                        },
                        icon: Icon(
                          // <-- Icon
                          Icons.add,
                          size: 24.0,
                        ),
                        label: Text('New Activity'), // <-- Text
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Divider(color: Colors.grey)
              ),
              ExpansionTile(
                title: const Text('Recomendation 1'),
                subtitle: const Text('NES Category'),
                trailing: Icon(
                  _customTileExpanded
                      ? Icons.arrow_drop_down_circle
                      : Icons.arrow_drop_down,
                ),
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Text('Activity', style: TextStyle(fontSize: 14))),
                        DataColumn(
                            label: Text('Start Date', style: TextStyle(fontSize: 14))),
                        DataColumn(
                            label: Text('End Date', style: TextStyle(fontSize: 14))),
                        DataColumn(
                            label: Text('Activity Status', style: TextStyle(fontSize: 14))),
                        DataColumn(
                            label: Text('Budget',
                                style: TextStyle(
                                  fontSize: 14,
                                ))),
                        DataColumn(
                            label: Text('Priority Level', style: TextStyle(fontSize: 14))),
                        DataColumn(
                            label: Text('Status Remarks', style: TextStyle(fontSize: 14))),
                      ],
                      rows: <DataRow>[
                        DataRow(cells: [
                          DataCell(Text("1")),
                          DataCell(Text("1")),
                          DataCell(Text("1")),
                          DataCell(Text("1")),
                          DataCell(Text("1")),
                          DataCell(Text("1")),
                          DataCell(Text("1")),
                        ])
                      ],


                    ),

                  ),
                ],
                onExpansionChanged: (bool expanded) {
                  setState(() => _customTileExpanded = expanded);
                },
              ),


    ]),
    ),
    );
  }
}
