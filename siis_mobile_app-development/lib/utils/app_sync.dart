import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/constants.dart';
import 'package:siis_offline/models/actionPlan.dart';
import 'package:siis_offline/models/critical_issues.dart';
import 'package:siis_offline/models/district.dart';
import 'package:siis_offline/models/division.dart';
import 'package:siis_offline/models/good_practices.dart';
import 'package:siis_offline/models/inspector_model.dart';
import 'package:siis_offline/models/key_evidence_model.dart';
import 'package:siis_offline/models/major_strengths.dart';
import 'package:siis_offline/models/national_standards.dart';
import 'package:siis_offline/models/nes_category.dart';
import 'package:siis_offline/models/nes_levels.dart';
import 'package:siis_offline/models/nes_requirements.dart';
import 'package:siis_offline/models/recommendations_model.dart';
import 'package:siis_offline/models/recommendations_model_minor.dart';
import 'package:siis_offline/models/requirements_count.dart';
import 'package:siis_offline/models/school.dart';
import 'package:siis_offline/models/user.dart';
import 'package:siis_offline/models/weaknesses.dart';
import 'package:siis_offline/screens/Inspector/home.dart';
import 'package:siis_offline/screens/commons/something_went_wrong.dart';
import 'package:siis_offline/utils/account_provider.dart';
import 'package:siis_offline/utils/base_api.dart';

import '../models/Inspection.dart';
import '../models/follow-up_model.dart';
import '../models/zone.dart';

class AppSync extends StatefulWidget {
  const AppSync({ key}) : super(key: key);

  @override
  _AppSyncState createState() => _AppSyncState();
}

class _AppSyncState extends State<AppSync> {
  bool isSynced = false;
  var sync_data = "National Standards";
  var _progressValue = 0.0;
  @override
  void initState() {
    super.initState();
    syncData();
  }

  @override
  Widget build(BuildContext context) => (

      !isSynced
      ? Center(
          child: Container(
            color: kPrimaryColor2,
          padding: EdgeInsets.all(50),
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/sync.gif",

              ),
              SizedBox(height: 40),
              DefaultTextStyle(style: TextStyle(fontSize: 16, color: Colors.black),
              child: Text('Syncing ${sync_data}...')),
              SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 25,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.teal[50],
                    ),

                    child: Row(
                      children: [Container(
                      height: 25,
                      width: _progressValue * 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.teal,
                        ),
                      child: Center(
                        child: DefaultTextStyle(style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                            child: Text('${(_progressValue).round()}%'),),
                      ),
                    ),],),
                  ),

                ],
              )
            ],
          ),),
        )
      : Center(
       child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/checkb.gif")
        ],
      ),
       ),

  )
  );

  void syncData() async {
    try {
      String? token = context.read<AccountProvider>().token;
      Map<String, String> headers = BaseApi.headers;
      headers.addAll({"Authorization": "Bearer $token"});

      await NationalStandardProvider().sync(headers);
      setState(() {
        _progressValue = 4.0;
        sync_data = "Districts";
      });
      await DistrictProvider().sync(headers);
      setState(() {
        _progressValue = 8.0;
        sync_data = "Divisions";
      });
      await DivisionProvider().sync(headers);
      setState(() {
        _progressValue = 12.0;
        sync_data = "NES Categories";
      });
      await NesCategoryProvider().sync(headers);
      setState(() {
        _progressValue = 16.0;
        sync_data = "NES Levels";
      });
      await NesLevelProvider().sync(headers);
      setState(() {
        _progressValue = 20.0;
        sync_data = "NES Requirements";
      });
      await NesRequirementProvider().sync(headers);
      setState(() {
        _progressValue = 25.0;
        sync_data = "Schools";
      });
      await SchoolProvider().sync(headers);
      setState(() {
        _progressValue = 29.0;
        sync_data = "Users";
      });
      await UserProvider().sync(headers);
      setState(() {
        _progressValue = 34.0;
        sync_data = "School Visits";
      });
      await InspectorModelProvider().sync(headers);
      setState(() {
        _progressValue = 38.0;
        sync_data = "Follow Up Visits";
      });
      await FollowUpModelProvider().sync(headers);
      setState(() {
        _progressValue = 42.0;
        sync_data = "Key Evidences";
      });
      await KeyEvidenceModelProvider().sync(headers);
      setState(() {
        _progressValue = 46.0;
        sync_data = "Major Strengths";
      });
      await MajorStrengthProvider().sync(headers);
      setState(() {
        _progressValue = 50.0;
        sync_data = "Weaknesses";
      });
      await WeaknessProvider().sync(headers);
      setState(() {
        _progressValue = 57.0;
        sync_data = "Good Practices";
      });
      await GoodPracticeProvider().sync(headers);
      setState(() {
        _progressValue = 63.0;
        sync_data = "Critical Issues";
      });
      await CriticalIssuesProvider().sync(headers);
      setState(() {
        _progressValue = 67.0;
        sync_data = "Zones";
      });
      await ZoneProvider().sync(headers);
      setState(() {
        _progressValue = 72.0;
        sync_data = "Requirement Counts";
      });
      await RequirementsCountProvider().sync(headers);
      setState(() {
        _progressValue = 76.0;
        sync_data = "Key Evidences";
      });
      await KeyEvidenceModelProvider().sync(headers);
      setState(() {
        _progressValue = 80.0;
        sync_data = "Major Recommendations";
      });
      await RecommendationModelProvider().sync(headers);
      setState(() {
        _progressValue = 89.0;
        sync_data = "Minor Recommendations";
      });
      await RecommendationMinorModelProvider().sync(headers);
      setState(() {
        _progressValue = 96.0;
        sync_data = "Action Plans";
      });
      await ActionPlanProvider().sync(headers);
      setState(() {
        _progressValue = 99.0;
      });
      setState(() {
        isSynced = true;
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return Home();
              },
            ),
          );
        });

      });
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return SomethingWrongScreen();
          },
        ),
      );
    }
  }
}
