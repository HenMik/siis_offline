import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../components/AppDrawer.dart';
import '../../constants.dart';

class StrengthsForm extends StatefulWidget {
  const StrengthsForm ({Key? key}) : super(key: key);

  @override
  _StrengthsForm createState() => _StrengthsForm();

}

class _StrengthsForm extends State<StrengthsForm> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        home: Scaffold(
          appBar: AppBar(
            title: Text('Strengths Management'),
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
            "Add Major Strength",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold )
        ),
      ),
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
        const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: TextField(
          maxLines: 6,
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

