import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/screens/Login/splash_page.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:siis_offline/utils/account_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return AccountProvider();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          splash: Image.asset("assets/images/splash.gif",),
          splashIconSize: double.infinity,
          nextScreen: SplashPage(),
        ),
      ),
    );
  }
}
