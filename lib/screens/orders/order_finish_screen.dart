import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'widget/widgets_for_order_screens.dart';

class OrderFinishScreen extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  OrderFinishScreen(this._stream);

  @override
  Widget build(BuildContext context) {
    print('build -> order_finish_screen.dart');

    return StreamBuilder(
      stream: _stream,
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
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  ...snapshot.data!.docs
                      .where((e) => e.data()['status'] == 'COMPLETED')
                      .map((e) => buildOrderListTile(context, e))
                      .toList(),
                  SizedBox(height: 100),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No data ¯\\_(ツ)_/¯'));
        }
      },
    );
  }
}
