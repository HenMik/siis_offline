import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/AppDrawer.dart';
import '../../components/background.dart';
import '../../constants.dart';

class PerfomanceReports extends StatefulWidget {
  const PerfomanceReports({Key? key, required this.appBar}) : super(key: key);
  final AppBar appBar;
  @override
  _PerfomanceReportState createState() => _PerfomanceReportState();

}

class _PerfomanceReportState extends State<PerfomanceReports> {

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
