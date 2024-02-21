import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/constants.dart';
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
import 'package:siis_offline/utils/app_sync.dart';
import 'package:siis_offline/utils/base_api.dart';

import '../models/Inspection.dart';
import '../models/actionPlan.dart';
import '../models/follow-up_model.dart';
import '../models/zone.dart';

class ManualSync extends StatefulWidget {
  const ManualSync({ key}) : super(key: key);

  @override
  _ManualSyncState createState() => _ManualSyncState();
}

class _ManualSyncState extends State<ManualSync> {
  bool isSynced = false;

  @override
  void initState() {
    super.initState();
    syncData();
  }

  @override
  Widget build(BuildContext context) => (
      Center(
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
              SizedBox(height: 10),
              DefaultTextStyle(style: TextStyle(fontSize: 20, color: Colors.black),
              child: Text('Syncing...')),
              SizedBox(height: 10),
            ],
          ),),
        )

  );

  void syncData() async {
    try {
      String? token = context.read<AccountProvider>().token;
      Map<String, String> headers = BaseApi.headers;
      headers.addAll({"Authorization": "Bearer $token"});
      await InspectorModelProvider().truncate();
      // await InspectorModelProvider().sync(headers);

      await KeyEvidenceModelProvider().truncate();
      // await KeyEvidenceModelProvider().sync(headers);

      await MajorStrengthProvider().truncate();
      // await MajorStrengthProvider().sync(headers);

      await WeaknessProvider().truncate();
      // await WeaknessProvider().sync(headers);

      await CriticalIssuesProvider().truncate();
      // await CriticalIssuesProvider().sync(headers);

      await GoodPracticeProvider().truncate();
      // await GoodPracticeProvider().sync(headers);

      await NesCategoryProvider().truncate();
      // await NesCategoryProvider().sync(headers);

      await NesLevelProvider().truncate();
      // await NesLevelProvider().sync(headers);

      await NesRequirementProvider().truncate();
      // await NesRequirementProvider().sync(headers);

      await FollowUpModelProvider().truncate();
      // await FollowUpModelProvider().sync(headers);

      await RequirementsCountProvider().truncate();
      // await RequirementsCountProvider().sync(headers);

      await RecommendationModelProvider().truncate();
      // await RecommendationModelProvider().sync(headers);

      await RecommendationMinorModelProvider().truncate();
      // await RecommendationMinorModelProvider().sync(headers);

      await ActionPlanProvider().truncate();
      // await ActionPlanProvider().sync(headers);
      setState(() {
        isSynced = true;
        Timer(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const AppSync();
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
