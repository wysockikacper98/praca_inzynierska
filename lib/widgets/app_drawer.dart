import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("build -> drawer");

    final user = FirebaseAuth.instance.currentUser;

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
                final user = snapshotUserData.data()
                return buildUserInfo(
                  context,
                  snapshotUserData.data.data()['firstName'],
                  snapshotUserData.data.data()['email'],
                );
              }
              return buildUserInfo(context);
            },
          ),
          Divider(
            thickness: 1,
            height: 25,
          ),
          ListTile(
            leading: Icon(
              Icons.home_outlined,
              size: 40,
            ),
            title: Center(
              child: Text(
                "Strona główna",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              //TODO: Go to screen

              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(
            thickness: 1,
            height: 25,
          ),
          ListTile(
            leading: Icon(
              Icons.email_outlined,
              size: 40,
            ),
            title: Center(
              child: Text(
                "Wiadomości",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              //TODO: Go to screen

              Navigator.of(context).pop();
            },
          ),
          Divider(
            thickness: 1,
            height: 25,
          ),
          ListTile(
            leading: Icon(
              Icons.search,
              size: 40,
            ),
            title: Center(
              child: Text(
                "Wyszukiwarka",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              //TODO: Go to screen

              Navigator.of(context).pop();
            },
          ),
          Divider(
            thickness: 1,
            height: 25,
          ),
          ListTile(
            leading: Icon(
              Icons.warning_amber_outlined,
              size: 40,
            ),
            title: Center(
              child: Text(
                "Awarie",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
            onTap: () {
              //TODO: Go to screen

              Navigator.of(context).pop();
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
              style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
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
