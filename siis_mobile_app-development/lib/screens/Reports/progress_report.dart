import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/AppDrawer.dart';
import '../../components/background.dart';
import '../../constants.dart';

class ProgressReport extends StatefulWidget {
  const ProgressReport({Key? key, required this.appBar}) : super(key: key);
  final AppBar appBar;
  @override
  _ProgressReportState createState() => _ProgressReportState();

}

class _ProgressReportState extends State<ProgressReport> {

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
