import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/firebase_firestore.dart';
import '../models/users.dart';
import '../service/local_notification_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/firm/firm_list.dart';
import 'orders/order_details_screen.dart';
import 'search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';
  bool _initialize = false;

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

  DateTime preBackPress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    print('build -> home_screen');
    initialize(context);
    return WillPopScope(
      onWillPop: () async {
        final timeGap = DateTime.now().difference(preBackPress);
        final cantExit = timeGap >= Duration(seconds: 2);
        preBackPress = DateTime.now();

        if (cantExit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Press Back button again to Exit'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("FixIT!"),
        ),
        drawer: AppDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Najczęstsze kategorie',
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SearchScreen('Hydraulik')),
                  ),
                ),
                ElevatedButton(
                  child: Center(child: FittedBox(child: Text('Elektryk'))),
                  style: style(1),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchScreen('Elektryk')),
                  ),
                ),
                ElevatedButton(
                  child: Center(child: FittedBox(child: Text('Malarz'))),
                  style: style(2),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchScreen('Malarz')),
                  ),
                ),
                ElevatedButton(
                  child:
                      Center(child: FittedBox(child: Text('Zdrowie i uroda'))),
                  style: style(3),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SearchScreen('Zdrowie i uroda')),
                  ),
                ),
                ElevatedButton(
                  child:
                      Center(child: FittedBox(child: Text('Usługi finansowe'))),
                  style: style(4),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SearchScreen('Usługi finansowe')),
                  ),
                ),
                ElevatedButton(
                  child: Center(
                    child: FittedBox(
                      child: Text('Meble i zabudowa'),
                    ),
                  ),
                  style: style(5),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SearchScreen('Hydraulik')),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text('Polecane',
                  style: Theme.of(context).textTheme.headline6),
            ),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) =>
                  createRecommendedFirmList(context),
            ),
          ],
        ),
      ),
    );
  }

  void initialize(BuildContext context) async {
    if (!_initialize) {
      await Future.delayed(Duration(seconds: 1));
      var userType =
          Provider.of<UserProvider>(context, listen: false).user!.type;

      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await saveTokenToDatabase(userType, token);
      }
      FirebaseMessaging.instance.onTokenRefresh
          .listen((event) => saveTokenToDatabase(userType, event));

      LocalNotificationService.initialize(context);

      ///gives you the message on which user taps
      ///and it opened the app from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          if (message.data['name'] == OrderDetailsScreen.routeName) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderDetailsScreen(orderID: message.data['details']),
              ),
            );
          }
        }
      });

      ///When the app is in background but opened and user taps
      ///on the notification
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (message.notification != null) {
          if (message.data['name'] == OrderDetailsScreen.routeName) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderDetailsScreen(orderID: message.data['details']),
              ),
            );
          }
        }
      });

      ///foreground work
      FirebaseMessaging.onMessage.listen((message) {
        if (message.notification != null) {
          //TODO: zrobic coś z wyświetlaniem w aplickaji
          LocalNotificationService.display(message);
        }
      });

      _initialize = true;
    }
  }
}
