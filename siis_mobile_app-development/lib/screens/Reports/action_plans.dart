import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/AppDrawer.dart';
import '../../components/background.dart';
import '../../constants.dart';

class ActionPlans extends StatefulWidget {
  const ActionPlans({Key? key, required this.appBar}) : super(key: key);
  final AppBar appBar;
  @override
  _ActionPlanState createState() => _ActionPlanState();

}

class _ActionPlanState extends State<ActionPlans> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Center(
        child: ListView(
        ),
      ),
    );
  }
}
