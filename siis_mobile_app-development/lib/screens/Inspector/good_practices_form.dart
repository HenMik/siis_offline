import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:siis_offline/screens/Inspector/control_panel.dart';
import '../../components/AppDrawer.dart';
import '../../constants.dart';
import 'inspection_form.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:siis_offline/screens/Inspector/key_evidence.dart';
import 'package:siis_offline/screens/Inspector/user.dart';
import '../../constants.dart';


class PracticeForm extends StatefulWidget {
  const PracticeForm ({Key? key}) : super(key: key);

  @override
  _PracticeForm createState() => _PracticeForm();

}

class _PracticeForm extends State<PracticeForm> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        home: Scaffold(
            appBar: AppBar(
              title: Text('GOOD PRACTICE'),
              centerTitle: true,
              backgroundColor: kPrimaryColor,
              leading: Builder(
                builder: (BuildContext appBarContext) {
                  return IconButton(
                      onPressed: () {
                        AppDrawer.of(appBarContext)?.toggle();
                      },
                      icon: Icon(Icons.menu_rounded)
                  );
                },
              ),
            ),
            body: Center(

                child: ListView(     children: [

                  Container(
                    padding: EdgeInsets.all(14),
                    child: Text(
                        "GOOD PRACTICE ADDITION FORM",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold )
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter Description',
                          ),
                        ),
                      ),
                      Container(
                        padding:const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,),
                          onPressed: () {


                          },
                          icon: Icon( // <-- Icon
                            Icons.add,
                            size: 24.0,
                          ),
                          label: Text('Submit'), // <-- Text
                        ),
                      ),

                    ],
                  ),

                ])
            )
        ));

  }
}

