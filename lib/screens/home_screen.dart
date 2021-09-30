import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';
import '../widgets/app_drawer.dart';
import '../widgets/firm/firm_list.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  style(int number) {
    return ElevatedButton.styleFrom(
      primary: color[number],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }

  final color = [
    Color(0xFFCF6B59),
    Color(0xFF196F64),
    Color(0xFF8E4169),
    Color(0xFFECBC9F),
    Color(0xFF2F4496),
    Color(0xFFBFB051),
  ];

  @override
  Widget build(BuildContext context) {
    print('build -> home_screen');
    // final provider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("FixIT!"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(getCurrentUser().toString()),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'Najczęstsze kategorie',
              // style: TextStyle(fontWeight: FontWeight.bold),
              style: Theme.of(context).textTheme.headline6,
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
                child:
                    Center(child: FittedBox(child: Text('Usługi finansowe'))),
                style: style(4),
                onPressed: () {},
              ),
              ElevatedButton(
                child: Center(
                  child: FittedBox(
                    child: Text('Meble i zabudowa'),
                  ),
                ),
                style: style(5),
                onPressed: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                Text('Polecane', style: Theme.of(context).textTheme.headline6),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) =>
                createRecommendedFirmList(context),
          ),
        ],
      ),
      drawer: AppDrawer(title: 'Test'),
    );
  }
}
