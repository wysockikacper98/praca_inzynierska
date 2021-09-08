import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'register_contractor_screen.dart';
import 'register_user_screen.dart';

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
                Text("Zarejestruj jako:",
                    style: Theme.of(context).textTheme.headline5),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      child: Text("Użytkownik"),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(RegisterUserScreen.routerName);
                      },
                    ),
                    ElevatedButton(
                        child: Text("Wykonawca"),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColorDark),
                        onPressed: () => _showContractorScreen(context)
                        //     () {
                        //   Navigator.of(context)
                        //       .pushNamed(RegisterContractorScreen.routeName);
                        // },
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

  Future<void> _showContractorScreen(BuildContext context) async {
    final data = await FirebaseFirestore.instance
        .collection('usefulData')
        .doc('mKT6HCrf066qkE3MTNL0')
        .get();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RegisterContractorScreen(categories: data.data()['categoryListPL']),
      ),
    );
  }
}
