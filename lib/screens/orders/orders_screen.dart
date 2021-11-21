import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/colorfull_print_messages.dart';
import 'package:provider/provider.dart';

import '../../models/users.dart';
import 'create_order_screen.dart';
import 'order_active_screen.dart';
import 'order_finish_screen.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  final String _loggedUserID = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> _finalStream(UserType userType) {
    final String fieldName = userType == UserType.Firm ? 'firmID' : 'userID';
    printColor(
        text: 'this stream is run once, hopefully', color: PrintColor.green);
    return FirebaseFirestore.instance
        .collection('orders')
        .where(fieldName, isEqualTo: _loggedUserID)
        .snapshots();
  }

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final UserType userType;

  @override
  void initState() {
    super.initState();
    userType = Provider.of<UserProvider>(context, listen: false).user!.type;
  }

  @override
  Widget build(BuildContext context) {
    printColor(text: 'build -> orders_screen.dart', color: PrintColor.green);

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
