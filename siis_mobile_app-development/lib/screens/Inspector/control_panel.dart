import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:siis_offline/screens/Inspector/areas_of_improvement/areas_of_improvement.dart';
import 'package:siis_offline/screens/Inspector/critical_issues/critical_issues.dart';
import 'package:siis_offline/screens/Inspector/good_practices/good_practices.dart';
import 'package:siis_offline/screens/Inspector/major_strengths/major_strengths.dart';
import 'package:siis_offline/screens/Inspector/key_evidence.dart';
import 'package:siis_offline/screens/Inspector/school_visit_report.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import 'Major_Recommendations.dart';

class ControlPanel extends StatefulWidget {
  final Inspection inspection;
  const ControlPanel({Key? key, required this.inspection}) : super(key: key);
  @override
  _ControlPanelState createState() => _ControlPanelState();

}

class _ControlPanelState extends State<ControlPanel> {

  var schoolName;
  var choices;
  @override
  void initState() {
    setState(() {
      choices = <Choice>[

      Choice(title: 'Key Evidence', icon: Icons.vpn_key_sharp, color: Colors.deepPurpleAccent, name: KeyEvidence(inspection: widget.inspection)),
      Choice(title: 'Major Strengths', icon: Icons.thumb_up, color: Colors.green,name: MajorStrength(inspection: widget.inspection)),
      Choice(title: 'Areas of Improvement', icon: Icons.hourglass_full, color: Colors.red,name: AreaOfImprovement(inspection: widget.inspection)),
      Choice(title: 'Good Practices', icon: Icons.check, color: Colors.green,name: GoodPractices(inspection: widget.inspection)),
      Choice(title: 'Critical Issues', icon: Icons.warning_rounded, color: Colors.orangeAccent,name: CriticalIssues(inspection: widget.inspection)),
      Choice(title: 'Major Recommendations', icon: Icons.comment_bank_sharp, color: Colors.deepPurpleAccent,name: Recommendations(inspection: widget.inspection)),
      Choice(title: 'School Visit Report', icon: Icons.bar_chart, color: Colors.deepPurpleAccent,name: SchoolVisitReport(inspection: widget.inspection)),
    ];

      schoolName = widget.inspection.schoolName;
    });
    super.initState();
    }



  AppBar appBar = AppBar(
  title: Text('Control panel'),
  centerTitle: true,
  backgroundColor: kPrimaryColor,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
        body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children:<Widget>[
                  Text(
                      'Home',
                      style: TextStyle(fontSize: 15, )
                  ),
                  Icon(Icons.arrow_right),
                  Text(
                      'Inspection Panel Options',
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                  ),
                ],

              ),

            ),
            Text(
                'CONTROL PANEL FOR ${schoolName}',
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Divider(
                    color: Colors.grey
                )
            ),
            Expanded(child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 8.0,
              children: List.generate(choices.length, (index) {
                return Center(
                  child: SelectCard(choice: choices[index]),
                );
              }
              ),
            ),),
          ],
        ),
        ),
    );
  }
}
class Choice {
  const Choice({required this.title, required this.icon, required this.color, required this.name});
  final String title;
  final IconData icon;
  final Color color;
  final Widget name;
}


class SelectCard extends StatelessWidget {
  const SelectCard({Key? key, required this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {

    return
     GestureDetector(
       onTap: (){ Navigator.push(
           context,
           MaterialPageRoute(
               builder: (context) => choice.name));},
       child: Card(
      elevation: 4,
        child: GestureDetector(
          onTap: (){Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return choice.name;
              },
            ),
          );},
        child: Center(child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Icon(choice.icon, size:50.0, color: choice.color)),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: kGreyLightColor,
                  child: Center(child: Text(choice.title, style: TextStyle(
                fontSize: 15,

              ),))),

            ]
        ),),
        ),
        )
    );
  }
}