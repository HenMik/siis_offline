import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/constants.dart';
import 'package:siis_offline/screens/Inspector/school_visits.dart';
import 'package:siis_offline/utils/account_provider.dart';

import '../../models/Inspection.dart';
import '../../models/key_evidence.dart';
import '../../models/national_standards.dart';
import '../../models/nes_requirements.dart';
import '../../services/KeyEvidenceService.dart';
import 'edit_inspection.dart';
import 'control_panel.dart';

class ViewKeyEvidence extends StatefulWidget {
  final Inspection inspection;
  final KeyEvidenceModel keyEvidence;

  const ViewKeyEvidence({Key? key, required this.inspection, required this.keyEvidence}) : super(key: key);

  @override
  State<ViewKeyEvidence> createState() => _ViewKeyEvidenceState();
}

class _ViewKeyEvidenceState extends State<ViewKeyEvidence> {
  late List<KeyEvidenceModel> _keyEvidenceList = <KeyEvidenceModel>[];
  final _keyEvidenceService = KeyEvidenceService();

  getAllKeyEvidenceDetails() async {
    var keyEvidences = await _keyEvidenceService.readAllKeyEvidencesByRequirement(widget.inspection.id.toString());
    _keyEvidenceList = <KeyEvidenceModel>[];
    keyEvidences.forEach((key_evidence) {
      setState(() {
        var keyEvidenceModel = KeyEvidenceModel();
        keyEvidenceModel.id = key_evidence['key_evidence_id'];
        keyEvidenceModel.requirementId = key_evidence['requirement_name'];
        keyEvidenceModel.nesLevelId = key_evidence['nes_level_id'];
        keyEvidenceModel.nesId = key_evidence['nes_name'];
        keyEvidenceModel.description = key_evidence['key_evidence_description'];
        keyEvidenceModel.visitId = key_evidence['visit_id'];
        keyEvidenceModel.createdAt = key_evidence['created_at'];
        keyEvidenceModel.keyEvidenceStatus =key_evidence['key_evidence_status'];

        _keyEvidenceList.add(keyEvidenceModel);
      });

    });

  }
  @override
  void initState() {
    getAllKeyEvidenceDetails();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Key Evidence"),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: ListView(children: [
          Container(
            padding: EdgeInsets.all(14),
            child: Text("KEY EVIDENCE DETAILS",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          Flexible(
              child: SingleChildScrollView(
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
                  ],
                  rows: _keyEvidenceList!.map((item) {
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
                            child: Text(item.requirementId.toString()),
                          ),
                        ),
                        DataCell(Text(item.nesLevelId.toString())),
                        DataCell(Text(item.keyEvidenceStatus.toString())),
                        DataCell(Text(item.description.toString())),
                        DataCell(Text('')),
                      ],

                    );
                  }).toList(),


                ),

              )),

        ]),
      ),
    );
  }
}
