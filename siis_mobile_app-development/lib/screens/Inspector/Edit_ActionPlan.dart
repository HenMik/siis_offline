import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:siis_offline/models/actionPlan.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/recommendation.dart';
import '../../services/ActionPlanService.dart';
import '../../services/RecommendationService.dart';
import 'ActionPlan.dart';

class EditActionPlanForm extends StatefulWidget {

  final Inspection inspection;
  final Recommendation recommendation;
  final ActionPlanModel actionPlan;
  const EditActionPlanForm ({Key? key, required this.inspection, required this.recommendation, required this.actionPlan}) : super(key: key);
  @override
  _EditActionPlanForm createState() => _EditActionPlanForm();

}

class _EditActionPlanForm extends State<EditActionPlanForm> {
  String? selectedNESValue;
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
  var action_plan_id;
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
    action_plan_id= widget.actionPlan.id??'';
   _activityName.text = widget.actionPlan.activityName??'';
    startDate = DateTime.parse(widget.actionPlan.activityStartDate);
    dueDate = DateTime.parse(widget.actionPlan.activityFinishDate);
    selectedStartDate = widget.actionPlan.activityStartDate??'';
    selectedDueDate = widget.actionPlan.activityFinishDate??'';
    selectedActivityStatus= widget.actionPlan.activityStatus??'';
   _activityBudget.text= widget.actionPlan.activityBudget??'';
   _statusRemarks.text = widget.actionPlan.statusRemarks??'';
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
        title: Text('Edit Action'),
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
                      value: selectedActivityStatus,
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
                controller: _activityBudget,
                decoration: InputDecoration(
                  labelText: "Activity Budget",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                TextInputType.numberWithOptions(decimal: false),

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
                          _actionPlan.activityName = _activityName.text;
                          _actionPlan.activityBudget = _activityBudget.text;
                          _actionPlan.statusRemarks = _statusRemarks.text;
                          _actionPlan.activityStartDate =
                              selectedStartDate.toString();
                          _actionPlan.activityFinishDate =
                              selectedDueDate.toString();
                          _actionPlan.activityStatus = selectedActivityStatus;
                          _actionPlan.recommendationId = widget.recommendation
                              .id.toString();
                          _actionPlan.visitId = widget.inspection.id.toString();
                          _actionPlan.createdAt = currentDate.toString();
                          _actionPlan.id = action_plan_id;
                          var result = await _actionPlanService.updateAction(
                              _actionPlan);
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


                        setState(() {
                          selectedActivityStatus = "0";
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
          ),
        ),

      ),
    );


  }
}



