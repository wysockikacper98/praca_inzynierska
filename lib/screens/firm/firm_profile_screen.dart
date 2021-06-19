import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/firm/build_firm_info.dart';

class FirmsAuth{
  final String uid;
  FirmsAuth(this.uid);
}

class FirmProfileScreen extends StatelessWidget {
  static const routeName = '/firm-profile';

  getDataAboutFirm(uid) async {
    // await Future.delayed(Duration(seconds: 3));
    return FirebaseFirestore.instance.collection('firms').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {

    final data = ModalRoute.of(context).settings.arguments as FirmsAuth;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Wykonawcy"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getDataAboutFirm(data.uid),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFirmInfo(context, snapshot.data),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                  child: Text("O nas", style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                  child: Text(snapshot.data.data()['details']['description'], style: TextStyle()),
                ),

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
