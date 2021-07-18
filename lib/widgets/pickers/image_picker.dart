import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:praca_inzynierska/models/users.dart';

Widget imagePicker(UserProvider provider, double width) {
  // PickedFile _pickedImage = null;

  return Stack(
    children: [
      CircleAvatar(
        backgroundImage: provider.user.avatar == ''
            ? AssetImage('assets/images/user.png')
            : NetworkImage(provider.user.avatar),
        backgroundColor: Colors.orangeAccent.shade100,
        radius: width * 0.15,
      ),
      Positioned(
        child: IconButton(
          icon: Icon(
            Icons.insert_photo,
            size: width * 0.08,
          ),
          onPressed: () => _pickImage(provider),
        ),
        bottom: 0,
        right: 0,
      ),
    ],
  );
}

Future<void> _pickImage(UserProvider provider) async {
  final picker = ImagePicker();
  final pickedImage = await picker.getImage(
    source: ImageSource.gallery,
    imageQuality: 50,
    maxWidth: 200,
  );
  if (pickedImage == null) return;
  final pickedImageFile = File(pickedImage.path);
  print(pickedImageFile);

  _pickedImage(pickedImageFile, provider);
}

Future<void> _pickedImage(File image, UserProvider provider) async {
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
      .update({'avatar': url});

  final data =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  provider.user = Users.fromJson(data.data());
}
