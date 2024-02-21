import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/models/actionPlan.dart';
import 'package:siis_offline/models/critical_issues.dart';
import 'package:siis_offline/models/good_practices.dart';
import 'package:siis_offline/models/key_evidence_model.dart';
import 'package:siis_offline/models/major_strengths.dart';
import 'package:siis_offline/screens/commons/something_went_wrong.dart';
import 'package:siis_offline/utils/manual_sync.dart';
import '../../components/AppDrawer.dart';
import '../../models/inspector_model.dart';
import '../../models/recommendations_model.dart';
import '../../models/weaknesses.dart';
import '../../utils/account_provider.dart';
import '../../utils/base_api.dart';
import '../Inspector/home.dart';
import '../Inspector/school_visits.dart';

class ServerSyncTo extends StatefulWidget {
  const ServerSyncTo({Key? key}) : super(key: key);


  @override
  State<ServerSyncTo> createState() => _ServerSyncState();
}

class _ServerSyncState extends State<ServerSyncTo> {
  @override
  void initState() {
    super.initState();
    syncDataToDB();
  }
  bool isSynced = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isSynced
          ?Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/syncing.gif",
              scale: 2,
            ),
            const SizedBox(height: 10),
            const Text('Syncing To SIIS')
          ],
        )
      ):Center(
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

      ),
    );
  }

  void syncDataToDB() async {
    String? token = context.read<AccountProvider>().token;
    Map<String, String> headers = BaseApi.headers;
    headers.addAll({"Authorization": "Bearer $token"});

    var inspections = await InspectorModelProvider().getToSync();
    if (inspections == null) {
      isSynced = true;
      Timer(Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  AppDrawer(
              child: SchoolVisits(),
            ),
          ),
        );
      });
    }
    try {
      inspections?.forEach((element) async {
        Response inspectionResponse = await post(Uri.parse(BaseApi.schoolVisitPath),
            headers: headers, body: jsonEncode(element));
        if (inspectionResponse.statusCode < 300) {
          var visit = jsonDecode(inspectionResponse.body);
          var onlineVisitId = visit['data']['visit_id'];
          var offlineVisitId = element.visitId.toString();
          element.sync = 0;
          element.visitId = onlineVisitId;
          InspectorModelProvider().update(element, offlineVisitId);
          await MajorStrengthProvider()
              .syncToServer(offlineVisitId, onlineVisitId, headers);
          await WeaknessProvider()
              .syncToServer(offlineVisitId, onlineVisitId, headers);
          await GoodPracticeProvider()
              .syncToServer(offlineVisitId, onlineVisitId, headers);
          await CriticalIssuesProvider()
              .syncToServer(offlineVisitId, onlineVisitId, headers);
          await RecommendationModelProvider()
              .syncToServer(offlineVisitId, onlineVisitId, headers);
          await KeyEvidenceModelProvider()
              .syncToServer(offlineVisitId, onlineVisitId, headers);
          isSynced = true;
          Timer(Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  AppDrawer(
                  child: SchoolVisits(),
                ),
              ),
            );
          });
        } else {
          if(inspectionResponse.statusCode == 406){
            //visit already exists
            var visit = jsonDecode(inspectionResponse.body);
            var onlineVisitId = visit['data'][0]['visit_id'];
            var offlineVisitId = element.visitId;
            var path = BaseApi.schoolVisitPath;
            Response resp = await patch(Uri.parse("$path/update/$onlineVisitId"), headers: headers, body: jsonEncode(element));
            print(resp.body);
            element.sync = 0;
            InspectorModelProvider().update(element, offlineVisitId);
            await MajorStrengthProvider()
                .syncUpdatesToServer(offlineVisitId, onlineVisitId, headers);
            await WeaknessProvider()
                .syncUpdatesToServer(offlineVisitId, onlineVisitId, headers);
            await GoodPracticeProvider()
                .syncUpdatesToServer(offlineVisitId, onlineVisitId, headers);
            await CriticalIssuesProvider()
                .syncUpdatesToServer(offlineVisitId, onlineVisitId, headers);
            await RecommendationModelProvider()
                .syncUpdatesToServer(offlineVisitId, onlineVisitId, headers);
            await KeyEvidenceModelProvider()
                .syncUpdatesToServer(offlineVisitId, onlineVisitId, headers);
            isSynced = true;
            Timer(Duration(seconds: 1), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  AppDrawer(
                    child: SchoolVisits(),
                  ),
                ),
              );
            });
          }
        }
      });
    } catch (e) {
      print(e);
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
