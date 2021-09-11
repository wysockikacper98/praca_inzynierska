import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/screens/orders/search_user_screen.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  @override
  Widget build(BuildContext context) {
    print("build -> orders_screen.dart");
    var provider = Provider.of<UserProvider>(context);

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
            buildCenter("Lista zamówień aktywnych"),
            buildCenter("Lista zamówień zakończonych"),
          ],
        ),
        floatingActionButton: provider.user.type == UserType.Firm
            ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed(SearchUserScreen.routeName);
                },
              )
            : null,
      ),
    );
  }

  Center buildCenter(String text) => Center(child: Text(text));
}
