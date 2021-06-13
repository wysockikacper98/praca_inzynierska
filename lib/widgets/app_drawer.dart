import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';
import 'package:praca_inzynierska/screens/chats_screen.dart';
import 'package:praca_inzynierska/widgets/widgets.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // var _currentUser = Users(
  //   lastName: '',
  //   email: '',
  //   firstName: '',
  //   avatar: '',
  //   rating: '',
  //   telephone: '',
  //   type: null,
  // );

  // @override
  // void initState() {
  //   super.initState();
  //   _currentUser = getCurrentUser();
  // }

  @override
  Widget build(BuildContext context) {
    print("build -> drawer");

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildUserInfo(context, getCurrentUser()),
          Divider(
            thickness: 1,
            height: 25,
          ),
          ListTile(
            leading: Icon(
              Icons.home_outlined,
              size: 40,
            ),
            title: Center(
              child: Text(
                "Strona główna",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              //TODO: Go to screen

              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(
            thickness: 1,
            height: 25,
          ),
          ListTile(
            leading: Icon(
              Icons.email_outlined,
              size: 40,
            ),
            title: Center(
              child: Text(
                "Wiadomości",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              //TODO: Go to screen
              // Navigator.of(context).pushReplacement(ChatsScreen());
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatsScreen(
                            key:
                                ValueKey(FirebaseAuth.instance.currentUser.uid),
                            user: getCurrentUser(),
                          )));
            },
          ),
          Divider(
            thickness: 1,
            height: 25,
          ),
          ListTile(
            leading: Icon(
              Icons.search,
              size: 40,
            ),
            title: Center(
              child: Text(
                "Wyszukiwarka",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              //TODO: Go to screen

              Navigator.of(context).pop();
            },
          ),
          Divider(
            thickness: 1,
            height: 25,
          ),
          ListTile(
            leading: Icon(
              Icons.warning_amber_outlined,
              size: 40,
            ),
            title: Center(
              child: Text(
                "Awarie",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              //TODO: Go to screen

              Navigator.of(context).pop();
            },
          ),
          Divider(
            thickness: 1,
            height: 25,
          ),
          if (getCurrentUser().type == UserType.Firm)
            ListTile(
              leading: Icon(
                Icons.business_outlined,
                size: 40,
              ),
              title: Center(
                child: Text(
                  "Firma",
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ),
              onTap: () {
                //TODO: Go to screen

                Navigator.of(context).pop();
              },
            ),
          if (getCurrentUser().type == UserType.PrivateUser)
            ListTile(
              leading: Icon(
                Icons.sentiment_very_satisfied_outlined,
                size: 40,
              ),
              title: Center(
                child: Text(
                  "Użytkownik",
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                ),
              ),
              onTap: () {
                //TODO: Go to screen

                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
