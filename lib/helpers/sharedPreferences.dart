import 'dart:convert';

import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserInfo(dynamic user) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString('user', jsonEncode(user));
  print('Save User Info'+jsonEncode(user));
  setCurrentUser(user);

}

Future<Users> getUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Map userMap = jsonDecode(sharedPreferences.getString('user'));
  print("Mapa:\n$userMap");
  var user = Users.fromJson(userMap);

  return user;
}

Future<void> clearUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.remove('user');
}
