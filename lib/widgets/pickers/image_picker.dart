import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../helpers/colorful_print_messages.dart';
import '../../models/firm.dart';
import '../../models/users.dart';

Widget imagePicker(UserProvider provider, double width) {
  // PickedFile _pickedImage = null;

  return Stack(
    children: [
      CircleAvatar(
        backgroundImage: (provider.user!.avatar == ''
            ? AssetImage('assets/images/user.png')
            : NetworkImage(provider.user!.avatar!)) as ImageProvider<Object>?,
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

Widget imagePickerFirm(
    FirmProvider firmProvider, UserProvider userProvider, double width) {
  return Stack(
    children: [
      CircleAvatar(
        backgroundImage: (firmProvider.firm!.avatar == ''
                ? AssetImage('assets/images/user.png')
                : NetworkImage(firmProvider.firm!.avatar!))
            as ImageProvider<Object>?,
        backgroundColor: Colors.orangeAccent.shade100,
        radius: width * 0.15,
      ),
      Positioned(
        child: IconButton(
          icon: Icon(
            Icons.insert_photo,
            size: width * 0.08,
          ),
          onPressed: () => _pickImageFirm(firmProvider, userProvider),
        ),
        bottom: 0,
        right: 0,
      ),
    ],
  );
}

Future<void> _pickImage(UserProvider provider) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 50,
    maxWidth: 200,
  );
  if (pickedImage == null) return;
  final pickedImageFile = File(pickedImage.path);
  print(pickedImageFile);

  _pickedImage(pickedImageFile, provider);
}

Future<void> _pickImageFirm(
    FirmProvider firmProvider, UserProvider userProvider) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 50,
    maxWidth: 200,
  );
  if (pickedImage == null) return;
  final pickedImageFile = File(pickedImage.path);
  print(pickedImageFile);

  _pickedImageFirm(pickedImageFile, firmProvider, userProvider);
}

Future<void> _pickedImage(File image, UserProvider provider) async {
  final userID = FirebaseAuth.instance.currentUser!.uid;
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

  //start - update zdjecia w wiadomościach
  final QuerySnapshot<Map<String, dynamic>> chats = await FirebaseFirestore
      .instance
      .collection('chats')
      .where('users', arrayContains: userID)
      .get();

  chats.docs.forEach((element) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(element.id)
        .update({'userAvatar': url});
  });
  //end

  //start - update zdjęcia użytkownika w zamówieniach
  final QuerySnapshot<Map<String, dynamic>> orders = await FirebaseFirestore
      .instance
      .collection('orders')
      .where('userID', isEqualTo: userID)
      .get();
  orders.docs.forEach((element) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(element.id)
        .update({'userAvatar': url});
  });
  //end

  final data =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  provider.user = Users.fromJson(data.data()!);
}

Future<void> _pickedImageFirm(
    File image, FirmProvider firmProvider, UserProvider userProvider) async {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  final ref = FirebaseStorage.instance
      .ref()
      .child('user_avatars')
      .child(userID + '.jpg');
  await ref.putFile(image);
  final url = await ref.getDownloadURL();

  await FirebaseFirestore.instance
      .collection('firms')
      .doc(userID)
      .update({'avatar': url});
  //start - update zdjecia firmy w wiadomościach
  final QuerySnapshot<Map<String, dynamic>> chats = await FirebaseFirestore
      .instance
      .collection('chats')
      .where('users', arrayContains: userID)
      .get();

  chats.docs.forEach((element) {
    printColor(
      text: 'Updating firm avatar in chat: ${element.id}',
      color: PrintColor.blue,
    );
    FirebaseFirestore.instance
        .collection('chats')
        .doc(element.id)
        .update({'firmAvatar': url});
  });
  // end

  //start - update zdjecia firmy w zamówieniach
  final QuerySnapshot<Map<String, dynamic>> orders = await FirebaseFirestore
      .instance
      .collection('orders')
      .where('firmID', isEqualTo: userID)
      .get();

  orders.docs.forEach((element) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(element.id)
        .update({'firmAvatar': url});
  });
  //end

  final data =
      await FirebaseFirestore.instance.collection('firms').doc(userID).get();
  firmProvider.firm = Firm.fromJson(data.data()!);
  userProvider.user = Users.fromJson(data.data()!);
}
