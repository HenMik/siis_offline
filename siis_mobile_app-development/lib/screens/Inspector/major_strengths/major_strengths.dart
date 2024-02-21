import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../models/Inspection.dart';
import '../../../models/area_of_improvement.dart';
import '../../../models/good_practices.dart';
import '../../../models/inspUpdate.dart';
import '../../../models/major_strengths.dart';
import '../../../services/InspectionService.dart';
import '../../../services/MajorStrengths.dart';
import '../../../utils/account_provider.dart';

class MajorStrength extends StatefulWidget {
  final Inspection inspection;
  const MajorStrength({Key? key, required this.inspection}) : super(key: key);

  @override
  _MajorStrength createState() => _MajorStrength();
}

class _MajorStrength extends State<MajorStrength> {
  String? selectedNESValue;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var school_id;
  var _description = TextEditingController();
  var _recomServices = MajorStrengthsService();
  var _formKeySchoolVisit = GlobalKey<FormState>();
  late List<MajorStrengthModel> _majorStrengthList = <MajorStrengthModel>[];
  getAllMajorStrengthDetails() async {
    var majorStrengths = await _recomServices
        .readAllMajorStrengthssByVisitId(widget.inspection.id.toString());
    print(majorStrengths);
    _majorStrengthList = <MajorStrengthModel>[];
    majorStrengths.forEach((majorStrength) {
      setState(() {
        var majorStrengthModel = MajorStrengthModel();
        majorStrengthModel.id = majorStrength['strength_id'];
        majorStrengthModel.createdAt = majorStrength['created_at'];
        majorStrengthModel.description = majorStrength['strength_description'];
        majorStrengthModel.visitId = majorStrength['visit_id'];
        _majorStrengthList.add(majorStrengthModel);
      });
    });
  }

  late bool _viewTile = true;
  var _inspectionService = InspectionService();
  @override
  void initState() {
    var user = context.read<AccountProvider>().user;
    if (user!['user_role'] == 'Secondary Advisor') {
      _viewTile = false;
    }
    getAllMajorStrengthDetails();
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

  _deleteFormDialog(BuildContext context, majorStrengthId) {
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
                    var result = await _recomServices
                        .deleteMajorStrength(majorStrengthId);
                    if (result != null) {
                      Navigator.of(context, rootNavigator: true).pop();
                      setState(() {
                        getAllMajorStrengthDetails();
                      });
                      _showSuccessSnackBar(
                          'Major Strength Deleted Successfully');
                    }
                  },
                  child: const Text('Delete')),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.pop(
                        context);
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
        title: Text('Major Strengths'),
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
                  Text('MajorStrengths',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text("Major Strength Management",
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
                              backgroundColor: Colors.teal,
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
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text('Add Major Strength',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  )),
                                              SizedBox(
                                                height: 25.0,
                                              ),
                                              Form(
                                                key: _formKeySchoolVisit,
                                                child: TextFormField(
                                                  controller: _description,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  maxLines: 4,
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return ("Description is required");
                                                    }
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'Description',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 25.0,
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                        primary: Colors.white,
                                                        backgroundColor:
                                                            Colors.teal,
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 15)),
                                                    onPressed: () async {
                                                      if (_formKeySchoolVisit
                                                          .currentState!
                                                          .validate()) {
                                                        var _majorStrength =
                                                            MajorStrengthModel();
                                                        var inspection = InspectionUp();
                                                        _majorStrength
                                                                .description =
                                                            _description.text;
                                                        _majorStrength.visitId =
                                                            widget.inspection.id
                                                                .toString();
                                                        _majorStrength
                                                                .createdAt =
                                                            currentDate;
                                                        var result = await _recomServices
                                                            .SaveMajorStrengths(
                                                                _majorStrength);
                                                        setState(() {
                                                          getAllMajorStrengthDetails();
                                                          _description.text =
                                                          '';
                                                        });
                                                        _showSuccessSnackBar(
                                                            'Major Strength added Successfully');
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
                                                                fontSize: 15)),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context);
                                                      },
                                                    child: Text('Cancel'),
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
                            icon: Icon(
                              // <-- Icon
                              Icons.add,
                              size: 24.0,
                            ),
                            label: Text('New Major Strength'), // <-- Text
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(color: Colors.grey)),
            _majorStrengthList.isEmpty
                ? Center(
                    child: Image.asset("assets/images/empty.png"),
                  )
                : ListView.builder(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _majorStrengthList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {},
                          leading: const Icon(Icons.thumb_up),
                          title: Text(
                              "${_majorStrengthList[index].description}" ?? ''),
                          subtitle:
                              Text(_majorStrengthList[index].createdAt ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _description.text =
                                          _majorStrengthList[index].description;
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
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text('Edit Major Strength',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        )),
                                                    SizedBox(
                                                      height: 25.0,
                                                    ),
                                                    TextFormField(
                                                      controller: _description,
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
                                                    Row(
                                                      children: <Widget>[
                                                        TextButton(
                                                          style: TextButton.styleFrom(
                                                              primary:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  Colors.teal,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15)),
                                                          onPressed: () async {
                                                            var _majorStrength =
                                                                MajorStrengthModel();
                                                            _majorStrength.id =
                                                                _majorStrengthList[
                                                                        index]
                                                                    .id;
                                                            _majorStrength
                                                                    .description =
                                                                _description
                                                                    .text;
                                                            _majorStrength
                                                                    .visitId =
                                                                widget
                                                                    .inspection
                                                                    .id
                                                                    .toString();
                                                            _majorStrength
                                                                    .createdAt =
                                                                _majorStrengthList[
                                                                        index]
                                                                    .createdAt;
                                                            var result =
                                                                await _recomServices
                                                                    .UpdateMajorStrength(
                                                                        _majorStrength);
                                                            setState(() {
                                                              getAllMajorStrengthDetails();
                                                            });
                                                            print(
                                                                _majorStrengthList[
                                                                        index]
                                                                    .id);
                                                            _showSuccessSnackBar(
                                                                'Major Strength updated Successfully');
                                                            Navigator.pop(
                                                                context,
                                                                result);
                                                          },
                                                          child: Text('UPDATE'),
                                                        ),
                                                        const SizedBox(
                                                          width: 10.0,
                                                        ),
                                                        TextButton(
                                                          style: TextButton.styleFrom(
                                                              primary:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15)),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('Cancel'),
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
                                        context, _majorStrengthList[index].id);
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
          ],
        ),
      ),
    );
  }
}
