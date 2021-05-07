import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/home_screen.dart';

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
        primaryColor: Colors.deepOrange,
        accentColor: Colors.amber,
      ),
      home: HomeScreen(),
    );
  }
}
