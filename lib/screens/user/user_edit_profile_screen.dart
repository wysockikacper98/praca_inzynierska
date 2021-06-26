import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
                  // Text(snapshot.data.data().toString()),
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: user['avatar'] == ''
                            ? AssetImage('assets/images/user.png')
                            : NetworkImage(user['avatar']),
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
                  RatingBarIndicator(
                    rating: double.parse(user['rating']),
                    itemBuilder: (_, index) =>
                        Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 40.0,
                  ),
                  Text(
                    user['rating'] + ' (' + user['ratingNumber'] + ')',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(height: 15),
                  Text('Imie i Nazwisko:'),
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
                  SizedBox(height: 15),
                  Text('Numer Telefonu:'),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Text(
                        _formatPhoneNumber(user['telephone']),
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

  String _formatPhoneNumber(String phone) {
    String temp = phone.substring(0, 3) +
        '-' +
        phone.substring(3, 6) +
        '-' +
        phone.substring(6);
    return temp;
  }
}
