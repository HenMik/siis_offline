import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/AppDrawer.dart';
import '../../components/background.dart';
import '../../constants.dart';

class ExecutiveSummary extends StatefulWidget {
  const ExecutiveSummary({Key? key, required this.appBar}) : super(key: key);
  final AppBar appBar;
  @override
  _ExecutiveSummaryState createState() => _ExecutiveSummaryState();

}

class _ExecutiveSummaryState extends State<ExecutiveSummary> {

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
