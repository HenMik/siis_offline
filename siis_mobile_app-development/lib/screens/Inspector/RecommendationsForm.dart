import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:siis_offline/constants.dart';

import '../../models/Inspection.dart';
import '../../services/InspectionService.dart';

class RecommendationsForm extends StatefulWidget {
  @override
  _RecommendationsFormState createState() => _RecommendationsFormState();
}

class _RecommendationsFormState extends State<RecommendationsForm> {
  bool hide = false;
  String? selectedNESValue;

  StepperType stepperType = StepperType.horizontal;
  List<DropdownMenuItem<String>> get recommendations{
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("Recommendation"),value: "1"),
      DropdownMenuItem(child: Text("Action Plan"),value: "2"),
    ];
    return menuItems;
  }


  TextEditingController textarea = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: AppBar(
        title: Text('Recommendations Form'),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body:  Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Text(
                  'Add New Recommendation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: kBlackColor)
              ),
            ),
            Row(
              children: [
                Expanded(child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'NES',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    validator: (value) => value == null ? "Select a NES" : null,

                    onChanged: (String? newValue) {
                      setState(() {
                        selectedNESValue = newValue;
                      });
                    },
                    items: recommendations),)
              ],
            ),
            Divider(
                color: Colors.grey
            )
          ],
        ),

      ),

    );
  }


}
