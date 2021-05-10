

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserInfo(String uid) async {
  final data =
  await FirebaseFirestore.instance.collection('users').doc(uid).get();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString('user', jsonEncode(data.data()));
}

Future<Users> getUserInfo() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  Map userMap = jsonDecode(sharedPreferences.getString('user'));
  var user = Users.fromJson(userMap);

  return user;
}