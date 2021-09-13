import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/screens/orders/create_order_screen.dart';
import 'package:praca_inzynierska/screens/orders/order_active_screen.dart';
import 'package:praca_inzynierska/screens/orders/order_finish_screen.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";
  final String _loggedUserID = FirebaseAuth.instance.currentUser.uid;

  Future<QuerySnapshot<Map<String, dynamic>>> _finalFuture(UserType userType) {
    final String fieldName = userType == UserType.Firm ? 'firmID' : 'userID';
    print("this future is run once, hopefully");
    return FirebaseFirestore.instance
        .collection('orders')
        .where(fieldName, isEqualTo: _loggedUserID)
        .get();
  }

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    print("build -> orders_screen.dart");
    var provider = Provider.of<UserProvider>(context);
    var userType = provider.user.type;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Zamówienia"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Aktywne"),
              Tab(text: "Zakończone"),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            OrderActiveScreen(widget._finalFuture(userType)),
            OrderFinishScreen(widget._finalFuture(userType)),
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
