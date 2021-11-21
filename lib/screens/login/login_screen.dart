import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/colorfull_print_messages.dart';
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
  bool _futureInitialize = false;
  late Future<void> _future;

  // @override
  // void initState() {
  //   super.initState();
  //   _future = getDataBeforeLogIn();
  // }

  @override
  Widget build(BuildContext context) {
    printColor(text: 'build -> login_screen', color: PrintColor.blue);
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.hasData) {
          if (!_futureInitialize) {
            _futureInitialize = true;
            _future = getDataBeforeLogIn();
          }
          printColor(text: 'userSnapshot.hasData', color: PrintColor.red);
          return FutureBuilder(
            future: _future,
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
          _futureInitialize = false;
          return LoginFormScreen();
        }
      },
    );
  }

  Future<void> getDataBeforeLogIn() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    printColor(text: 'getDataBeforeLogIn', color: PrintColor.magenta);

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final provider = Provider.of<ThemeProvider>(context, listen: false);

    await getCategories(context);

    await getUserInfoFromFirebase(context, userId);

    if (userProvider.user!.type == UserType.Firm) {
      print("GetFirm info provider: " + userId);
      await getFirmInfoFromFirebase(context, userId);
    } else {
      printColor(text: 'GetUserInfo: $userId', color: PrintColor.magenta);
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
}
