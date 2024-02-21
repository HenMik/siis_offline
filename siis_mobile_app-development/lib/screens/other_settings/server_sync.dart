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
import '../../models/inspector_model.dart';
import '../../models/recommendations_model.dart';
import '../../models/weaknesses.dart';
import '../../utils/account_provider.dart';
import '../../utils/base_api.dart';
import '../Inspector/home.dart';

class ServerSync extends StatefulWidget {
  const ServerSync({Key? key}) : super(key: key);


  @override
  State<ServerSync> createState() => _ServerSyncState();
}

class _ServerSyncState extends State<ServerSync> {
  @override
  void initState() {
    super.initState();
    syncDataToDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return ManualSync();
          },
        ),
      );
    }
    try {
      inspections?.forEach((InspectorModel element) async {
        Response inspectionResponse = await post(Uri.parse(BaseApi.schoolVisitPath),
            headers: headers, body: jsonEncode(element));
        if (inspectionResponse.statusCode < 300) {
          var visit = jsonDecode(inspectionResponse.body);
          var onlineVisitId = visit['data']['visit_id'];
          var offlineVisitId = element.visitId.toString();
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return ManualSync();
              },
            ),
          );
        } else {
          if(inspectionResponse.statusCode == 406){
            //visit already exists
            var visit = jsonDecode(inspectionResponse.body);
            var onlineVisitId = visit['data']['visit_id'];
            var offlineVisitId = element.visitId.toString();
            var path = BaseApi.schoolVisitPath;
            patch(Uri.parse("$path/update/$onlineVisitId"), headers: headers, body: jsonEncode(element));
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return ManualSync();
                },
              ),
            );
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
