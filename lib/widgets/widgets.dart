import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/users.dart';

Container buildUserInfo(BuildContext context, Users user) {
  return Container(
    height: 120,
    child: DrawerHeader(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(color: Colors.blue),
      child: Center(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: user.avatar == ''
                ? AssetImage('assets/images/user.png')
                : NetworkImage(user.avatar),
            radius: 30,
          ),
          title: Text(
            user.firstName,
            style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
          ),
          subtitle: Text(user.email),
          trailing: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              //TODO: Przejście do ustawień użytkownika
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    ),
  );
}
