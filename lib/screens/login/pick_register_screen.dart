

import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/login/register_contractor_screen.dart';
import 'package:praca_inzynierska/screens/login/register_user_screen.dart';

class PickRegisterScreen extends StatelessWidget {
  static const routerName = '/pick-register';
  @override
  Widget build(BuildContext context) {
    print('build -> pick_register_screen');
    return Scaffold(
      body: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Zarejestruj jako:", style: Theme.of(context).textTheme.headline5),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      child: Text("Użytkownik"),
                      onPressed: (){
                        Navigator.of(context).pushNamed(RegisterUserScreen.routerName);
                      },
                    ),
                    ElevatedButton(
                      child: Text("Wykonawca"),
                      style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
                      onPressed: (){
                        Navigator.of(context).pushNamed(RegisterContractorScreen.routeName);
                      },
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







