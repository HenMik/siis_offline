import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:siis_offline/models/actionPlan.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/inspUpdate.dart';
import '../../models/recommendation.dart';
import '../../services/ActionPlanService.dart';
import '../../services/InspectionService.dart';
import '../../services/RecommendationService.dart';
import 'package:form_validator/form_validator.dart';


class ActionPlanForm extends StatefulWidget {
  final Inspection inspection;
  final Recommendation recommendation;
  const ActionPlanForm ({Key? key, required this.inspection, required this.recommendation}) : super(key: key);

  @override
  _ActionPlanForm createState() => _ActionPlanForm();

}

class _ActionPlanForm extends State<ActionPlanForm> {
  String? selectedNESValue;
  var _inspectionService = InspectionService();
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var school_id;
  var _description = TextEditingController();
  var _recomService = RecommendationService();
  late List<Recommendation> _recommendationList = <Recommendation>[];
  final  formkey = GlobalKey<FormState>();
  /*getAllRecommendationDetails() async {
    var recommendations = await _recomService.readAllActionPlanByVisitId(widget.inspection.id.toString());
    _recommendationList = <Recommendation>[];
    recommendations.forEach((recommendation) {
      setState(() {
        var recommendationModel = Recommendation();
        recommendationModel.id = recommendation['recommendation_id'];
        recommendationModel.createdAt = recommendation['created_at'];
        recommendationModel.description= recommendation['recommendation_description'];
        recommendationModel.nesCategory = recommendation['category_id'];
        recommendationModel.visitId = recommendation['visit_id'];
        _recommendationList.add(recommendationModel);

      });
    });

  }*/
  String? selectedStartDate;
  String? selectedDueDate;
  String? selectedActivityStatus;
  var _activityName = TextEditingController();
  var _activityBudget = TextEditingController();
  var _statusRemarks =TextEditingController();
  var _actionPlanService = ActionPlanService();
  DateTime startDate = DateTime.now();
  DateTime dueDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor, // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Colors.black, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.red, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: startDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != startDate) {
      setState(() {
        selectedStartDate = picked.toString();
        startDate = picked;

      });
    }
  }
  Future<void> _nextInspectionDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: kPrimaryColor, // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Colors.black, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  primary: Colors.red, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: dueDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != dueDate) {
      setState(() {
        selectedDueDate = picked.toString();
        dueDate = picked;
      });
    }
  }
  @override
  void initState() {
    //getAllRecommendationDetails();
    selectedActivityStatus = "0";
    selectedStartDate = currentDate;
    selectedDueDate = currentDate;
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
  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(message),
      ),
    );
  }

  final _key = GlobalKey<FormFieldState>();
  final _keyStart = GlobalKey<FormFieldState>();
  final _keyDue = GlobalKey<FormFieldState>();
  List<DropdownMenuItem<String>> get activity_statuses{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("0%"),value: "0"),
      DropdownMenuItem(child: Text("25%"),value: "1"),
      DropdownMenuItem(child: Text("50%"),value: "2"),
      DropdownMenuItem(child: Text("75%"),value: "3"),
      DropdownMenuItem(child: Text("100%"),value: "4")
    ];
    return menuItems;
  }
  List<DropdownMenuItem<String>> get priority_level{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("25%"),value: "1"),
      DropdownMenuItem(child: Text("50%"),value: "2"),
      DropdownMenuItem(child: Text("75%"),value: "3"),
      DropdownMenuItem(child: Text("100%"),value: "4")
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text('Action Plan Form'),
            centerTitle: true,
            backgroundColor: kPrimaryColor,),

    body: SingleChildScrollView(
    child: Container(
    padding: const EdgeInsets.all(16.0),
    child: Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formkey,
    child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Activity Name';
                    }
                    return null;
                  },
                  maxLines: 4,
                  controller: _activityName,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Activity name',
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Row(
                  children: [
                    Expanded(child: TextFormField(
                      key: _keyStart,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Start Date",
                        border: OutlineInputBorder(),
                      ),
                      onTap: (){
                        _selectDate(context);
                      },
                      controller: TextEditingController(text: startDate.toLocal().toString().split(' ')[0]),

                    ),),
                    SizedBox(
                      width: 25.0,
                    ),
                    Expanded(child: TextFormField(
                      key: _keyDue,
                      readOnly: true,
                      controller: TextEditingController(text: dueDate.toLocal().toString().split(' ')[0]),
                      decoration: InputDecoration(
                        labelText: "Due Date",
                        border: OutlineInputBorder(),
                      ),
                      onTap: (){
                        _nextInspectionDate(context);
                      },

                    ),),
                  ],
                ),
                SizedBox(
                  height: 25.0,
                ),
                Row(
                  children: [

                    Expanded(child: DropdownButtonFormField(
                        key: _key,
                        decoration: InputDecoration(
                          labelText: 'Progress',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        value: "0",
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedActivityStatus = newValue;
                          });
                        },
                        items: activity_statuses),),],),
                SizedBox(
                  height: 25.0,
                ),
                TextFormField(
                validator: (value) {
                },
                  controller: _activityBudget,
                  decoration: InputDecoration(
                    labelText: "Activity Budget",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                  TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]')),
                  ],
                ),
                SizedBox(
                  height: 25.0,
                ),
                TextField(
                  maxLines: 4,
                  controller: _statusRemarks,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Remarks',
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.teal,
                            textStyle: const TextStyle(fontSize: 15)),
                        child: const Text('Submit'),
                        onPressed: () async {

                          if (formkey.currentState!.validate()) {
                            var _actionPlan = ActionPlanModel();
                            var inspection = InspectionUp();
                            _actionPlan.activityName = _activityName.text;
                            _actionPlan.activityBudget = _activityBudget.text;
                            _actionPlan.statusRemarks = _statusRemarks.text;
                            _actionPlan.activityStartDate = selectedStartDate;
                            _actionPlan.activityFinishDate = selectedDueDate;
                            _actionPlan.activityStatus = selectedActivityStatus;
                            _actionPlan.recommendationId =
                                widget.recommendation.id.toString();
                            _actionPlan.visitId =
                                widget.inspection.id.toString();
                            _actionPlan.createdAt = currentDate.toString();

                            var result = await _actionPlanService
                                .SaveActionPlan(_actionPlan);
                            inspection.id = widget.inspection.id;
                            inspection.sync = '1';
                            var result2 = await _inspectionService.UpdateInsp(inspection);
                            Navigator.pop(context, result);
                          }
                        }
                    ),
                    const SizedBox(
                      width: 25.0,
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(fontSize: 15)),
                        onPressed: () {
                         _activityName.text='';
                         _activityBudget.text = '';
                         _statusRemarks.text = '';
                         _description.text ='';
                         _key.currentState?.reset();
                         setState(() {
                           selectedDueDate = currentDate;
                           selectedStartDate = currentDate;
                           dueDate = DateTime.now();
                           startDate = DateTime.now();
                         });

                        },
                        child: const Text('Clear Details')),
                  ],
                ),
              ],
            ),
    )
    ),

          ),
        );


  }
}



