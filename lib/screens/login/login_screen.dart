import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/firebase_firestore.dart';
import '../../helpers/storage_manager.dart';
import '../../models/users.dart';
import '../../widgets/theme/theme_Provider.dart';
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
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final provider = Provider.of<ThemeProvider>(context, listen: false);

  await getUserInfoFromFirebase(context, userId);

  if (user.user.type == UserType.Firm) {
    print("GetFirm info provider: " + userId);
    await getFirmInfoFromFirebase(context, userId);
  }

  final String? themeMode = await StorageManager.readData('themeMode');
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
