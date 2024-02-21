import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/models/key_evidence.dart';
import 'package:siis_offline/screens/Inspector/edit_key_evidence.dart';
import 'package:siis_offline/services/keyEvidenceService.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/nes_bar_chart_model.dart';
import '../../services/RecommendationService.dart';
import '../../utils/account_provider.dart';
import 'key_evidence_form.dart';
import "package:collection/collection.dart";

class KeyEvidence extends StatefulWidget {
  final Inspection inspection;
  const KeyEvidence({Key? key, required this.inspection} ) : super(key: key);

  @override
  _KeyEvidence createState() => _KeyEvidence();

}

class _KeyEvidence extends State<KeyEvidence> {
  late List<KeyEvidenceModel> _keyEvidenceList = <KeyEvidenceModel>[];
  late List<KeyEvidenceModel> _achievedList = <KeyEvidenceModel>[];
  late List<KeyEvidenceModel> _nesAchievedList = <KeyEvidenceModel>[];
  late TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  final _keyEvidenceService = KeyEvidenceService();
  final _recommendationService = RecommendationService();
  var levelsAchieved = {};
  var newAchieved = [];
  var evidenceDesc = {};
  _deleteFormDialog(BuildContext context, nesId, visitId) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: const Text(
              'Are You Sure to Delete this Key Evidence?',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red),
                  onPressed: () async {
          setState(() {
            var result = _keyEvidenceService.deleteKeyEvidence(nesId, visitId);
                    var result2 = _recommendationService.deleteRecommendationWithKeyEvidence(nesId, visitId);
                    if (result != null && result2 != null) {
                        setState(() {
                          getNesLevelAchieved();
                          getNesLevelsAchieved();
                          getAllKeyEvidenceDetails();
                          getAllRequirementsAchieved();
                        });

                        Navigator.of(context, rootNavigator: true).pop();
                        _showSuccessSnackBar('Key Evidence Deleted Successfully');};
                  });

                  },
                  child: const Text('Delete')),
              TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.teal),
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
 getNesLevelAchieved() async{
    var levelsAchived = await _keyEvidenceService.readAllRequirementsAchieved(widget.inspection.id.toString());
    var newMap = [];
    levelsAchived.forEach((level) {
      var l = {...level, 'percentage': (int.parse(level['achieved'].toString())/int.parse(level['out_of'])) * 100};
      newMap.add(l);
    });
    var newMapp = newMap.groupListsBy((obj) => obj['nes_id']);
    
    newMapp.forEach((key, value) {
      var newMaap = newMapp[key];
      var contain = newMaap!.where((e) => e["nes_level_id"] == '2' && e["percentage"] == 100);
      var contain2 = newMaap!.where((e) => e["nes_level_id"] == '3' && e["percentage"] == 100);
      var contain3 = newMaap!.where((e) => e["nes_level_id"] == '4' && e["percentage"] == 100);

      newMaap!.forEach((element) {
        if(contain.isEmpty){
          levelsAchieved[element['nes_id']] = '1';
        }
        else{
          if(element['nes_level_id'] == '2' && element['percentage'] < 100){

            levelsAchieved[element['nes_id']] = '1';

          }
          if(element['nes_level_id'] == '2' && element['percentage'] == 100){
            levelsAchieved[element['nes_id']] = '2';
          }
          else{
            if(contain2.isEmpty){
              levelsAchieved[element['nes_id']] = '2';
            }
            else{
              if(element['nes_level_id'] == '3' && element['percentage'] < 100){

                levelsAchieved[element['nes_id']] = '2';

              }
              if(element['nes_level_id'] == '3' && element['percentage'] == 100){
                levelsAchieved[element['nes_id']] = '3';
              }
              else{
                if(contain3.isEmpty){
                  levelsAchieved[element['nes_id']] = '3';
                }
                else{
                  if(element['nes_level_id'] == '4' && element['percentage'] < 100){

                    levelsAchieved[element['nes_id']] = '3';

                  }
                  if(element['nes_level_id'] == '4' && element['percentage'] == 100){

                    levelsAchieved[element['nes_id']] = '4';

                  }


                }
              }
            }
          }

        }


      });


    });

  }
  getAllKeyEvidenceDetails() async {
    var keyEvidences = await _keyEvidenceService.readAllKeyEvidencesByRequirement(widget.inspection.id.toString());

    _keyEvidenceList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    keyEvidences.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = int.parse(key_evidence['nes_id']);
        keyEvidenceModel.requirementName = key_evidence['requirement_name'];
        keyEvidenceModel.requirementId = key_evidence['requirement_id'];
        keyEvidenceModel.nesLevelId = key_evidence['nes_level_id'];
        keyEvidenceModel.nesId = !nes.contains(key_evidence['nes_id']) ? key_evidence['nes_name'] : '';
        keyEvidenceModel.description = key_evidence['key_evidence_description'];
        keyEvidenceModel.visitId = !nes.contains(key_evidence['nes_id']) ? key_evidence['recommendation_description'] : '';
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus =key_evidence['key_evidence_status'];

        _keyEvidenceList.add(keyEvidenceModel);
      });
      if(!nes.contains(key_evidence['nes_id'])){
        nes.add(key_evidence['nes_id']);
      }
      evidenceDesc[key_evidence['key_evidence_id']] = key_evidence['key_evidence_description'];

    });
  }
  getAllRequirementsAchieved() async {
    var levelsAchived = await _keyEvidenceService.readAllRequirementsAchieved(widget.inspection.id.toString());
    _achievedList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    levelsAchived.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = key_evidence['key_evidence_id'];
        keyEvidenceModel.requirementName = key_evidence['requirement_name'];
        keyEvidenceModel.requirementId = key_evidence['requirement_id'];
        keyEvidenceModel.nesLevelId = key_evidence['achieved'].toString();
        keyEvidenceModel.nesId = key_evidence['nes_id'];
        keyEvidenceModel.description = key_evidence['out_of'];
        keyEvidenceModel.visitId = key_evidence['recommendation_description'];
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus =key_evidence['nes_level_id'];


        _achievedList.add(keyEvidenceModel);
      });
      if(!nes.contains(key_evidence['nes_id'])){
        nes.add(key_evidence['nes_id']);
      }
    });

  }
  getNesLevelsAchieved() async {
    var nesLevelsAchived = await _keyEvidenceService.readNesLevelsAchieved(widget.inspection.id.toString());

    _nesAchievedList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    nesLevelsAchived.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = key_evidence['key_evidence_id'];
        keyEvidenceModel.requirementName = key_evidence['requirement_name'];
        keyEvidenceModel.requirementId = key_evidence['requirement_id'];
        keyEvidenceModel.nesLevelId = key_evidence['achieved'].toString();
        keyEvidenceModel.nesId = key_evidence['nes_id'];
        keyEvidenceModel.description = key_evidence['out_of'];
        keyEvidenceModel.visitId = key_evidence['recommendation_description'];
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus =key_evidence['nes_level_id'];

        _nesAchievedList.add(keyEvidenceModel);
      });
      if(!nes.contains(key_evidence['nes_id'])){
        nes.add(key_evidence['nes_id']);
      }

    });

  }
  final List<InspectionSeries> data = [

  ];
  late bool _viewTile = true;
  @override
  void initState() {
    var user = context.read<AccountProvider>().user;
    if(user!['user_role']=='Secondary Advisor'){
      _viewTile = false;
    }
    getNesLevelAchieved();
    getNesLevelsAchieved();
    getAllKeyEvidenceDetails();
    getAllRequirementsAchieved();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(


        appBar: AppBar(
          title: const Text("Key Evidences"),
          backgroundColor: kPrimaryColor,
        ),

        body: RefreshIndicator(
          onRefresh: () {
            return Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return KeyEvidence(inspection: widget.inspection,);
                },
              ),
            ); },
          child:Center(
        child: ListView(

          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children:<Widget>[
                  Text(

                      'Home',
                      style: TextStyle(fontSize: 15, )
                  ),
                  Icon(Icons.arrow_right),
                  Text(
                      'Key Evidences',
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                  ),
                ],

              ),

            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text(
                  "Key Evidence Management",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold )
              ),
            ),

            _viewTile? Row(
              children: <Widget>[
                Container(
                  padding:const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Hero(
                    tag: "new_inspection_btn",
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return KeyEvidenceForm(inspection: widget.inspection);
                            },
                          ),
                        ).then((data) {
                          if (data != null) {
                            getNesLevelAchieved();
                            getNesLevelsAchieved();
                            getAllKeyEvidenceDetails();
                            getAllRequirementsAchieved();
                            _showSuccessSnackBar(
                                'Key evidence Added Successfully');
                          }
                        });
                      },
                      icon: Icon( // <-- Icon
                        Icons.add,
                        size: 24.0,
                      ),
                      label: Text('New Evidence'), // <-- Text
                    ),
                  ),
                ),


              ],

            ):Container(),
            Divider(
                color: Colors.grey
            ),
            SingleChildScrollView(
                            scrollDirection: Axis.horizontal,

                            child: DataTable(
                              dataRowHeight: (MediaQuery.of(context).size.height - 56) / 4,

                              columns: [
                                DataColumn(
                                    label: Text('NES', style: TextStyle(fontSize: 14))),
                                DataColumn(
                                    label: Text('REQUIREMENT', style: TextStyle(fontSize: 14))),
                                DataColumn(
                                    label: Text('LEVEL', style: TextStyle(fontSize: 14))),
                                DataColumn(
                                    label: Text('STATUS', style: TextStyle(fontSize: 14))),
                                DataColumn(
                                    label: Text('EVIDENCE',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ))),
                                DataColumn(
                                    label: Text('MINOR RECOMMENDATION', style: TextStyle(fontSize: 14))),
                                _viewTile? DataColumn(
                                    label: Text('ACTIONS', style: TextStyle(fontSize: 14))): DataColumn(
                                    label: Text('', style: TextStyle(fontSize: 14))),
                              ],
                              rows: _keyEvidenceList.map((item) {

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        width: 120,
                                        child: Text(item.nesId.toString()),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        width: 120,
                                        child: Text('${item.id.toString()}.${item.requirementId.toString()}  ${item.requirementName.toString()}'),
                                      ),
                                    ),
                                    DataCell(Text(item.nesLevelId.toString())),
                                    DataCell(Text(item.keyEvidenceStatus.toString())),
                                    DataCell(Text(item.description.toString())),
                                    DataCell(Text(item.visitId.toString())),
                                    DataCell(item.nesId == '' ? const Text("") :
                                    _viewTile?Row(children:[
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return EditKeyEvidence(inspection: widget.inspection, keyEvidenceModel: item);
                                                },
                                              ),
                                            ).then((data) {
                                              if (data != null) {
                                                getNesLevelAchieved();
                                                getNesLevelsAchieved();
                                                getAllKeyEvidenceDetails();
                                                getAllRequirementsAchieved();
                                                _showSuccessSnackBar(
                                                    'Key evidence Updated Successfully');
                                              }
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.teal,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            _deleteFormDialog(context,
                                                item.id, widget.inspection.id);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ))
                                    ]):Container(),)
                                  ],

                                );
                              }).toList(),


                            ),

                          ),
            Divider(
                color: Colors.grey
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.teal,
             child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                   Text("REQUIREMENT ACHIEVEMENT PERCENTAGE", style: TextStyle(color: Colors.white),),
              ],

            ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                      label: Text('NES', style: TextStyle(fontSize: 14))),
                  DataColumn(
                      label: Text('LEVEL', style: TextStyle(fontSize: 14))),
                  DataColumn(
                      label: Text('ACHIEVED', style: TextStyle(fontSize: 14))),
                  DataColumn(
                      label: Text('OUT OF', style: TextStyle(fontSize: 14))),
                  DataColumn(
                      label: Text('PERCENTAGE', style: TextStyle(fontSize: 14,))),

                ], rows: _achievedList.map((item) {
                var percentage = (int.parse(item.nesLevelId.toString()) / int.parse(item.description.toString())) * 100;

                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        child: Text(item.nesId.toString()),
                      ),
                    ),
                    DataCell(Text(item.keyEvidenceStatus.toString())),
                    DataCell(Text(item.nesLevelId.toString())),
                    DataCell(Text(item.description.toString())),
                    DataCell(Text("${percentage.toInt().toString()}%")),

                  ],

                );
              }).toList(),


              ),

            ),
            Divider(
                color: Colors.grey
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.teal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text("NES LEVEL ACHIEVEMENT", style: TextStyle(color: Colors.white),),
                ],

              ),
            ),
            DataTable(
              columns: [
                DataColumn(
                    label: Text('NES', style: TextStyle(fontSize: 14))),
                DataColumn(
                    label: Text('LEVEL ACHIEVED', style: TextStyle(fontSize: 14))),
                DataColumn(
                    label: Text('REACTION IMAGE', style: TextStyle(fontSize: 14))),
              ], rows: _nesAchievedList.map((item) {

                String emoji='';
              if(levelsAchieved[item.nesId] == '1'){
                setState(() {
                  emoji = 'assets/images/poor.png';
                });
              }
                if(levelsAchieved[item.nesId] == '2'){
                  setState(() {
                    emoji = 'assets/images/good.png';
                  });
                }
                if(levelsAchieved[item.nesId] == '3'){
                  setState(() {
                    emoji = 'assets/images/vgood.png';
                  });
                }
                if(levelsAchieved[item.nesId] == '4'){
                  setState(() {
                    emoji = 'assets/images/excellent.png';
                  });
                }
              return DataRow(

                cells: [
                  DataCell(
                    Container(
                      child: Text(item.nesId.toString()),
                    ),
                  ),
                  DataCell(Text(levelsAchieved[item.nesId])),

                  DataCell(Image(image: AssetImage(emoji),height: 30,)),

                ],

              );
            }).toList(),




            ),
            Divider(
                color: Colors.grey
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.teal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text("NES ACHIEVEMENT GRAPH", style: TextStyle(color: Colors.white),),
                ],
              ),
            ),
            Container(
                child: SfCartesianChart(
                    isTransposed: true,
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(minimum: 0, maximum: 4,interval: 1),
                    tooltipBehavior: _tooltip,

                    series: <ChartSeries<_ChartData, String>>[

                      BarSeries<_ChartData, String>(
                          dataSource: _achievedList.map((item) {
                            var year = double.parse(levelsAchieved[item.nesId]);
                            return _ChartData(year,item.nesId.toString());
                          }).toList(),
                          xValueMapper: (_ChartData data, _) => data.y,
                          yValueMapper: (_ChartData data, _) => data.x,
                          name: 'Level achived',
                          color: Color.fromRGBO(255, 156, 46, 1),
                          markerSettings: MarkerSettings(
                            isVisible: true,
                          )),

                    ])),
          ],

        ),

      ),),
    );

  }
}
class _ChartData {
  _ChartData(this.x, this.y);

  final String y;
  final double x;
}





