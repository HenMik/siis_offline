import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:siis_offline/models/national_standards.dart';
import 'package:siis_offline/models/nes_notifications.dart';
import 'package:siis_offline/models/nes_requirements.dart';

import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/key_evidence.dart';
import '../../models/recommendation.dart';
import '../../services/RecommendationService.dart';
import '../../services/keyEvidenceService.dart';
import '../../services/nesNotificationsService.dart';

class EditKeyEvidence extends StatefulWidget {
  final Inspection inspection;
  final KeyEvidenceModel keyEvidenceModel;
  const EditKeyEvidence({Key? key, required this.inspection, required this.keyEvidenceModel}) : super(key: key);

  @override
  _EditKeyEvidenceState createState() => _EditKeyEvidenceState();
}

class _EditKeyEvidenceState extends State<EditKeyEvidence> {
  String? dropDownValue;
  String? nessId;
  String? nesLevelId;
  String? requirementId;
  String? keyStatus;
  var _nesNotificationService = NesNotificationsService();
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late List<NesRequirement>? nes_requirement = [];
  late List<NesRequirement>? new_description_list = [];
  final List<String?> _desc = [];
  var _formKeySchoolVisit = GlobalKey<FormState>();
  var _key = GlobalKey<FormState>();
  var _deps = [];
  var keyForm;
  var form = [];
  late Iterable<NationalStandard>? neses = [];
  var _recomService = RecommendationService();
  bool _showNotifications = false;
  List<DropdownMenuItem<String>> get status {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Positive"), value: "Positive"),
      DropdownMenuItem(child: Text("Negative"), value: "Negative"),
    ];
    return menuItems;
  }
  List<MultiSelectItem<String>> get sendTo {
    List<MultiSelectItem<String>> menuItems = [
      MultiSelectItem("DQAS HQ", "DQAS HQ"),
      MultiSelectItem("MIE", "MIE"),
      MultiSelectItem("DSE", "DSE"),
      MultiSelectItem("DEM", "DEM"),
      MultiSelectItem("EDM", "EDM"),
      MultiSelectItem("DTED", "DTED"),
      MultiSelectItem("E-planning", "E-planning"),
      MultiSelectItem("DIE", "DIE"),
      MultiSelectItem("DST", "DST"),
      MultiSelectItem("MANEB", "MANEB"),
    ];
    return menuItems;
  }
  var _description = TextEditingController();
  final List<TextEditingController> _evidenceDescription = [TextEditingController()];
  final List<String?> keyEvidenceStatus = [];
  final List<String?> nessIdList = [];
  final List<String?> nesLevelIdList = [];
  final List<String?> requirementIdList = [];
  var _keyEvidenceService = KeyEvidenceService();
  final _recommendationService = RecommendationService();
  var evidenceDesc = {};
  var stat = {};
  late List<KeyEvidenceModel> _keyEvidenceList = <KeyEvidenceModel>[];

  get requirementName => null;
  /*getAlKeyEvidenceDetails() async {
    var keyEvidence = await _keyEvidenceService.readAllKeyEvidences();
    _majorStrengthList = <MajorStrengthModel>[];
    majorStrengths.forEach((majorStrength) {
      setState(() {
        var majorStrengthModel = MajorStrengthModel();
        majorStrengthModel.id = majorStrength['strength_id'];
        majorStrengthModel.createdAt = majorStrength['created_at'];
        majorStrengthModel.description= majorStrength['strength_description'];
        majorStrengthModel.visitId = majorStrength['visit_id'];
        _majorStrengthList.add(majorStrengthModel);

      });
    });

  }*/
  var _initial;
  var _nesNotifications = NesNotificationsService();
  late List<NesNotifications> _nesNotificationList = <NesNotifications>[];
  getAllnesNotifications() async {
    var nesNotifications = await _nesNotifications.readAllNesNotifications(widget.keyEvidenceModel.id.toString(),widget.inspection.id.toString());
    _nesNotificationList = <NesNotifications>[];
    nesNotifications.forEach((nes) {
      setState(() {
        var nesNotification = NesNotifications();
        nesNotification.id = nes['nes_notification_id'];
        nesNotification.visitId = nes['visit_id'].toString();
        nesNotification.nesId = nes['nes_id'].toString();
        nesNotification.departmentId = nes['department_id'].toString();
        _nesNotificationList.add(nesNotification);

      });
    });
    _deps = [for(var i = 0; i < _nesNotificationList.length; i++) _nesNotificationList[i].departmentId.toString()];
    _showNotifications = true;

  }
  getAllKeyEvidenceDetails() async {
    var keyEvidences = await _keyEvidenceService.readAllRequirementsAchievedAndNes(widget.inspection.id.toString(),widget.keyEvidenceModel.id.toString());

    _keyEvidenceList = <KeyEvidenceModel>[];
    var nes = <dynamic>{};
    keyEvidences.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = int.parse(key_evidence['nes_id']);
        keyEvidenceModel.requirementId = key_evidence['requirement_id'];
        keyEvidenceModel.requirementName = key_evidence['requirement_name'];
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
      evidenceDesc[key_evidence['requirement_id']] = key_evidence['key_evidence_description'];
      stat[key_evidence['requirement_id']] = key_evidence['key_evidence_status'];
      _desc.add(key_evidence['requirement_id'].toString());
      requirementIdList.add(key_evidence['requirement_id'].toString());
      nesLevelIdList.add(key_evidence['nes_level_id'].toString());
      keyEvidenceStatus.add(key_evidence['key_evidence_status']);
      keyForm = {'id': key_evidence['requirement_id'].toString(), 'nes_level': key_evidence['nes_level_id'].toString(),
        'key_status': key_evidence['key_evidence_status'].toString(), 'description': key_evidence['requirement_id'].toString()};
      form.add(keyForm);
    });

  }
  getAllNESRequirementDetails(String? nes_id) async {
    List<NesRequirement>? nr =
        await NesRequirementProvider().getByNesId(nes_id);
    setState(() {
      nes_requirement = nr;
    });
  }

  getAllNESDetails() async {
    Iterable<NationalStandard>? n = await NationalStandardProvider().getAll();
    setState(() {
      neses = n;
    });
  }
  late bool _showForm;
  @override
  void initState() {
    getAllnesNotifications();
    _description.text = widget.keyEvidenceModel.visitId;
    getAllKeyEvidenceDetails();
    getAllNESRequirementDetails(widget.keyEvidenceModel.id.toString());
    getAllNESDetails();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Key Evidence"),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: ListView(children: [

          Container(
            padding: EdgeInsets.all(14),
            child: Text("KEY EVIDENCE EDIT FORM",
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
                  child: Text('Editing on:'.toUpperCase(), style: TextStyle(
                    fontSize: 16,
                  )),
                ),
                Expanded(
                  flex: 3,
                  child: Text('${widget.keyEvidenceModel.nesId}'.toUpperCase(), style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey),
          Form(
              key: _key,
              child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowHeight: (MediaQuery.of(context).size.height - 56) / 4,
              columns: [
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
              ],
              rows: nes_requirement!.map((item) {
                var index = nes_requirement!.indexOf(item);
                _evidenceDescription.add(new TextEditingController());
                  _evidenceDescription[index].text =  evidenceDesc[item.requirementId.toString()];


                  return DataRow(   cells: [
                      DataCell(
                          Container(
                   width: 120,
                   child: Text('${item.nesId.toString()}.${item.requirementId.toString()}  ${item.requirementName.toString()}'),
                   ),
                   ),
                      DataCell(Text(item.nesLevelId.toString())),
                      DataCell(DropdownButtonFormField(
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 6),
                  labelText: 'status',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                value: stat[item.requirementId.toString()].toString()=='null'?null:stat[item.requirementId.toString()].toString(),
                onChanged: (String? newValue) {
                  setState(() {
    var contain = form.where((element) => element["id"] == item.requirementId.toString());

    if(contain.isEmpty){
    keyForm = {'id': item.requirementId.toString(), 'nes_level': item.nesLevelId.toString(),
    'key_status': newValue, 'description': item.requirementId.toString()};
    form.add(keyForm);
    }
    else {
                    form.forEach((element) {
                      if(element['id'].contains(item.requirementId.toString())){
                        form[form.indexOf(element)] =
                        {'id': element['id'], 'nes_level': element['nes_level'],
                          'key_status': newValue, 'description': element['description']
                        };

                      }
                    });}
                  });
                },
                items: status,

              )),
                      DataCell(

                TextFormField(
                  onSaved: (newVar) {
                    for (var element in form) {
                      if (element['description'] == item.requirementId.toString()) {
                        setState(() {
                          form[form.indexOf(element)] =
                          {'id': element['id'], 'nes_level': element['nes_level'],
                            'key_status': element['key_status'], 'description': newVar};
                        });
                      }
                      else{

                      }
                    }
                  },
                  controller: _evidenceDescription[index],
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Evidence description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

                  ],

               );
              }).toList(),


            ),

          )),
          Column(
            children: [
              Divider(color: Colors.grey),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional(0, 0.05),
                            child: Text(
                              'Minor Recommendation:',
                            ),
                          ),
                        ),
                        Form(
                            key: _formKeySchoolVisit,
                            child: Expanded(
                              flex: 3,
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Minor recommendation is required");
                                  }
                                },
                                controller: _description,
                                keyboardType: TextInputType.multiline,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: '',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    _showNotifications?Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional(0, 0.05),
                            child: Text(
                              'Send Notificstions to:',
                            ),
                          ),
                        ),
                        Expanded(

                          flex: 3,
                        child: MultiSelectDialogField(
                          title: Text("Departments"),
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
                            Icons.home_work_outlined,
                            color: Colors.teal,
                          ),
                          buttonText: Text(
                            "Departments",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),

                          initialValue: [for(var i = 0; i < _nesNotificationList.length; i++) _nesNotificationList[i].departmentId.toString()],
                          items: sendTo,
                          onConfirm: (result) {
                            setState(() {
                              _deps = result;
                            });
                          },
                        ),),
                      ],

                    ):Text(''),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: <Widget>[
              const SizedBox(
                width: 10.0,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.deepPurple,
                    textStyle: const TextStyle(fontSize: 15)),
                onPressed: () async {
                 _key.currentState!.save();
                  if (_formKeySchoolVisit.currentState!.validate()) {
                    await _keyEvidenceService.deleteKeyEvidence(widget.keyEvidenceModel.id, widget.inspection.id);
                    await _recommendationService.deleteRecommendationWithKeyEvidence(widget.keyEvidenceModel.id, widget.inspection.id);
                    await _nesNotificationService.deleteNesNotifications(widget.keyEvidenceModel.id, widget.inspection.id);
                    var _keyEvidence = KeyEvidenceModel();
                    form.forEach((element) async {
                      _keyEvidence.description = element['description'];
                      _keyEvidence.keyEvidenceStatus = element['key_status'].toString();
                      _keyEvidence.createdAt = currentDate;
                      _keyEvidence.nesLevelId = element['nes_level'];
                      _keyEvidence.requirementId = element['id'].toString();
                      _keyEvidence.nesId = widget.keyEvidenceModel.id.toString();
                      _keyEvidence.visitId = widget.inspection.id.toString();
                      var result = await _keyEvidenceService.SaveKeyEvidence(
                          _keyEvidence);
                    });
                    var _recommendation = Recommendation();
                    _recommendation.description = _description.text;
                    _recommendation.nesId = widget.keyEvidenceModel.id.toString();
                    _recommendation.visitId = widget.inspection.id.toString();
                    _recommendation.recommendationType = "Minor";
                    _recommendation.createdAt = currentDate;
                    var result =
                    await _recomService.SaveRecommendation(_recommendation);
                    var _nesNotifications = NesNotifications();
                    for(var i = 0; i< _deps.length; i++){
                      _nesNotifications.departmentId = _deps[i];
                      _nesNotifications.nesId = widget.keyEvidenceModel.id.toString();
                      _nesNotifications.visitId = widget.inspection.id.toString();
                      await _nesNotificationService.SaveNesNotifications(_nesNotifications);
                    }
                    Navigator.pop(context, result);
                  }
                },
                child: Text('UPDATE'),
              ),

            ],
          ),
        ]),
      ),
    );
  }
}
