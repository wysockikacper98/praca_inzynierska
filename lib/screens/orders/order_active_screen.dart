import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'widget/widgets_for_order_screens.dart';

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
            child: Column(
              children: snapshot.data.docs
                  .where((e) =>
                      e.data()['status'] != 'DONE' &&
                      e.data()['status'] != 'TERMINATE')
                  .map((e) => buildOrderListTile(context, e))
                  .toList(),
            ),
          );
        } else {
          return Center(child: Text('No data ¯\\_(ツ)_/¯'));
        }
      },
    );
  }
}
