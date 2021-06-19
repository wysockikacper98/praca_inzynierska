import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/sharedPreferences.dart';
import 'package:praca_inzynierska/widgets/firm/firm_list.dart';

import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  style(int number) {
    return ElevatedButton.styleFrom(
      primary: color[number],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }

  final color = [
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.greenAccent,
  ];

  @override
  Widget build(BuildContext context) {
    print('build -> home_screen');
    color.shuffle();

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
              size: 30,
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
          GridView.count(
            primary: true,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: EdgeInsets.all(20),
            crossAxisCount: 2,
            childAspectRatio: 4,
            shrinkWrap: true,
            children: [
              ElevatedButton(
                child: Center(child: FittedBox(child: Text('Hydraulik'))),
                style: style(0),
                onPressed: () {},
              ),
              ElevatedButton(
                child: Center(child: FittedBox(child: Text('Elektryk'))),
                style: style(1),
                onPressed: () {},
              ),
              ElevatedButton(
                child: Center(child: FittedBox(child: Text('Malarz'))),
                style: style(2),
                onPressed: () {},
              ),
              ElevatedButton(
                child: Center(child: FittedBox(child: Text('Zdrowie i uroda'))),
                style: style(3),
                onPressed: () {},
              ),
              ElevatedButton(
                child: Center(child: FittedBox(child: Text('Usługi finansowe'))),
                style: style(4),
                onPressed: () {},
              ),
              ElevatedButton(
                child: Center(child: FittedBox(child: Text('Meble i zabudowa'),)),
                style: style(5),
                onPressed: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                Text('Polecane', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          createRecommendedFirmList(context),
        ],
      ),
      drawer: AppDrawer(),
    );
  }
}
