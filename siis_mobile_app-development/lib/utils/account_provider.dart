import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/Login/splash_page.dart';
import 'base_api.dart';

class AccountProvider with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  late final SharedPreferences _preferences;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  Future<void> init(context) async {
    try {
      _preferences = await SharedPreferences.getInstance();
      _token = _preferences.getString(BaseApi.keyToken);
      _user = jsonDecode(_preferences.getString(BaseApi.user) as String) as Map<String, dynamic>?;
      print(_user);
    }catch(e){
      print(_token);
      logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) {
          return const Login();
        }),
            (Route<dynamic> route) => false,
      );
    }
  }

    Future<bool> login({
      required String email,
      required String password,
    }) async {
      Response response = await post(Uri.parse(BaseApi.loginPath),
          headers: BaseApi.headers,
          body: json.encode({
            'user_email': email,
            'user_password': password,
          }));
      Map results = jsonDecode(response.body);
      if (results.keys.contains('error')) {
        return false;
      }
      if(results['1'] == null) return false;
      _token = results['1']['token'];
      if (results['1']['token'] != null) {
        await _preferences.setString(
          BaseApi.keyToken,
          results['1']['token']!,
        );
        _user = results['0'];
        print(jsonEncode(results['0']).toString());
        await _preferences.setString(
          BaseApi.user, jsonEncode(results['0'])
        );
      }
      notifyListeners();
      return true;
    }

    Future<void> logout() async {
      _token = null;
      _preferences = await SharedPreferences.getInstance();
      await _preferences.remove(BaseApi.keyToken);
      await _preferences.remove(BaseApi.user);
      notifyListeners();
    }
}
