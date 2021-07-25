import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/screens/firm/firm_edit_profile_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final bool isUserTypeFirm =
        Provider.of<UserProvider>(context, listen: false).user.type ==
            UserType.Firm;

    return Scaffold(
        appBar: AppBar(title: Text('Ustawienia')),
        body: Column(
          children: [
            // IconButton(
            //   icon: Icon(_isDarkMode
            //       ? Icons.dark_mode_outlined
            //       : Icons.light_mode_outlined),
            //   iconSize: 200,
            //   onPressed: () {
            //     setState(() {
            //       _isDarkMode = !_isDarkMode;
            //     });
            //   },
            // ),
            SwitchListTile(
              title: Text('Tryb ciemny:'),
              value: _isDarkMode,
              activeColor: Theme.of(context).accentColor,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.userEdit),
              title: Text(
                isUserTypeFirm
                    ? 'Edycja profilu wykonawcy'
                    : 'Edycja profilu użytkownika',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                isUserTypeFirm
                    ? Navigator.of(context)
                        .pushNamed(FirmEditProfileScreen.routeName)
                    : Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}
