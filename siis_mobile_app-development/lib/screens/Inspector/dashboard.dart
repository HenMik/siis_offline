import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/constants.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:siis_offline/models/zone.dart';
import 'package:siis_offline/utils/account_provider.dart';
import 'package:siis_offline/utils/app_sync.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/Inspection.dart';
import '../../models/bar_chart_model.dart';
import '../../models/school.dart';
import '../../services/InspectionService.dart';

class Dashboard extends StatefulWidget {
  final AppBar appBar;
  Dashboard({key, required this.appBar}) : super(key: key);

  @override
  _DashState createState() => _DashState();
}

class _DashState extends State<Dashboard> {
  late List<ExpenseData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  late Iterable<School>? schools = [];
  late Iterable<School>? schoolsByZone = [];
  late Iterable<Zone>? clusters = [];
  late List<Inspection> _inspectionList = <Inspection>[];
  final _inspectionService = InspectionService();
  late bool _viewTile = true;
  late TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  @override
  void initState() {
    var user = context.read<AccountProvider>().user;
    if(user!['user_role']=='Secondary Advisor'){
      _viewTile = false;
    }
    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _tooltip = TooltipBehavior(enable: true);
    getAllSchoolDetails(user!['sector_id'].toString());
    getAllClusterDetails(user!['sector_id'].toString());
    getAllSchoolDetailsByZone(user!['sector_id'].toString(), user!['zone_id'].toString());
    getAllInspectionDetails();
    super.initState();
  }
  getAllSchoolDetails(String? sector_id) async {
    Iterable<School>? s = await SchoolProvider().getBySector(sector_id);
    setState(() {
      schools = s;
    });
  }
  getAllSchoolDetailsByZone(String? sector_id, String? zone) async {
    Iterable<School>? s = await SchoolProvider().getBySectorAndZone(sector_id, zone);
    setState(() {
      schoolsByZone = s;
    });
  }
  getAllClusterDetails(String? sector_id) async {
    Iterable<Zone>? z = await ZoneProvider().getBySector(sector_id);
    setState(() {
      clusters = z;
    });
  }
  getAllInspectionDetails() async {
    var user = context.read<AccountProvider>().user;
    var inspections = await _inspectionService.readInspections(user!['sector_id'].toString());
    _inspectionList = <Inspection>[];
    inspections.forEach((inspection) {
      setState(() {
        var inspectionModel = Inspection();
        inspectionModel.id = inspection['total_inspection'];
        inspectionModel.districtName = inspection['district_name'];
        inspectionModel.divisionName = inspection['division_name'];
        inspectionModel.clusterName = inspection['zone_name'];
        inspectionModel.actionPlanDate = inspection['action_plan_date'];
        inspectionModel.visitType = inspection['visit_type_id'];
        inspectionModel.nextInspectionDate = inspection['next_inspection_date'];
        inspectionModel.schoolName = inspection['emis_id'];
        inspectionModel.postAddress = inspection['school_address'];
        inspectionModel.headTeacher = inspection['head_teacher'];
        inspectionModel.headPhonenumber = inspection['phone_number'];
        inspectionModel.nofqTeachers = inspection['number_of_teachers'];
        inspectionModel.noufqTeachers = inspection['unqualified_teachers'];
        inspectionModel.totalEnrolledBoys = inspection['enrolment_boys'];
        inspectionModel.totalAttendanceBoys = inspection['attendance_boys'];
        inspectionModel.totalEnrolledGirls = inspection['enrolment_girls'];
        inspectionModel.totalAttendanceGirls = inspection['attendance_girls'];
        inspectionModel.advisor = inspection['year'];
        inspectionModel.schoolGovernanceChair = inspection['govt_chair_id'];
        inspectionModel.presentVisitationDate = inspection['present_visitation_date'];
        inspectionModel.yearOfEstablishment = inspection['establishment_year'];
        inspectionModel.leadInspectorName = inspection['lead_inspector_id'];
        _inspectionList.add(inspectionModel);
      });

    });
    print('Number of Inspections: ${_inspectionList.length}');
  }

  get animate => animate;

  List<charts.Series<dynamic, String>> get seriesList => seriesList;

  @override
  Widget build(BuildContext context) {
    AccountProvider provider = context.read<AccountProvider>();
    return Scaffold(
      appBar: widget.appBar,
      body: Center(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Text('Inspection Level',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kBlackColor)),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: <Widget>[
                  Text('Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  Icon(Icons.arrow_right),
                  Text('Visualization',
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(color: Colors.grey)),
            Container(
              padding: EdgeInsets.all(14),
              child: Text('Quick Statistic',
                  style: TextStyle(
                    fontSize: 14,
                  )),
            ),
            _viewTile?Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 6, 3, 0),
                    height: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        /*side: BorderSide(
                          color: Colors.teal,
                        ),*/
                      ),
                      elevation: 4,
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.school,
                                          size: 50,
                                          color: Colors.teal,
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Secondary Schools',
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              )),

                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: 66,
                              color: kGreyLightColor,
                              child: Center(child: Text('${schools?.length.toString()}', style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold

                              ),))),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 6, 3, 0),
                    height: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        /*side: BorderSide(
                          color: Colors.teal,
                        ),*/
                      ),
                      elevation: 4,
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.apartment_outlined,
                                          size: 50,
                                          color: Colors.teal,
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Clusters',
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              )),

                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: 66,
                              color: kGreyLightColor,
                              child: Center(child: Text('${clusters?.length.toString()}', style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold

                              ),))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ):Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(6, 6, 3, 0),
                    height: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        /*side: BorderSide(
                          color: Colors.teal,
                        ),*/
                      ),
                      elevation: 4,
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.school,
                                          size: 50,
                                          color: Colors.teal,
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Secondary Schools',
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              )),

                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: 66,
                              color: kGreyLightColor,
                              child: Center(child: Text('${schoolsByZone?.length.toString()}', style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold

                              ),))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Divider(color: Colors.grey)),
            Container(
                child: SfCartesianChart(
                    title: ChartTitle(
                        text: 'INSPECTION PERCENTAGE FOR SCHOOLS OVER THE PAST 10 YEARS',
                        textStyle:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    isTransposed: true,
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(minimum: 0, maximum: 100, interval: 20,labelFormat: '{value}%',),
                    tooltipBehavior: _tooltip,

                    series: <ChartSeries<_ChartData, String>>[

                      BarSeries<_ChartData, String>(
                          dataSource: _inspectionList.map((item) {
                            var percentage = (int.parse(item.id.toString())/ int.parse("${schools?.length.toString()}")) * 100;
                            return _ChartData(percentage,item.advisor.toString());
                          }).toList(),
                          xValueMapper: (_ChartData data, _) => data.y,
                          yValueMapper: (_ChartData data, _) => data.x,
                          name: 'School inspections',
                          color: Color.fromRGBO(255, 156, 46, 1),
                          markerSettings: MarkerSettings(
                            isVisible: true,
                          )),

                    ])),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Divider(color: Colors.grey)),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: SfCartesianChart(
                isTransposed: true,
                title: ChartTitle(
                    text: 'NATIONAL PROGRESS REPORT FOR THE PAST 10 YEARS',
                    textStyle:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                legend: Legend(isVisible: true),
                tooltipBehavior: _tooltipBehavior,
                series: <ChartSeries>[
                  StackedBarSeries<ExpenseData, String>(
                      dataSource: _chartData,
                      xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                      yValueMapper: (ExpenseData exp, _) => exp.level1,
                      name: 'Level 1',
                      color: Colors.redAccent,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                      )),
                  StackedBarSeries<ExpenseData, String>(
                      dataSource: _chartData,
                      xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                      yValueMapper: (ExpenseData exp, _) => exp.level2,
                      name: 'Level 2',
                      color: Colors.blue,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                      )),
                  StackedBarSeries<ExpenseData, String>(
                      dataSource: _chartData,
                      xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                      yValueMapper: (ExpenseData exp, _) => exp.level3,
                      name: 'Level 3',
                      color: Colors.amberAccent,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                      )),
                  StackedBarSeries<ExpenseData, String>(
                      dataSource: _chartData,
                      xValueMapper: (ExpenseData exp, _) => exp.expenseCategory,
                      yValueMapper: (ExpenseData exp, _) => exp.level4,
                      name: 'Level 4',
                      color: Colors.teal,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                      )),
                ],
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(minimum: 0, maximum: 100, interval: 20,labelFormat: '{value}%',),
              ),
            ),
          ],
        ),
      ),

    );

  }

}

List<ExpenseData> getChartData() {
  final List<ExpenseData> chartData = [
    ExpenseData('2021', 0, 50, 50, 0),
    ExpenseData('2022', 37, 57, 6, 0),
    ExpenseData('2023', 49, 50, 0, 0),
  ];
  return chartData;
}

class ExpenseData {
  ExpenseData(
      this.expenseCategory, this.level1, this.level2, this.level3, this.level4);
  final String expenseCategory;
  final num level1;
  final num level2;
  final num level3;
  final num level4;
}
class _ChartData {
  _ChartData(this.x, this.y);

  final String y;
  final double x;
}
