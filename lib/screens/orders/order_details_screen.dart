import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  static const String routeName = '/order-details';

  final String orderID;

  OrderDetailsScreen({this.orderID});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getOrderDetails() {
    return FirebaseFirestore.instance.collection('orders').doc(orderID).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Szczegóły zamówienia")),
      body: FutureBuilder(
        future: _getOrderDetails(),
        builder: (
          ctx,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return buildErrorMessage(context);
          } else {
            return Text(snapshot.data.data().toString());
          }
        },
      ),
    );
  }

  Center buildErrorMessage(BuildContext context) {
    return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Wystąpił błąd z pobraniem danych.\n\nSpróbuj otworzyć stronę ponownie!'),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text("Wyjdź"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          );
  }
}
