import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/screens/emergency_screen.dart';
import 'package:praca_inzynierska/screens/firm/firm_edit_profile_screen.dart';
import 'package:praca_inzynierska/screens/messages/chats_screen.dart';
import 'package:praca_inzynierska/screens/search/search_screen.dart';
import 'package:praca_inzynierska/screens/user/user_edit_profile_screen.dart';
import 'package:praca_inzynierska/widgets/build_user_info.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    print("build -> drawer");
    final provider = Provider.of<UserProvider>(context);
    return Drawer(
      child: Container(
        color: Theme.of(context).primaryColorLight,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            buildUserInfo(context, provider.user),
            ListTile(
              leading: buildIcon(icon: Icons.home),
              title: Center(child: buildText(text: "Strona główna")),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            Divider(
              thickness: 1,
              height: 25,
            ),
            ListTile(
              leading: buildIcon(icon: Icons.search),
              title: Center(child: buildText(text: "Wyszukiwarka")),
              onTap: () {
                //TODO: Go to screen
                Navigator.of(context).popAndPushNamed(SearchScreen.routeName);
              },
            ),
            Divider(
              thickness: 1,
              height: 25,
            ),
            ListTile(
              leading: buildIcon(icon: Icons.email),
              title: Center(
                child: buildText(text: "Wiadomości"),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatsScreen(
                      key: ValueKey(FirebaseAuth.instance.currentUser.uid),
                      user: provider.user,
                    ),
                  ),
                );
              },
            ),
            Divider(
              thickness: 1,
              height: 25,
            ),
            ListTile(
              leading: buildIcon(icon: Icons.warning_outlined),
              title: Center(child: buildText(text: "Awarie")),
              onTap: () {
                Navigator.of(context)
                    .popAndPushNamed(EmergencyScreen.routeName);
              },
            ),
            Divider(
              thickness: 1,
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  buildIcon({IconData icon}) {
    return Icon(
      icon,
      size: 40,
      color: Theme.of(context).primaryColorDark,
    );
  }

  buildText({String text}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
