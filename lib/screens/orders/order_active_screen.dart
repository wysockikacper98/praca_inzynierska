import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/theme/theme_Provider.dart';
import 'widget/widgets_for_order_screens.dart';

class OrderActiveScreen extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  OrderActiveScreen(this._stream);

  @override
  Widget build(BuildContext context) {
    print('build -> order_active_screen.dart');
    final bool _isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return StreamBuilder(
      stream: _stream,
      builder: (
        ctx,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data != null) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ...snapshot.data!.docs
                    .where((e) => e.data()['status'] != 'COMPLETED')
                    .map((e) => buildOrderListTile(context, e, _isDarkMode))
                    .toList(),
                SizedBox(height: 100),
              ],
            ),
          );
        } else {
          return Center(child: Text('Brak zamówień'));
        }
      },
    );
  }
}
