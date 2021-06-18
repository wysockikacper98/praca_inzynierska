import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/firmRelated/build_firm_info.dart';

Widget createFirmList(BuildContext context) {

  getFuture() async {
    // await Future.delayed(Duration(seconds: 2));
    return FirebaseFirestore.instance.collection('firms').get();
  }

  return FutureBuilder(
    future: getFuture(),
    builder: (ctx, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        final firms = snapshot.data.docs;
        // print("Data"+snapshot.data());
        return ListView.builder(
          //TODO: ListView multiple items in debug purposes
          itemCount: firms.length*4,
          itemBuilder: (context, index) {
            return buildFirmInfo(context, firms[index%3].data());
          },
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );
}
