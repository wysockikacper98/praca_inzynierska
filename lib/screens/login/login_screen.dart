import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/firebaseHelper.dart';
import 'package:praca_inzynierska/helpers/storage_manager.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/widgets/theme/theme_Provider.dart';
import 'package:provider/provider.dart';

import '../home_screen.dart';
import 'login_form_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    print('build -> login_screen');
    final user = Provider.of<UserProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.hasData) {
          return FutureBuilder(
            future: functionTemp(user, context),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                    backgroundColor: Color(0xFFFFF3E2),
                    // body: Center(child: CircularProgressIndicator()));
                    body: Center(
                      child: Image.asset(
                        'assets/icons/repair-tools.png',
                        width: size.width * 0.4,
                      ),
                    ));
              }
              return HomeScreen();
            },
          );
        } else {
          return LoginFormScreen();
        }
      },
    );
  }
}

functionTemp(UserProvider user, BuildContext context) async {
  final userId = FirebaseAuth.instance.currentUser.uid;
  final provider = Provider.of<ThemeProvider>(context, listen: false);

  if (user.user == null) {
    await getUserInfoFromFirebase(context, userId);
  }
  if (user.user.type == UserType.Firm) {
    print("GetFirm info provider: " + userId);
    await getFirmInfoFromFirebase(context, userId);
  }

  final String themeMode = await StorageManager.readData('themeMode');
  if (themeMode == null) {
    provider.themeMode = ThemeMode.system;
    print('Hello themeMode is: $themeMode');
  } else if (themeMode == 'dark') {
    provider.themeMode = ThemeMode.dark;
    print('Hello themeMode is: $themeMode');
  } else if (themeMode == 'light') {
    provider.themeMode = ThemeMode.light;
    print('Hello themeMode is: $themeMode');
  } else {
    provider.themeMode = ThemeMode.system;
    print('Hello themeMode is: $themeMode');
  }
}
