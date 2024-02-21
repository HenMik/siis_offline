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
import 'levels_achieved.dart';

class LevelAchieved extends StatefulWidget {
  const LevelAchieved ({Key? key}) : super(key: key);

  @override
  _LevelAchieved createState() => _LevelAchieved();

}

class _LevelAchieved extends State<LevelAchieved> {
  final DataTableSource _data = MyData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        home: Scaffold(
         appBar: AppBar(
        title: Text('Level Achieved Management'),
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
                        'Nes Level Achievements',
                        style: TextStyle(fontSize: 14, color: Colors.grey)
                    ),
                  ],

                ),

              ),
              Container(
                padding: EdgeInsets.all(14),
                child: Text(
                    "Level Achieved Management",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold )
                ),
              ),


              Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Divider(
                      color: Colors.grey
                  )
              ),

              Column(
                children: [
                  PaginatedDataTable(
                    source: _data,
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('NES')),
                      DataColumn(label: Text('Level Achieved')),
                    ],

                  )
                ],
              ),
            ],

          ),

        ),
        )
    );

  }
}
class MyData extends  DataTableSource{

  final List<Map<String, dynamic>> _data = List.generate(
      20,
          (index) => {
        "id": index,
        "title": "Item $index",

      });

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_data[index]['id'].toString())),
      DataCell(Text(_data[index]['NES'].toString())),
      DataCell(Text(_data[index]["Level Achieved"].toString())),
    ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _data.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;

}
