import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/firebaseHelper.dart';
import 'package:praca_inzynierska/widgets/firm/build_firm_info.dart';

Widget buildFirmListWithFilter() {
  getFirmList();
  return FutureBuilder(
    future: getFirmList(),
    builder: (ctx, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        final firms = snapshot.data.docs;
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
