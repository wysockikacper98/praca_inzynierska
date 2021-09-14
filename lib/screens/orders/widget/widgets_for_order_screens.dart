import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:provider/provider.dart';

Widget buildOrderListTile(
  BuildContext context,
  QueryDocumentSnapshot<Map<String, dynamic>> data,
) {
  final provider = Provider.of<UserProvider>(context);
  return ListTile(
    leading: CircleAvatar(
      backgroundImage: AssetImage('assets/images/user.png'),
    ),
    title: provider.user.type == UserType.PrivateUser
        ? Text(data.data()['firmName'])
        : Text(data.data()['userName']),
  );
}
