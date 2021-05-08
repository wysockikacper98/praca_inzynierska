import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("build -> drawer");

    final user = FirebaseAuth.instance.currentUser;
    print('UserID:' + user.uid);
    final Future<DocumentSnapshot> userData =
        FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder(
            future: userData,
            builder: (context, snapshotUserData) {
              if (snapshotUserData.connectionState == ConnectionState.done) {
                return buildUserInfo(
                  context,
                  snapshotUserData.data.data()['firstName'],
                  snapshotUserData.data.data()['email'],
                );
              }
              return buildUserInfo(context);
            },
          ),



        ],
      ),
    );
  }

  Container buildUserInfo(
    BuildContext context, [
    String firstName = '',
    String email = '',
    String avatar =
        'https://firebasestorage.googleapis.com/v0/b/praca-inzynierska-a600c.appspot.com/o/user%20(1).png?alt=media&token=139f0027-4bd3-4a70-8169-207819903975',
  ]) {
    return Container(
      height: 120,
      child: DrawerHeader(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(color: Colors.blue),
        child: Center(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: NetworkImage(avatar),
              radius: 30,
            ),
            title: Text(
              firstName,
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text(email),
            trailing: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                //TODO: Przejście do ustawień użytkownika
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
