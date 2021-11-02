import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/colorfull_print_messages.dart';
import '../../helpers/firebase_firestore.dart';
import '../../helpers/storage_manager.dart';
import '../../models/users.dart';
import '../../service/local_notification_service.dart';
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
            future: getDataBeforeLogIn(user, context),
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

  @override
  void initState() {
    super.initState();

    LocalNotificationService.initialize();

    ///gives you the message on which user taps
    ///and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        printColor(
            text: 'Printing data from terminated state',
            color: PrintColor.blue);
        printColor(text: message.data["data"], color: PrintColor.cyan);
      }
    });

    ///foreground work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        printColor(
            text: 'Printing data when app is on foreground',
            color: PrintColor.magenta);
        printColor(
            text: message.notification!.body.toString(), color: PrintColor.red);
        printColor(
            text: message.notification!.title.toString(),
            color: PrintColor.red);
      }

      LocalNotificationService.display(message);
    });

    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.notification != null) {
        printColor(
            text: 'Printing data when app is on background',
            color: PrintColor.cyan);
        printColor(text: message.data["data"], color: PrintColor.blue);
      }
    });
  }
}

getDataBeforeLogIn(UserProvider user, BuildContext context) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final provider = Provider.of<ThemeProvider>(context, listen: false);

  await getUserInfoFromFirebase(context, userId);

  // dev.debugger();

  await getCategories(context);

  if (user.user!.type == UserType.Firm) {
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
