import 'dart:convert';

import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserInfo(dynamic user) async {
  user = Users(
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    telephone: user.telephone,
    rating: user.rating,
    avatar: user.avatar,
    type: user.type,
  );
  setCurrentUser(user);

  SharedPreferences.getInstance().then((value) => value.setString('user', jsonEncode(user)));
}

Future<Users> getUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  print("Pobrany string z shared Preferences:" +
      sharedPreferences.getString('user').toString());
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
