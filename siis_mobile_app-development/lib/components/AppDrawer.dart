import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/models/recommendation.dart';
import 'package:siis_offline/screens/Inspector/dashboard.dart';
import 'package:siis_offline/screens/Inspector/follow_up.dart';
import 'package:siis_offline/screens/Inspector/school_visits.dart';
import 'package:siis_offline/screens/Login/splash_page.dart';
import 'package:siis_offline/screens/Reports/action_plans.dart';
import 'package:siis_offline/screens/Reports/executive_summary.dart';
import 'package:siis_offline/screens/Reports/perfomance_reports.dart';
import 'package:siis_offline/screens/other_settings/other_settings.dart';
import 'package:siis_offline/utils/account_provider.dart';

import '../constants.dart';
import '../screens/Inspector/Major_Recommendations_Advisor.dart';
import '../screens/other_settings/server_sync.dart';

class AppDrawer extends StatefulWidget {
  final Widget child;

  AppDrawer({key, required this.child}) : super(key: key);

  static _AppDrawerState? of(BuildContext context) => context.findAncestorStateOfType<_AppDrawerState>();

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  static Duration duration = Duration(milliseconds: 100);
  late AnimationController _controller;
  static const double maxSlide = 255;
  static const dragRightStartVal = 60;
  static const dragLeftStartVal = maxSlide - 20;
  static bool shouldDrag = false;


  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: _AppDrawerState.duration);
    super.initState();
  }

  void close() => _controller.reverse();

  void open () => _controller.forward();

  void toggle () {
    if (_controller.isCompleted) {
      close();
    } else {
      open();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails startDetails) {
    bool isDraggingFromLeft = _controller.isDismissed && startDetails.globalPosition.dx < dragRightStartVal;
    bool isDraggingFromRight = _controller.isCompleted && startDetails.globalPosition.dx > dragLeftStartVal;
    shouldDrag = isDraggingFromLeft || isDraggingFromRight;
  }

  void _onDragUpdate(DragUpdateDetails updateDetails) {
    if (shouldDrag == false) {
      return;
    }
    double delta = updateDetails.primaryDelta! / maxSlide;
    _controller.value += delta;
  }

  void _onDragEnd(DragEndDetails dragEndDetails) {
    if (_controller.isDismissed || _controller.isCompleted) {
      return;
    }

    double _kMinFlingVelocity = 365.0;
    double dragVelocity = dragEndDetails.velocity.pixelsPerSecond.dx.abs();

    if (dragVelocity >= _kMinFlingVelocity) {
      double visualVelocityInPx = dragEndDetails.velocity.pixelsPerSecond.dx / MediaQuery.of(context).size.width;
      _controller.fling(velocity: visualVelocityInPx);
    } else if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          double animationVal = _controller.value;
          double translateVal = animationVal * maxSlide;
          double scaleVal = 1 - (animationVal *  0.3);
          return Stack(
            children: <Widget>[
              CustomDrawer(),
              Transform(

                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..translate(translateVal)
                  ..scale(scaleVal),
                child: GestureDetector(
                  onTap: () {
                    if (_controller.isCompleted) {
                      close();
                    }
                  },
                  child: widget.child
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  AppBar appBar = AppBar(
    title: Text('SIIS'),
    backgroundColor: kPrimaryColor,
    leading: Builder(
      builder: (BuildContext appBarContext) {
        return IconButton(
            onPressed: () {
              AppDrawer.of(appBarContext)?.toggle();
            },
            icon: Icon(Icons.menu_rounded)
        );
      },
    ),
  );


  @override
  Widget build(BuildContext context) {
    var user = context.read<AccountProvider>().user;
    String? username = user!['user_name'];
    String? userrole = user!['user_role'];
    return Material(
      color: kMenuColor,
      child: SafeArea(
        child: Theme(
          data: ThemeData(
            brightness: Brightness.dark,
          ),


           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisAlignment: MainAxisAlignment.start,
             children:<Widget>[

              Container(
                    height: 150,
                    padding: EdgeInsets.all(26),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,

                          children: <Widget>[
                            Image.asset("assets/images/mw.png", width: 35, height: 35,),

                            Expanded(
                              child: Text('SIIS', style: TextStyle(fontSize: 26, color: Colors.white)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: <Widget>[
                            Icon(Icons.person, size: 18,),
                            Expanded(
                              child: Text(username!, style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: <Widget>[
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(userrole!, style: TextStyle(fontSize: 16, color: Colors.white, fontStyle: FontStyle.italic )),
                            ),
                          ],
                        ),
                      ],
                    )


                ),

            Expanded(
              child: ListView(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.home),
                        title: Text('Dashboard'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  AppDrawer(
                                child: Dashboard(appBar: appBar),
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 250,
                        child: ExpansionTile(
                          leading: Icon(Icons.school),
                          title: Text("School Visit"),
                          childrenPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          children: <Widget>[
                            user!['user_role'] == 'Secondary Advisor' ?ListTile(
                              leading: Icon(Icons.arrow_right),
                              title: Text('Action Plan'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (body) =>  AppDrawer(
                                      child: Recommendations(),
                                    ),
                                  ),
                                );
                              },
                            ): Container(),
                            ListTile(
                              leading: Icon(Icons.arrow_right),
                              title: Text('Full Inspection'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (body) =>  AppDrawer(
                                      child: SchoolVisits( ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.arrow_right),
                              title: Text('Follow-up Inspection'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  AppDrawer(
                                      child: FollowUp(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),),
                      //
                      // ListTile(
                      //   leading: Icon(Icons.sync),
                      //   title: Text('Sync data'),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) =>  AppDrawer(
                      //           child: ServerSync(),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        onTap: () async {
                          await AccountProvider().logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (BuildContext context) {
                              return const Login();
                            }),
                                (Route<dynamic> route) => true,

                          );
                        },
                      ),

                    ],
                  ),
                ],

              ),
          ),
          ],
          ),
        ),
      ),
    );
  }
}
