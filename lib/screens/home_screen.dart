import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("build -> home_screen.dart");

    return Scaffold(
      appBar: AppBar(
        title: Text("FixIT!"),
      ),
      body: Center(
        child: Text("Hello from home_screen.dart"),
      ),
      drawer: AppDrawer(),
    );
  }
}
