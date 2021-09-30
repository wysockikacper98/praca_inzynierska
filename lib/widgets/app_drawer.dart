import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/messages/chats_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings_screen.dart';
import 'build_user_info.dart';

Drawer appDrawer(BuildContext context) {
  print('build -> drawer');
  var height = MediaQuery.of(context).size.height;
  final provider = Provider.of<UserProvider>(context, listen: false);

  Divider buildDivider() {
    return Divider(
      thickness: 1,
      height: height * 0.02,
    );
  }

  buildIcon(IconData icon) {
    return Icon(
      icon,
      size: 40,
      color: Theme.of(context).primaryColorDark,
    );
  }

  buildText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontStyle: FontStyle.italic,
      ),
    );
  }
// FIXME: Drawer do poprawy (skorzystać z poleceń Material Design: https://material.io/components/navigation-drawer
  return Drawer(
    child: Container(
      color: Theme.of(context).primaryColorLight,
      child: Column(
        children: [
          Consumer<UserProvider>(
              builder: (ctx, provider, _) =>
                  buildUserInfo(context, provider.user)),
          buildListTile(
            context,
            buildIcon(Icons.home),
            buildText('Strona główna'),
            () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          buildDivider(),
          buildListTile(
            context,
            buildIcon(Icons.search),
            buildText('Wyszukiwarka'),
            () {
              Navigator.of(context).popAndPushNamed(SearchScreen.routeName);
            },
          ),
          buildDivider(),
          buildListTile(
            context,
            buildIcon(Icons.email),
            buildText('Wiadomości'),
            () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatsScreen(
                    key: ValueKey(FirebaseAuth.instance.currentUser!.uid),
                    user: provider.user,
                  ),
                ),
              );
            },
          ),
          buildDivider(),
          buildListTile(
            context,
            buildIcon(Icons.build),
            buildText('Zamówienia'),
            () {
              Navigator.of(context).popAndPushNamed(OrdersScreen.routeName);
            },
          ),
          buildDivider(),
          provider.user.type == UserType.Firm
              ? buildListTile(
                  context,
                  buildIcon(Icons.today_outlined),
                  buildText('Kalendarz'),
                  () {
                    Navigator.of(context)
                        .popAndPushNamed(CalendarScreen.routeName);
                  },
                )
              : buildListTile(
                  context,
                  buildIcon(Icons.warning_outlined),
                  buildText('Awarie'),
                  () {
                    Navigator.of(context)
                        .popAndPushNamed(EmergencyScreen.routeName);
                  },
                ),
          buildDivider(),
          buildListTile(
            context,
            buildIcon(Icons.settings),
            buildText('Ustawienia'),
            () {
              Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
            },
          ),
          buildDivider(),
          Spacer(),
          buildDivider(),
          buildListTile(
            context,
            buildIcon(Icons.logout),
            buildText('Wyloguj'),
            () {
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

ListTile buildListTile(
  BuildContext context,
  Icon icon,
  Text title,
  Function navigate,
) {
  return ListTile(
    leading: icon,
    title: Center(child: title),
    onTap: navigate as void Function()?,
  );
}
