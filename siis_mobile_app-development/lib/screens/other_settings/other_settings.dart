import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../components/AppDrawer.dart';
import '../../components/background.dart';
import '../../constants.dart';

class OtherSettings extends StatefulWidget {
  const OtherSettings({Key? key, required this.appBar}) : super(key: key);
  final AppBar appBar;
  @override
  _OtherSettingState createState() => _OtherSettingState();

}

class _OtherSettingState extends State<OtherSettings> {

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
