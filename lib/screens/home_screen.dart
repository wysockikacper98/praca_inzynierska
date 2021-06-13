import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/sharedPreferences.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';

import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    if (getCurrentUser() == null) {
      getUserInfo().then((value) => setCurrentUser(value));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("FixIT!"),
        actions: [
          DropdownButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8),
                      Text('Wyloguj'),
                    ],
                  ),
                ),
                value: 'logout',
              )
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
                clearUserInfo();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Hello from home_screen.dart"),
      ),
      drawer: AppDrawer(),
    );
  }
}
