import 'dart:async';
import 'dart:convert';

import 'package:dart_date/dart_date.dart';
import 'package:flutter/src/animation/curves.dart' as curve;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:siis_offline/screens/Inspector/edit_inspection.dart';
import 'package:siis_offline/screens/Inspector/search.dart';
import 'package:siis_offline/screens/Inspector/view_inspection.dart';
import 'package:siis_offline/utils/manual_sync.dart';
import 'dart:math' as math;

import '../../components/AppDrawer.dart';
import '../../constants.dart';
import '../../models/Inspection.dart';
import '../../models/critical_issues.dart';
import '../../models/good_practices.dart';
import '../../models/inspector_model.dart';
import '../../models/key_evidence_model.dart';
import '../../models/major_strengths.dart';
import '../../models/recommendations_model.dart';
import '../../models/user.dart';
import '../../models/weaknesses.dart';
import '../../services/InspectionService.dart';
import '../../utils/account_provider.dart';
import '../../utils/base_api.dart';
import '../other_settings/server_sync.dart';
import '../other_settings/server_sync_to.dart';
import 'inspection_form.dart';

class SchoolVisits extends StatefulWidget {
  const SchoolVisits({Key? key}) : super(key: key);
  @override
  _SchoolVisitState createState() => _SchoolVisitState();
}

class _SchoolVisitState extends State<SchoolVisits> {
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('Full Inspection');
  late List<Inspection> _inspectionList = <Inspection>[];
  List<Inspection> currentInspectionList = <Inspection>[];
  final _inspectionService = InspectionService();

  void _showAction(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Are you sure you want to sync data to server?'),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white, // foreground
                    backgroundColor: Colors.green),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  AppDrawer(
                        child: ServerSyncTo(),
                      ),
                    ),
                  );
                },
                child: const Text('Sync')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  void _showActionFrom(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Are you sure you want to sync data from server?'),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white, // foreground
                    backgroundColor: Colors.green),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  AppDrawer(
                        child: ManualSync(),
                      ),
                    ),
                  );
                },
                child: const Text('Sync')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  void _showActionBoth(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Are you sure you want to sync data both to server and from server?'),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white, // foreground
                    backgroundColor: Colors.green),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  AppDrawer(
                        child: ServerSync(),
                      ),
                    ),
                  );
                },
                child: const Text('Sync')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(message),
      ),
    );
  }

  String? schools;
  int page = 1;
  int pageCount = 10;
  int startAt = 0;
  late int endAt;
  int totalPages = 0;
  List<GlobalKey<TooltipState>> tooltipkey = [];

  _deleteFormDialog(BuildContext context, inspectionId) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: const Text(
              'Are You Sure to Delete this Inpection?',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.red),
                  onPressed: () async {
                    var result =
                    await _inspectionService.deleteInspection(inspectionId);
                    if (result != null) {
                      Navigator.of(context, rootNavigator: true).pop();
                      setState(() {
                        getAllInspectionDetails();
                      });
                      _showSuccessSnackBar('Inspection Deleted Successfully');
                    }
                  },
                  child: const Text('Delete')),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }
  void syncDataToDB() async {
    String? token = context.read<AccountProvider>().token;
    Map<String, String> headers = BaseApi.headers;
    headers.addAll({"Authorization": "Bearer $token"});

    var inspections = await InspectorModelProvider().getToSync();
    if (inspections == null) {

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
          setState(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (body) =>  AppDrawer(
                  child: SchoolVisits( ),
                ),
              ),
            );
          });
        } else {
          if(inspectionResponse.statusCode == 406){
            //visit already exists
            var visit = jsonDecode(inspectionResponse.body);
            var onlineVisitId = visit['data'][0]['visit_id'];
            var offlineVisitId = element.visitId.toString();
            var path = BaseApi.schoolVisitPath;
            Response resp = await patch(Uri.parse("$path/update/$onlineVisitId"), headers: headers, body: jsonEncode(element));

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


          }
        }
      });
    } catch (e) {
      print(e);
    }
  }
  getAllInspectionDetails() async {
    var user = context
        .read<AccountProvider>()
        .user;
    var inspections =
    await _inspectionService.readAllInspections(user!['sector_id'].toString());
    _inspectionList = <Inspection>[];
    inspections.forEach((inspection) {
      setState(() {
        var inspectionModel = Inspection();
        inspectionModel.id = inspection['visit_id'];
        inspectionModel.divisionId = inspection['division_id'];
        inspectionModel.districtId = inspection['district_id'];
        inspectionModel.districtName = inspection['district_name'];
        inspectionModel.divisionName = inspection['division_name'];
        inspectionModel.clusterName = inspection['zone_name'];
        inspectionModel.actionPlanDate = inspection['action_plan_date'];
        inspectionModel.visitType = inspection['visit_type_id'];
        inspectionModel.nextInspectionDate = inspection['next_inspection_date'];
        inspectionModel.schoolName = inspection['school_name'];
        inspectionModel.emisId = inspection['emis_id'];
        inspectionModel.postAddress = inspection['school_address'];
        inspectionModel.headTeacher = inspection['head_teacher'];
        inspectionModel.headPhonenumber = inspection['phone_number'];
        inspectionModel.nofqTeachers = inspection['number_of_teachers'];
        inspectionModel.noufqTeachers = inspection['unqualified_teachers'];
        inspectionModel.totalEnrolledBoys = inspection['enrolment_boys'];
        inspectionModel.totalAttendanceBoys = inspection['attendance_boys'];
        inspectionModel.totalEnrolledGirls = inspection['enrolment_girls'];
        inspectionModel.totalAttendanceGirls = inspection['attendance_girls'];
        inspectionModel.advisor = inspection['lead_advisor_id'];
        inspectionModel.schoolGovernanceChair = inspection['govt_chair_id'];
        inspectionModel.presentVisitationDate = inspection['present_visitation_date'];
        inspectionModel.previousVisitationDate = inspection['prev_visitation_date'];
        inspectionModel.yearOfEstablishment = inspection['establishment_year'];
        inspectionModel.leadInspectorName = inspection['lead_inspector_id'];
        inspectionModel.firstInspectorName = inspection['first_inspector_id'];
        inspectionModel.secondInspectorName = inspection['second_inspector_id'];
        inspectionModel.actionPlanDate = inspection['action_plan_date'];
        inspectionModel.nextInspectionDate = inspection['next_inspection_date'];
        inspectionModel.thirdInspectorName = inspection['third_inspector_id'];
        inspectionModel.fourthInspectorName = inspection['fourth_inspector_id'];
        inspectionModel.establishment = inspection['establishment'];
        inspectionModel.sync = inspection['sync'];
        _inspectionList.add(inspectionModel);

        _isLoading = false;
      });
    });


    if (_inspectionList.length <= 10) {

    }
    else {
      endAt = startAt + pageCount;
      totalPages = (_inspectionList.length / pageCount).floor();
      if (_inspectionList.length / pageCount > totalPages) {
        totalPages = totalPages + 1;
      }

      currentInspectionList = _inspectionList.getRange(startAt, endAt).toList();
    }
  }


  late bool _isLoading = true;
  late bool _viewAddInspectionButton = true;

  @override
  void initState() {
    try {
      Timer.periodic(Duration(seconds: 30), (Timer t) => syncDataToDB());
    }catch(e){

    }
    var user = context
        .read<AccountProvider>()
        .user;
    if (user!['user_role'] == 'Secondary Advisor') {
      _viewAddInspectionButton = false;
    }
    getAllInspectionDetails();
    super.initState();
  }

  List<Inspection> inspectionSearched = [];

  Finder(String qry) {
    qry = qry.toLowerCase();
    setState(() {
      inspectionSearched = _inspectionList.where((element) =>
      element.schoolName.toLowerCase().contains(qry)
          || element.headTeacher.toLowerCase().contains(qry)
          || element.leadInspectorName.toLowerCase().contains(qry)
          || element.advisor.toLowerCase().contains(qry)
          || element.divisionName.toLowerCase().contains(qry)
          || element.districtName.toLowerCase().contains(qry)
          || element.clusterName.toLowerCase().contains(qry)
          || element.presentVisitationDate.toLowerCase().contains(qry)
      ).toList();
    });
  }


  var _searchController = TextEditingController();

  void loadPreviousPage() {
    if (page > 1) {
      setState(() {
        startAt = startAt - pageCount;
        endAt = page == totalPages
            ? endAt - currentInspectionList.length
            : endAt - pageCount;
        currentInspectionList =
            _inspectionList.getRange(startAt, endAt).toList();
        page = page - 1;
      });
    }
  }

  void loadNextPage() {
    if (page < totalPages) {
      setState(() {
        startAt = startAt + pageCount;
        endAt = _inspectionList.length > endAt + pageCount
            ? endAt + pageCount
            : _inspectionList.length;
        currentInspectionList =
            _inspectionList.getRange(startAt, endAt).toList();
        page = page + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        backgroundColor: kPrimaryColor,
        leading: Builder(
          builder: (BuildContext appBarContext) {
            return IconButton(
                onPressed: () {
                  AppDrawer.of(appBarContext)?.toggle();
                },
                icon: Icon(Icons.menu_rounded));
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (customIcon.icon == Icons.search) {
                setState(() {
                  customIcon = const Icon(Icons.cancel);
                  customSearchBar = ListTile(
                    leading: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    title: TextField(
                      controller: _searchController,
                      onEditingComplete: () {
                        Finder(_searchController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return Search(inspection: inspectionSearched);
                            },
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                });
              } else {
                setState(() {
                  customIcon = const Icon(Icons.search);
                  customSearchBar = const Text('Full Inspection');
                });
              }
            },
            icon: customIcon,
          )
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () {
            return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (body) =>  AppDrawer(
                child: SchoolVisits( ),
              ),
            ),
          ); },
          child: Center(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: <Widget>[
                  Text('Home',
                      style: TextStyle(
                        fontSize: 15,
                      )),
                  Icon(Icons.arrow_right),
                  Text('Inspection Visit',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text("School Inspection's Management",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            _viewAddInspectionButton ? Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Hero(
                    tag: "new_inspection_btn",
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InspectionForm()))
                            .then((data) {
                          if (data != null) {
                            getAllInspectionDetails();
                            _showSuccessSnackBar(
                                'Inspection Added Successfully');
                          }
                        });
                      },
                      icon: Icon(
                        // <-- Icon
                        Icons.add,
                        size: 24.0,
                      ),
                      label: Text('New Inspection Visit'), // <-- Text
                    ),
                  ),
                ),
              ],
            ) : Container(),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Divider(color: Colors.grey)),
            _isLoading
                ? Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.white,
              child: ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //padding: new EdgeInsets.all(4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 15),
                            Container(
                              height: 45,
                              width: 45,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 5),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(2)),
                                        color: Colors.grey,
                                      ),
                                      height: 18,
                                      child: Row(),
                                    ),
                                    SizedBox(height: 7),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.all(
                                                    Radius.circular(2)),
                                                color: Colors.grey,
                                              ),
                                              height: 18,
                                              child: Row(),
                                            )),
                                        Expanded(
                                            child: Container(
                                              height: 18,
                                            )),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  }),
            )
                : ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: currentInspectionList.length,
                itemBuilder: (context, index) {
                  var user = context
                      .read<AccountProvider>()
                      .user;
                  var date = DateTime.parse(currentInspectionList[index].presentVisitationDate);
                  DateFormat formatter = DateFormat('dd/MM/yyyy');
                  final String formatted = formatter.format(date);
                  var expiry = DateTime(date.year, date.month, date.day + 15);
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewInspection(
                                      inspection:
                                      currentInspectionList[index],
                                    )));
                      },
                      leading: const Icon(Icons.list_alt_rounded),
                      title: Text(
                          "${currentInspectionList[index]
                              .schoolName} Inspection Visit" ??
                              ''),
                      subtitle: Text(formatted.split(' ')[0] ??
                          ''),
                      trailing:
                      _viewAddInspectionButton ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          ((user!['user_id'] == currentInspectionList[index].leadInspectorName
                              || user!['user_id'] == currentInspectionList[index].firstInspectorName
                              || user!['user_id'] == currentInspectionList[index].secondInspectorName
                              || user!['user_id'] == currentInspectionList[index].thirdInspectorName
                              || user!['user_id'] == currentInspectionList[index].fourthInspectorName) && expiry >= DateTime.now())?
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditInspection(
                                                    inspection:
                                                    currentInspectionList[
                                                    index],
                                                  ))).then((data) {
                                        if (data != null) {
                                          getAllInspectionDetails();
                                          _showSuccessSnackBar(
                                              'Inspection Updated Successfully');
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.teal,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      _deleteFormDialog(context,
                                          currentInspectionList[index].id);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )),
                              ],
                            ):Text(''),


                          if(currentInspectionList[index].sync == '1' ||
                              currentInspectionList[index].sync == '3')
                            Tooltip(
                              triggerMode: TooltipTriggerMode.tap,
                              showDuration: const Duration(seconds: 2),
                              message: 'This inspection is offline',
                              child: Image.asset(
                                "assets/images/offline.jpg", width: 43,),),
                          if(currentInspectionList[index].sync != '1' &&
                              currentInspectionList[index].sync != '3')
                            Container(),
                        ],
                      ) : (currentInspectionList[index].sync == '1' ||
                          currentInspectionList[index].sync == '3') ?
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        showDuration: const Duration(seconds: 2),
                        message: 'This inspection is offline',
                        child: Image.asset(
                          "assets/images/offline.jpg", width: 43,),) :
                      Text('')
                    ),
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: page > 1 ? loadPreviousPage : null,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 35,
                  ),
                ),
                Text("$page / $totalPages"),
                IconButton(
                  onPressed: page < totalPages ? loadNextPage : null,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 35,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),),
      floatingActionButton:  Padding(
    padding: const EdgeInsets.only(bottom: 50.0),
    child: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () => _showAction(context),
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
          ActionButton(
            onPressed: () => _showActionFrom(context),
            icon: const Icon(Icons.cloud_download_outlined),
          ),
          ActionButton(
            onPressed: () => _showActionBoth(context),
            icon: const Icon(Icons.sync_alt),
          ),
        ],
      ),
      ),
    );

  }
}
@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
  super.key,
  this.initialOpen,
  required this.distance,
  required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
    i < count;
    i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const curve.Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const curve.Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed: _toggle,
            child: const Icon(Icons.sync),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
  super.key,
  this.onPressed,
  required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.secondary,
      elevation: 4.0,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.colorScheme.onSecondary,
      ),
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
  super.key,
  required this.isBig,
  });

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      height: isBig ? 128.0 : 36.0,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: Colors.grey.shade300,
      ),
    );

  }

}
