import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserEditProfileScreen extends StatefulWidget {
  static const routeName = '/user-edit-profile';

  @override
  _UserEditProfileScreenState createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final userID = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Użytkownika"),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(userID).get(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //TODO: Widok do edycji użytkownika
            return Center(child: Text(snapshot.data.data().toString()));
          } else if (snapshot.data == null) {
            return Center(child: Text("User not found"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
