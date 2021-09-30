import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/theme/theme_Provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Ustawienia')),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Tryb ciemny:'),
            value: themeProvider.isDarkMode,
            activeColor: Theme.of(context).colorScheme.secondary,
            onChanged: (value) =>
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(value),
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
      ),
    );
  }
}
