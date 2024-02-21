import 'package:http/http.dart';
import '../constants.dart';

class UserService {
  static Future<bool> login(String email, String password) async {
    try {
      Map<String, String> headers = {"Content-type": "application/json", "Accept": "application/json"};

      print(email + password);
      Response response = await post(Uri.parse(""),
          body: {'user_email': email, 'user_password': password});
      print(response.body);
      if (response.body.contains('success')) {
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }
}
