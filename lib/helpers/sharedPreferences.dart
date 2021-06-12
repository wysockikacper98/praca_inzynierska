import 'dart:convert';

import 'package:praca_inzynierska/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserInfo(Users user) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString('user', jsonEncode(user));
}

Future<Users> getUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Map userMap = jsonDecode(sharedPreferences.getString('user'));
  var user = Users.fromJson(userMap);

  return user;
}

Future<void> clearUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove('user');
}
