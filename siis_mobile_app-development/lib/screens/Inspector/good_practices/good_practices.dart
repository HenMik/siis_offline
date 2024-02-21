import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../models/Inspection.dart';
import '../../../models/area_of_improvement.dart';
import '../../../models/good_practices.dart';
import '../../../services/GoodPractices.dart';
import '../../../utils/account_provider.dart';
class GoodPractices extends StatefulWidget {
  final Inspection inspection;
  const GoodPractices ({Key? key, required this.inspection}) : super(key: key);

  @override
  _GoodPractices createState() => _GoodPractices();

}

class _GoodPractices extends State<GoodPractices> {
  String? selectedNESValue;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var school_id;
  var _description = TextEditingController();
  var _practiceService = GoodPracticesService();
  late List<GoodPracticesModel> _goodPracticesList = <GoodPracticesModel>[];
  getAllGoodPracticesDetails() async {
    var goodPracticess = await _practiceService.readAllGoodPracticessByVisitId(widget.inspection.id.toString());
    _goodPracticesList = <GoodPracticesModel>[];
    goodPracticess.forEach((goodPractices) {
      setState(() {
        var goodPracticesModel = GoodPracticesModel();
        goodPracticesModel.id = goodPractices['good_practice_id'];
        goodPracticesModel.createdAt = goodPractices['created_at'];
        goodPracticesModel.description= goodPractices['good_practice_description'];
        goodPracticesModel.visitId = goodPractices['visit_id'];
        _goodPracticesList.add(goodPracticesModel);

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
    getAllGoodPracticesDetails();
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
  _deleteFormDialog(BuildContext context, good_practice_id) {
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
                    await _practiceService.deleteGoodPractice(good_practice_id);
                    if (result != null) {
                      _showSuccessSnackBar('Good Practices Deleted Successfully');
                      setState(() {

                      });
                      getAllGoodPracticesDetails();
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
        title: Text('Good Practicess'),
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
                      'GoodPracticess',
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                  ),
                ],

              ),

            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text(
                  "Good Practices Management",
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
                                            'Add Good Practices',
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
                                                var _goodPractices = GoodPracticesModel();

                                                _goodPractices.description = _description.text;
                                                _goodPractices.visitId = widget.inspection.id.toString();
                                                _goodPractices.createdAt = currentDate;
                                                var result = await _practiceService.SaveGoodPractices(_goodPractices);
                                                setState(() {
                                                  getAllGoodPracticesDetails();
                                                  _description.text =
                                                  '';
                                                });
                                                _showSuccessSnackBar('Good Practices added Successfully');
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
                      label: Text('New GoodPractices'), // <-- Text
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
            _goodPracticesList.isEmpty?
            Center(
              child: Image.asset("assets/images/empty.png"),
            ):
            ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: _goodPracticesList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {

                      },
                      leading: const Icon(Icons.check),
                      title: Text(
                          "${_goodPracticesList[index].description}" ??
                              ''),
                      subtitle: Text(_goodPracticesList[index].createdAt??
                          ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _description.text = _goodPracticesList[index].description;
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
                                                        var _goodpractice = GoodPracticesModel();
                                                        _goodpractice.id = _goodPracticesList[index].id;
                                                        _goodpractice.description = _description.text;
                                                        _goodpractice.visitId = widget.inspection.id.toString();
                                                        _goodpractice.createdAt = _goodPracticesList[index].createdAt;
                                                        var result = await _practiceService.UpdateGoodPractice(_goodpractice);
                                                        setState(() {
                                                          getAllGoodPracticesDetails();
                                                        });
                                                        _showSuccessSnackBar('Major Strength updated Successfully');
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
                                    _goodPracticesList[index].id);
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



