import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';
import '../widgets/theme/theme_Provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final bool isUserTypeFirm =
        Provider.of<UserProvider>(context, listen: false).user.type ==
            UserType.Firm;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
        appBar: AppBar(title: Text('Ustawienia')),
        body: Column(
          children: [
            SwitchListTile(
              title: Text('Tryb ciemny:'),
              value: themeProvider.isDarkMode,
              activeColor: Theme.of(context).accentColor,
              onChanged: (value) {
                final provider =
                    Provider.of<ThemeProvider>(context, listen: false);
                provider.toggleTheme(value);
              },
            ),
            // ListTile(
            //   leading: FaIcon(FontAwesomeIcons.userEdit),
            //   title: Text(
            //     isUserTypeFirm
            //         ? 'Edycja profilu wykonawcy'
            //         : 'Edycja profilu użytkownika',
            //     style: Theme
            //         .of(context)
            //         .textTheme
            //         .subtitle1,
            //   ),
            //   trailing: Icon(Icons.chevron_right),
            //   onTap: () {
            //     isUserTypeFirm
            //         ? Navigator.of(context)
            //         .pushNamed(FirmEditProfileScreen.routeName)
            //         : Navigator.of(context).pop();
            //   },
            // ),
          ],
        ));
  }
}
