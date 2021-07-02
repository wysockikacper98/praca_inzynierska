import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/widgets/pickers/image_picker.dart';
import 'package:provider/provider.dart';

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
    final provider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Użytkownika"),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text(snapshot.data.data().toString()),
            SizedBox(height: 20),
            imagePicker(provider, width),
            SizedBox(height: 15),
            RatingBarIndicator(
              rating: double.parse(provider.user.rating),
              itemBuilder: (_, index) => Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 40.0,
            ),
            Text(
              provider.user.rating + ' (' + provider.user.ratingNumber + ')',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 15),
            Text('Imie i Nazwisko:'),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Text(
                  provider.user.firstName + ' ' + provider.user.lastName,
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
                  _formatPhoneNumber(provider.user.telephone),
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
