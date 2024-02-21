import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../models/Inspection.dart';
import '../../../models/critical_issues.dart';
import '../../../services/CriticalIssues.dart';
import '../../../utils/account_provider.dart';

class CriticalIssues extends StatefulWidget {
  final Inspection inspection;
  const CriticalIssues ({Key? key, required this.inspection}) : super(key: key);

  @override
  _CriticalIssues createState() => _CriticalIssues();

}

class _CriticalIssues extends State<CriticalIssues> {
  String? selectedNESValue;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var school_id;
  var _description = TextEditingController();
  var _crititalService = CriticalIssuesService();
  late List<CriticalIssuesModel> _criticalissuesList = <CriticalIssuesModel>[];
  getAllCriticalIssuesDetails() async {
    var criticalIssues= await _crititalService.readAllCriticalIssuessByVisitId(widget.inspection.id.toString());
    _criticalissuesList = <CriticalIssuesModel>[];
    criticalIssues.forEach((criticalIssues) {
      setState(() {
        var criticalIssuesModel = CriticalIssuesModel();
        criticalIssuesModel.id = criticalIssues['critical_issue_id'];
        criticalIssuesModel.createdAt = criticalIssues['created_at'];
        criticalIssuesModel.description= criticalIssues['critical_issue_description'];
        criticalIssuesModel.visitId = criticalIssues['visit_id'];
        _criticalissuesList.add(criticalIssuesModel);

      });
    });

  }
  late bool _viewTile = true;
  @override
  void initState() {
    var user = context.read<AccountProvider>().user;
    if(user!['user_role']=='Secondary Advisor'){
      _viewTile = false;
    }
    getAllCriticalIssuesDetails();
    super.initState();

  }
  List<DropdownMenuItem<String>> get nes{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("1. Outcomes for students"),value: "1"),
      DropdownMenuItem(child: Text("2. The teaching process"),value: "2"),
      DropdownMenuItem(child: Text("3. Leadership"),value: "3"),
      DropdownMenuItem(child: Text("4. Management"),value: "4"),
    ];
    return menuItems;

  }


  _deleteFormDialog(BuildContext context, critical_issue_id) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: const Text(
              'Are You Sure to Delete Good Practices?',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.red),
                  onPressed: () async {
                    var result =
                    await _crititalService.deleteCriticalIssue(critical_issue_id);
                    if (result != null) {
                      _showSuccessSnackBar('Critical Issue Deleted Successfully');
                      setState(() {

                      });
                      getAllCriticalIssuesDetails();
                      Navigator.of(context, rootNavigator: true).pop();
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
        title: Text('Critical Issues'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,),

      body: Center(
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
                      'Critical Issuess',
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                  ),
                ],

              ),

            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text(
                  "Critical Issues Management",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold )
              ),
            ),

            _viewTile?Row(
              children: <Widget>[

                Container(
                  padding:const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Hero(
                    tag: "new_inspection_btn",
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,),
                      onPressed: () {
                        showModalBottomSheet<void>(
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
                          context: context,
                          builder: (BuildContext context) {
                            return Wrap(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(20,20,20,
                                        MediaQuery.of(context).viewInsets.bottom+20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                            'Add Critical Issues',
                                            style: TextStyle(fontSize: 20, )
                                        ),
                                        SizedBox(
                                          height: 25.0,
                                        ),
                                        TextField(
                                          controller: _description,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                            labelText: 'Description',
                                            border: OutlineInputBorder(),
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
                                                  backgroundColor: Colors.deepPurple,
                                                  textStyle: const TextStyle(fontSize: 15)),
                                              onPressed: () async {
                                                var _criticalIssues = CriticalIssuesModel();

                                                _criticalIssues.description = _description.text;
                                                _criticalIssues.visitId = widget.inspection.id.toString();
                                                _criticalIssues.createdAt = currentDate;
                                                var result = await _crititalService.SaveCriticalIssues(_criticalIssues);
                                                setState(() {
                                                  getAllCriticalIssuesDetails();
                                                  _description.text =
                                                  '';
                                                });
                                                _showSuccessSnackBar('CriticalIssues added Successfully');
                                                Navigator.pop(context, result);
                                              },
                                              child: Text('SUBMIT'),
                                            ),
                                            const SizedBox(
                                              width: 10.0,
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                  primary: Colors.white,
                                                  backgroundColor: Colors.red,
                                                  textStyle: const TextStyle(fontSize: 15)),

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
                      icon: Icon( // <-- Icon
                        Icons.add,
                        size: 24.0,
                      ),
                      label: Text('New Critical Issues'), // <-- Text
                    ),
                  ),
                ),

              ],

            ):Container(),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(
                    color: Colors.grey
                )
            ),
            _criticalissuesList.isEmpty?
            Center(
              child: Image.asset("assets/images/empty.png"),
            ):
            ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: _criticalissuesList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {

                      },
                      leading: const Icon(Icons.warning_rounded),
                      title: Text(
                          "${_criticalissuesList[index].description}" ??
                              ''),
                      subtitle: Text(_criticalissuesList[index].createdAt??
                          ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _description.text = _criticalissuesList[index].description;
                                });
                                showModalBottomSheet<void>(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Wrap(
                                      children: [
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(20,20,20,
                                                MediaQuery.of(context).viewInsets.bottom+20),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                    'Edit Major Strength',
                                                    style: TextStyle(fontSize: 20, )
                                                ),
                                                SizedBox(
                                                  height: 25.0,
                                                ),
                                                TextFormField(
                                                  controller: _description,
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: 4,
                                                  decoration: InputDecoration(
                                                    labelText: 'Description',
                                                    border: OutlineInputBorder(),
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
                                                          backgroundColor: Colors.teal,
                                                          textStyle: const TextStyle(fontSize: 15)),
                                                      onPressed: () async {
                                                        var _criticalissues = CriticalIssuesModel();
                                                        _criticalissues.id = _criticalissuesList[index].id;
                                                        _criticalissues.description = _description.text;
                                                        _criticalissues.visitId = widget.inspection.id.toString();
                                                        _criticalissues.createdAt = _criticalissuesList[index].createdAt;
                                                        var result = await _crititalService.UpdateCriticalIssue(_criticalissues);
                                                        setState(() {
                                                          getAllCriticalIssuesDetails();
                                                        });
                                                        _showSuccessSnackBar('Critical Issue updated Successfully');
                                                        Navigator.pop(context, result);
                                                      },
                                                      child: Text('UPDATE'),
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                          primary: Colors.white,
                                                          backgroundColor: Colors.red,
                                                          textStyle: const TextStyle(fontSize: 15)),

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
                                _deleteFormDialog(context,
                                    _criticalissuesList[index].id);
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




