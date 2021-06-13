import 'dart:convert';

import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserInfo(dynamic user) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString('user', jsonEncode(user));
  setCurrentUser(Users(
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    telephone: user.telephone,
    rating: user.rating,
    avatar: user.avatar,
    type: user.type,
  ));

}

Future<Users> getUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  print(sharedPreferences.getString('user'));
  Map userMap = jsonDecode(sharedPreferences.getString('user'));
  print("Mapa:\n$userMap");
  var user = Users.fromJson(userMap);

  return user;
}

Future<void> clearUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.remove('user');
  setCurrentUser(null);
}
