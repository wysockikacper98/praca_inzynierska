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
    final sizeMediaQuery = MediaQuery.of(context).size;
    final width = sizeMediaQuery.width;
    // final height = sizeMediaQuery.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Użytkownika"),
      ),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('users').doc(userID).get(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //TODO: Widok do edycji użytkownika
            // return Center(child: Text(snapshot.data.data().toString()));
            final user = snapshot.data.data();
            return Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orangeAccent.shade100,
                        radius: width * 0.15,
                      ),
                      Positioned(
                        child: IconButton(
                          icon: Icon(
                            Icons.insert_photo,
                            size: width * 0.08,
                          ),
                          onPressed: () {
                            print('Pick new Photo');
                          },
                        ),
                        bottom: 0,
                        right: 0,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Text(
                        user['firstName'] + ' ' + user['lastName'],
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Positioned(
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        right: -40,
                      ),
                    ],
                  ),
                ],
              ),
            );
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
