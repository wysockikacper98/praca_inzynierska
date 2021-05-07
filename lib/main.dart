import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("build -> main.dart");
    // Custom Colors
    // const MaterialColor primaryColor = const MaterialColor(
    //   0xFFFC9684,
    //   const <int, Color>{
    //     50: const Color(0xFFFC9684),
    //     100: const Color(0xFFFC9684),
    //     200: const Color(0xFFFC9684),
    //     300: const Color(0xFFFC9684),
    //     400: const Color(0xFFFC9684),
    //     500: const Color(0xFFFC9684),
    //     600: const Color(0xFFFC9684),
    //     700: const Color(0xFFFC9684),
    //     800: const Color(0xFFFC9684),
    //     900: const Color(0xFFFC9684),
    //   },
    // );

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
