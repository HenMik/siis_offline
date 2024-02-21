import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:siis_offline/db_helper/database_connection.dart';
import 'package:siis_offline/screens/commons/something_went_wrong.dart';
import 'package:siis_offline/utils/app_sync.dart';
import 'package:sqflite/sqflite.dart';
import '../../../constants.dart';
import '../../../utils/account_provider.dart';
import '../../Inspector/home.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginForm> {
  late bool _isLoading;
  @override
  void initState() {
    Future<Database> db = DatabaseConnection().setDatabase();
    setState(() {
      db;
    });
    _isLoading = false;
    super.initState();
  }

  _loginFailed(BuildContext context, String msg) async {
    var _selected = "";
    _selected = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(children: [
          Expanded(
            child: SimpleDialog(
              title: Text('Login Failed'),
              children: [
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, "Wrng ");
                  },
                  child: Text(msg),
                ),
              ],
              elevation: 10,
              //backgroundColor: Colors.green,
            ),
          ),
        ]);
      },
    );
  }

  bool ActiveConnection = false;

  Future<bool> is_connected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        ActiveConnection = false;
      });
    }
    return ActiveConnection;
  }

  login(String email, password) async {
    AccountProvider provider = context.read<AccountProvider>();
    try {
      _isLoading = true;
      bool authToken = await provider.login(email: email, password: password);
      if (authToken) {
        setState(() {
          _isLoading = false;
        });

        Fluttertoast.showToast(
            msg: "Login Successful",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 10,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return AppSync();
            },
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Wrong Email or Password",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 10,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return SomethingWrongScreen();
          },
        ),
            (Route<dynamic> route) => false,
      );
      print(e.toString());
    }
  }

  final _formKeyLogin = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKeyLogin,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              onSaved: (email) {},
              controller: emailController,
              validator: (value) {
                if (value!.isEmpty) {
                  return ("Email is required for login");
                }
              },
              decoration: InputDecoration(
                hintText: "Your email",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.person),
                ),
                filled: true,
                fillColor: kPrimaryLightColor,
                iconColor: kPrimaryColor,
                prefixIconColor: kPrimaryColor,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                obscureText: true,
                cursorColor: kPrimaryColor,
                controller: passwordController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return ("Password is required for login");
                  }
                },
                decoration: InputDecoration(
                  hintText: "Your password",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.lock),
                  ),
                  filled: true,
                  fillColor: kPrimaryLightColor,
                  iconColor: kPrimaryColor,
                  prefixIconColor: kPrimaryColor,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: defaultPadding, vertical: defaultPadding),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Hero(
              tag: "login_btn",
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  primary: kPrimaryColor,
                  shape: const StadiumBorder(),
                  maximumSize: const Size(double.infinity, 56),
                  minimumSize: const Size(double.infinity, 56),
                ),
                onPressed: () async {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) {
                  //       return Home();
                  //     },
                  //   ),
                  // );
                  String msg = "";
                  if (!await is_connected()) {
                    msg = "No internet Connection";
                    _loginFailed(context,msg);
                  } else {
                    if(_formKeyLogin.currentState!.validate()) {
                      login(emailController.text.toString(),
                          passwordController.text.toString());}
                  }
                },
                child: _isLoading
                    ? SpinKitWave(
                        color: Colors.white,
                        size: 15.0,
                      )
                    : Text(
                        "Login".toUpperCase(),
                      ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              "SIIS Mobile V2.0.4",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
