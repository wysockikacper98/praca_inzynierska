import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/firm/edit_firm_form.dart';

class FirmEditProfileScreen extends StatelessWidget {
  static const routeName = '/firm-edit-profile';
  final userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Firmy"),
      ),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('firms').doc(userID).get(),
        // future: getFirmInfoFromFirebase(context, userID),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return Center(child: Text("Firm not found"));
            }
            return EditFirmForm();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
