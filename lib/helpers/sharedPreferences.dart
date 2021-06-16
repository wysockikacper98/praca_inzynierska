import 'dart:convert';

import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserInfo(dynamic user) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  user.type == UserType.Firm
      ? print("Zapisywanie firmy")
      : print("Zapiswyanie użtykownika");
  user = Users(
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    telephone: user.telephone,
    rating: user.rating,
    avatar: user.avatar,
    type: user.type,
  );

  await sharedPreferences.setString('user', jsonEncode(user));
  setCurrentUser(user);
}

Future<Users> getUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  try {
    print("Pobrany string z shared Preferences:" +
        sharedPreferences.getString('user').toString());
    Map userMap = jsonDecode(sharedPreferences.getString('user'));
    print("Mapa:\n$userMap");
    var user = Users.fromJson(userMap);
    return user;
  }catch(error){
    print('SharedPreferences Error get User info'+error);
    return null;
  }
}

Future<void> clearUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.remove('user');
  setCurrentUser(null);
}
