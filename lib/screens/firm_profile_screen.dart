import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/firmRelated/build_firm_info.dart';

class FirmProfileScreen extends StatelessWidget {
  static const routeName = '/firm-profile';

  final uid = FirebaseAuth.instance.currentUser.uid;

  getDataAboutFirm() async {
    // await Future.delayed(Duration(seconds: 3));
    return FirebaseFirestore.instance.collection('firms').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Wykonawcy"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getDataAboutFirm(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFirmInfo(context, snapshot.data.data()),
                Text("O nas"),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
