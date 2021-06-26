import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget imagePicker(user, double width) {
  // PickedFile _pickedImage = null;

  return Stack(
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
          onPressed: _pickImage,
        ),
        bottom: 0,
        right: 0,
      ),
    ],
  );
}

Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedImage = await picker.getImage(source: ImageSource.gallery);
  final pickedImageFile = File(pickedImage.path);
  print(pickedImageFile);

  _pickedImage(pickedImageFile);
}

Future<void> _pickedImage(File image) async {
  final userID = FirebaseAuth.instance.currentUser.uid;
  final ref = FirebaseStorage.instance
      .ref()
      .child('user_avatars')
      .child(userID + '.jpg');
  await ref.putFile(image);
  final url = await ref.getDownloadURL();
  
  await FirebaseFirestore.instance
  .collection('users')
  .doc(userID)
  .update({'avatar':url});
  //TODO: zapisywanie zaktualizowanego użytkownika w SharedPreferences
}
