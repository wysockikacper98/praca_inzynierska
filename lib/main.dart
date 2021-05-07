import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/home_screen.dart';
import 'package:praca_inzynierska/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("build -> main.dart");

    return MaterialApp(
      title: 'FixIT!',
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
      home: LoginScreen(),
    );
  }
}
