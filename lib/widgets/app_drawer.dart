import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';
import '../screens/emergency_screen.dart';
import '../screens/messages/chats_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings_screen.dart';
import 'build_user_info.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    print("build -> drawer");
    var height = MediaQuery.of(context).size.height;
    final provider = Provider.of<UserProvider>(context);

    return Drawer(
      child: Container(
        color: Theme.of(context).primaryColorLight,
        child: Column(
          children: [
            Consumer<UserProvider>(
                builder: (ctx, provider, _) =>
                    buildUserInfo(context, provider.user)),
            ListTile(
              leading: buildIcon(icon: Icons.home),
              title: Center(child: buildText(text: "Strona główna")),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            buildDivider(),
            ListTile(
              leading: buildIcon(icon: Icons.build),
              title: Center(child: buildText(text: "Zamówienia")),
              onTap: () {
                Navigator.of(context)
                    .popAndPushNamed(OrdersScreen.routeName);
              },
            ),
            buildDivider(),
            ListTile(
              leading: buildIcon(icon: Icons.search),
              title: Center(child: buildText(text: "Wyszukiwarka")),
              onTap: () {
                //TODO: Go to screen
                Navigator.of(context).popAndPushNamed(SearchScreen.routeName);
              },
            ),
            buildDivider(),
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
            buildDivider(),
            ListTile(
              leading: buildIcon(icon: Icons.warning_outlined),
              title: Center(child: buildText(text: "Awarie")),
              onTap: () {
                Navigator.of(context)
                    .popAndPushNamed(EmergencyScreen.routeName);
              },
            ),
            buildDivider(),
            ListTile(
              leading: buildIcon(icon: Icons.settings),
              title: Center(child: buildText(text: 'Ustawienia')),
              onTap: () {
                Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
              },
            ),
            buildDivider(),
            Spacer(),
            buildDivider(),
            ListTile(
              leading: buildIcon(icon: Icons.logout),
              title: Center(child: buildText(text: "Wyloguj")),
              onTap: () {
                Navigator.of(context).pop();
                FirebaseAuth.instance.signOut();
                provider.clearUserInfo();
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Divider buildDivider() {
    return Divider(
      thickness: 1,
      height: 20,
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
