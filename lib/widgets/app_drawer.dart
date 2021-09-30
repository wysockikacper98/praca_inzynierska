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

class AppDrawer extends StatefulWidget {
  final String title;

  AppDrawer({required this.title});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _selectedDestination = 0;

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final provider = Provider.of<UserProvider>(context, listen: false);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<UserProvider>(
                builder: (ctx, provider, _) =>
                    buildHeader(textTheme, provider.user),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
                leading: Icon(Icons.home),
                title: Text('Strona główna'),
                selected: _selectedDestination == 0,
                onTap: () {
                  selectDestination(0);
                  Navigator.of(context).pushReplacementNamed('/');
                }),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Wyszukiwarka'),
              selected: _selectedDestination == 1,
              onTap: () {
                selectDestination(1);
                Navigator.of(context).popAndPushNamed(SearchScreen.routeName);
              },
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Wiadomości'),
              selected: _selectedDestination == 2,
              onTap: () {
                selectDestination(2);
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
            ListTile(
              leading: Icon(Icons.build),
              title: Text('Zamówienia'),
              selected: _selectedDestination == 3,
              onTap: () {
                selectDestination(3);
                Navigator.of(context).popAndPushNamed(OrdersScreen.routeName);
              },
            ),
            provider.user.type == UserType.Firm
                ? ListTile(
                    leading: Icon(Icons.today_outlined),
                    title: Text('Kalendarz'),
                    selected: _selectedDestination == 4,
                    onTap: () {
                      selectDestination(4);
                      Navigator.of(context)
                          .popAndPushNamed(CalendarScreen.routeName);
                    },
                  )
                : ListTile(
                    leading: Icon(Icons.warning_outlined),
                    title: Text('Awarie'),
                    selected: _selectedDestination == 5,
                    onTap: () {
                      selectDestination(5);
                      Navigator.of(context)
                          .popAndPushNamed(EmergencyScreen.routeName);
                    },
                  ),
            Divider(
              height: 1,
              thickness: 1,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ustawienia'),
              selected: _selectedDestination == 6,
              onTap: () {
                selectDestination(6);
                Navigator.of(context).popAndPushNamed(SettingsScreen.routeName);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Wyloguj'),
              selected: _selectedDestination == 7,
              onTap: () {
                selectDestination(7);
                FirebaseAuth.instance.signOut();
                provider.clearUserInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(TextTheme textTheme, Users user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/user.png'),
          foregroundImage:
              user.avatar != '' ? NetworkImage(user.avatar!) : null,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            '${user.firstName} ${user.lastName}',
            style: textTheme.headline6,
          ),
        ),
        Text(
          '${user.email}',
          style: textTheme.bodyText2,
        )
      ],
    );
  }
}
