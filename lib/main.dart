import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/emergency_screen.dart';
import 'package:praca_inzynierska/screens/firm/firm_profile_screen.dart';
import 'package:praca_inzynierska/screens/login/pick_register_screen.dart';
import 'package:praca_inzynierska/screens/login/register_contractor_screen.dart';
import 'package:praca_inzynierska/screens/login/register_user_screen.dart';

import 'screens/home_screen.dart';
import 'screens/login/login_screen.dart';

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
        LoginScreen.routeName: (ctx) => LoginScreen(),
        PickRegisterScreen.routerName: (ctx) => PickRegisterScreen(),
        RegisterUserScreen.routerName: (ctx) => RegisterUserScreen(),
        RegisterContractorScreen.routeName: (ctx) => RegisterContractorScreen(),
        FirmProfileScreen.routeName: (ctx) => FirmProfileScreen(),
        EmergencyScreen.routeName: (ctx) => EmergencyScreen(),
        // ChatsScreen.routeName: (ctx) => ChatsScreen(),

      },
    );
  }
}
