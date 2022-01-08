import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/emergency_screen.dart';
import '../screens/firm/firm_edit_profile_screen.dart';
import '../screens/firm/firm_profile_screen.dart';
import '../screens/messages/chats_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/user/user_edit_profile_screen.dart';
import '../screens/user/user_profile_screen.dart';
import 'theme/theme_Provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final provider = Provider.of<UserProvider>(context, listen: false);
    final bool isDarkTheme =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Drawer(
      child: Container(
        color: isDarkTheme ? const Color(0xFF2A2A2A) : theme.primaryColorLight,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    color: theme.primaryColor,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Consumer<UserProvider>(
                          builder: (ctx, prov, _) => buildHeader(
                            ctx,
                            textTheme,
                            prov.user!,
                            isDarkTheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Strona główna'),
                      onTap: () {
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.search),
                    title: Text('Wyszukiwarka'),
                    onTap: () {
                      Navigator.of(context)
                          .popAndPushNamed(SearchScreen.routeName);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Wiadomości'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatsScreen(
                            key: ValueKey(
                                FirebaseAuth.instance.currentUser!.uid),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.build),
                    title: Text('Zamówienia'),
                    onTap: () {
                      Navigator.of(context)
                          .popAndPushNamed(OrdersScreen.routeName);
                    },
                  ),
                  provider.user!.type == UserType.Firm
                      ? ListTile(
                          leading: Icon(Icons.today_outlined),
                          title: Text('Kalendarz'),
                          onTap: () {
                            Navigator.of(context)
                                .popAndPushNamed(CalendarScreen.routeName);
                          },
                        )
                      : ListTile(
                          leading: Icon(Icons.warning_outlined),
                          title: Text('Awarie'),
                          onTap: () {
                            Navigator.of(context)
                                .popAndPushNamed(EmergencyScreen.routeName);
                          },
                        ),
                  Divider(
                    height: 1,
                    thickness: 1,
                  ),
                  //TODO: Usunąć albo dodać nowe funkcjonalności w aplikacji
                  // ListTile(
                  //   leading: Icon(Icons.settings),
                  //   title: Text('Ustawienia'),
                  //   onTap: () {
                  //     Navigator.of(context)
                  //         .popAndPushNamed(SettingsScreen.routeName);
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Wyloguj'),
                    onTap: () {
                      Navigator.of(context).pop();
                      FirebaseAuth.instance.signOut();
                      provider.clearUserInfo();
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (ctx, AsyncSnapshot<PackageInfo> snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          '${snapshot.data!.appName} v${snapshot.data!.version}+${snapshot.data!.buildNumber} ',
                          // style: Theme.of(context).textTheme.subtitle1,
                          style: GoogleFonts.vt323(
                            fontSize: 20,
                          ),
                        );
                      } else
                        return Container();
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(
      BuildContext context, TextTheme textTheme, Users user, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/user.png'),
              foregroundImage:
                  user.avatar != '' ? NetworkImage(user.avatar!) : null,
            ),
            IconButton(
              iconSize: 30,
              icon: Icon(
                isDarkMode
                    ? Icons.light_mode_sharp
                    : Icons.nightlight_round_sharp,
                color: Theme.of(context).primaryColorLight,
              ),
              onPressed: () =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(!isDarkMode),
            ),
          ],
        ),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: Theme.of(context).primaryColorLight,
            collapsedIconColor: Theme.of(context).primaryColorLight,
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text(
              '${user.firstName} ${user.lastName}',
              style: textTheme.headline6,
            ),
            subtitle: Text(
              '${user.email}',
              style: textTheme.bodyText2,
            ),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person),
                title: Text('Podgląd profilu'),
                onTap: user.type == UserType.Firm
                    ? () => Navigator.of(context).popAndPushNamed(
                          FirmProfileScreen.routeName,
                          arguments:
                              FirmsAuth(FirebaseAuth.instance.currentUser!.uid),
                        )
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(
                                FirebaseAuth.instance.currentUser!.uid),
                          ),
                        );
                      },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.manage_accounts),
                title: Text('Edycja profilu'),
                onTap: user.type == UserType.Firm
                    ? () => Navigator.of(context)
                        .popAndPushNamed(FirmEditProfileScreen.routeName)
                    : () => Navigator.of(context)
                        .popAndPushNamed(UserEditProfileScreen.routeName),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
