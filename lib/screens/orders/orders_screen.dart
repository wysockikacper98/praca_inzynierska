import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/users.dart';
import 'create_order_screen.dart';
import 'order_active_screen.dart';
import 'order_finish_screen.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  final String _loggedUserID = FirebaseAuth.instance.currentUser.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> _finalStream(UserType userType) {
    final String fieldName = userType == UserType.Firm ? 'firmID' : 'userID';
    print('this stream is run once, hopefully');
    return FirebaseFirestore.instance
        .collection('orders')
        .where(fieldName, isEqualTo: _loggedUserID)
        .snapshots();
  }

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    print("build -> orders_screen.dart");
    var provider = Provider.of<UserProvider>(context, listen:false);
    var userType = provider.user.type;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Zamówienia'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Aktywne'),
              Tab(text: 'Zakończone'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderActiveScreen(widget._finalStream(userType)),
            OrderFinishScreen(widget._finalStream(userType)),
          ],
        ),
        floatingActionButton: userType == UserType.Firm
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed(CreateOrderScreen.routeName);
                },
              )
            : null,
      ),
    );
  }
}
