import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderActiveScreen extends StatelessWidget {
  final Future<QuerySnapshot<Map<String, dynamic>>> _future;

  OrderActiveScreen(this._future);

  @override
  Widget build(BuildContext context) {
    print('build -> order_active_screen.dart');

    return FutureBuilder(
      future: _future,
      builder:
          (ctx, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              children: [
                Text('Still waiting'),
                SizedBox(height: 100),
                CircularProgressIndicator(),
              ],
            ),
          );
        }
        if (snapshot.data != null) {
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: snapshot.data.docs
                    .where((e) =>
                        e.data()['status'] != 'DONE' &&
                        e.data()['status'] != 'TERMINATE')
                    .map((e) {
                  return Column(
                    children: [
                      Text(e.data()['title'] + '\t' + e.data()['status']),
                      SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          return Center(child: Text('No data ¯\\_(ツ)_/¯'));
        }
      },
    );

    return Center(child: Text('Order Active Screen'));
  }
}
