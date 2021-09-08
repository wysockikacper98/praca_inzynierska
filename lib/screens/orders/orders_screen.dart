import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _widgetIndex;

  @override
  void initState() {
    super.initState();
    _widgetIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    print("build -> orders_screen.dart");

    return Scaffold(
      appBar: AppBar(title: Text("Zamówienia")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text("Button 1"),
                style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(0),
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () {
                  setState(() {
                    _widgetIndex = 1;
                  });
                },
              ),
              ElevatedButton(
                child: Text("Button 2"),
                onPressed: () {
                  setState(() {
                    _widgetIndex = 0;
                  });
                },
              ),
            ],
          ),
          Container(
            color: Colors.green,
            child: IndexedStack(
              index: _widgetIndex,
              children: [
                buildCenter("Jeden"),
                buildCenter("Dwa"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Center buildCenter(String text) => Center(child: Text(text));
}
