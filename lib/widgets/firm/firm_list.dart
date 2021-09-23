import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'build_firm_info.dart';

Widget createRecommendedFirmList(BuildContext context) {
  getFuture() async {
    return FirebaseFirestore.instance
        .collection('firms')
        .orderBy('rating', descending: true)
        .limit(10)
        .get();
  }

  return FutureBuilder(
    future: getFuture(),
    builder: (ctx, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        final firms = snapshot.data!.docs;
        // print(firms[0].id);
        return Flexible(
          fit: FlexFit.tight,
          child: ListView.builder(
            itemCount: firms.length,
            itemBuilder: (context, index) {
              return buildFirmInfo(context, firms[index]);
            },
          ),
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );
}
