// import 'dart:convert';
//
// import 'package:praca_inzynierska/models/users.dart';
// import 'package:praca_inzynierska/providers/UserProvider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// Future<void> saveUserInfo(dynamic user) async {
//   user = Users(
//     firstName: user.firstName,
//     lastName: user.lastName,
//     email: user.email,
//     telephone: user.telephone,
//     rating: user.rating,
//     avatar: user.avatar,
//     type: user.type,
//   );
//   // print('User to save in memory:' + user.toString());
//
//   setCurrentUser(user);
//
//   SharedPreferences.getInstance().then((value) {
//     // print('\n\nTest1:\n'+user.toString());
//     value.setString('user', jsonEncode(user));
//     // print('\n\nTest2\n'+value.getString('user').toString());
//     // print('\n\nTest3\n'+user.toJson().toString());
//   });
// }
//
// Future<Users> getUserInfo() async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//
//   // print("Pobrany string z shared Preferences:" +
//   //     sharedPreferences.getString('user').toString());
//   Map userMap = jsonDecode(sharedPreferences.getString('user'));
//   // print("Mapa:\n$userMap");
//   var user = Users.fromJson(userMap);
//   return user;
// }
//
// Future<void> clearUserInfo() async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   await sharedPreferences.remove('user');
//   setCurrentUser(null);
// }


import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      prefs.setString(key, value);
    } else {
      print("Invalid Type");
    }
  }

  static Future<String> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}