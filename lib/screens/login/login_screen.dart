import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/firebaseHelper.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:provider/provider.dart';

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
    final user = Provider.of<UserProvider>(context, listen: false);
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.hasData) {
          return FutureBuilder(
            future: functionTemp(user, context),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                    body: Center(child: CircularProgressIndicator()));
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
  if (user.user == null) {
    await getUserInfoFromFirebase(
        context, FirebaseAuth.instance.currentUser.uid);
  }
}
