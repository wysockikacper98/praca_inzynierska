import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/colorfull_print_messages.dart';

import '../../helpers/firebase_firestore.dart';
import '../firm/build_firm_info.dart';

Widget buildFirmListWithFilter() {
  // getFirmList();
  printColor(text: 'buildFirmListWithFilter', color: PrintColor.red);
  return FutureBuilder(
    future: getFirmList(),
    builder:
        (ctx, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        final firms = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: firms.length * 10,
          itemBuilder: (context, index) {
            return buildFirmInfo(context, firms[index % 3]);
          },
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );
}
