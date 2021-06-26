import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/sharedPreferences.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';

import '../home_screen.dart';
import 'login_form_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    print('build -> login_screen');
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.hasData) {
          return FutureBuilder(
            future: functionTemp(),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
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

functionTemp() async {
  if (getCurrentUser() == null) {
    setCurrentUser(await getUserInfo());
  }
}
