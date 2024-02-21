
import 'package:flutter/material.dart';
import 'package:siis_offline/components/AppDrawer.dart';
import 'package:siis_offline/constants.dart';
import 'package:siis_offline/screens/Inspector/dashboard.dart';
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {

    AppBar appBar = AppBar(
      title: Text('SIIS'),
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
    );

    return Scaffold(
      body: AppDrawer(
         child: Dashboard(appBar: appBar),
      ),
    );




  }

}
