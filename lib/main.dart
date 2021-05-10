import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/chats_screen.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("build -> main.dart");

    return MaterialApp(
      title: 'FixIT!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.pink,
        // backgroundColor: Colors.pink,
        accentColor: Colors.amber,
        accentColorBrightness: Brightness.light,

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.pink,
            // textStyle: TextStyle(color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => LoginScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        // ChatsScreen.routeName: (ctx) => ChatsScreen(),

      },
    );
  }
}
