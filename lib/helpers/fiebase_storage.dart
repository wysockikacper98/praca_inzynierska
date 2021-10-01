import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/firm.dart';
import 'firebase_firestore.dart';

Future<void> addPictureToFirmProfile(BuildContext context) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
  if (pickedImage == null) return;

  final pickedImageFile = File(pickedImage.path);
  print(pickedImageFile);

  try {
    addPickedImageToStorage(context, pickedImageFile);
  } on FirebaseException catch (e) {
    handleFirebaseException(context, e);
  } catch (e) {
    print(e);
  }
}

Future<void> addPickedImageToStorage(BuildContext context, File image) async {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  final ref = FirebaseStorage.instance
      .ref('firms_images')
      .child(userID)
      .child(Uuid().v4() + '.jpg');
  await ref.putFile(image);
  final url = await ref.getDownloadURL();

  await FirebaseFirestore.instance.collection('firms').doc(userID).update({
    'details.pictures': FieldValue.arrayUnion([url])
  });
  final data =
      await FirebaseFirestore.instance.collection('firms').doc(userID).get();

  Provider.of<FirmProvider>(context, listen: false)
      .updateFirm(Firm.fromJson(data.data()!));
}

Future<void> deleteImageFromStorage(BuildContext context, String url) async {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  String startString = userID + '%2F';
  int start = url.indexOf(startString) + startString.length;
  String fileName = url.substring(start, url.indexOf('.jpg') + 4);

  await FirebaseStorage.instance
      .ref('firms_images')
      .child(userID)
      .child(fileName)
      .delete();
  await FirebaseFirestore.instance.collection('firms').doc(userID).update({
    'details.pictures': FieldValue.arrayRemove([url])
  });

  final data =
      await FirebaseFirestore.instance.collection('firms').doc(userID).get();

  Provider.of<FirmProvider>(context, listen: false)
      .updateFirm(Firm.fromJson(data.data()!));
}
