import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/sharedPreferences.dart';
import 'package:praca_inzynierska/widgets/firmRelated/firm_list.dart';

import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    print('build -> home_screen');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "FixIT!",
          style: TextStyle(
              fontSize: 30,
              fontFamily: 'Dancing Script',
              fontWeight: FontWeight.w700),
        ),
        actions: [
          DropdownButton(
            underline: Container(),
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.black,
                      ),
                      SizedBox(width: 8),
                      Text('Wyloguj'),
                    ],
                  ),
                ),
                value: 'logout',
              )
            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
                clearUserInfo();
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'Najczęstrze kategorie',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.count(
              primary: false,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: EdgeInsets.all(20),
              crossAxisCount: 2,
              childAspectRatio: 4,
              addRepaintBoundaries: false,
              children: [
                ElevatedButton(child: Text('Hydraulik'), onPressed: (){}),
                Center(child: Text('Elektryk')),
                Center(child: Text('Malarz')),
                Center(child: Text('Zdrowie i uroda')),
                Center(child: Text('Usługi finansowe')),
                Center(child: Text('Meble i zabudowa')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'Polecane',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: createFirmList(context)),
        ],
      ),
      drawer: AppDrawer(),
    );
  }
}
