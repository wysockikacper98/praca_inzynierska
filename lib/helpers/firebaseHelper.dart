import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/sharedPreferences.dart';
import 'package:praca_inzynierska/models/firm.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/screens/messages/messages.dart';

Future<void> loginUser(
  BuildContext context,
  String email,
  String password,
) async {
  //TODO: Delete delay after testing
  print("Star of delay");
  await Future.delayed(const Duration(seconds: 3), () {
    print("End of delay");
  });
  UserCredential authResult;
  try {
    final _auth = FirebaseAuth.instance;
    authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user.uid)
        .get();
    if (!data.exists) {
      data = await FirebaseFirestore.instance
          .collection('firms')
          .doc(authResult.user.uid)
          .get();
    }
    print("Login as User:" + authResult.user.uid);
    print('Login helper:' + data.data().toString());
    await saveUserInfo(Users.fromJson(data.data()));
  } on FirebaseAuthException catch (error) {
    handleFirebaseError(context, error);
  } catch (error) {
    print(error);
  }
}

Future<bool> registerUser(
    BuildContext context, Users user, String userPassword) async {
  //TODO: Delete after testing
  print("Start delay");
  await Future.delayed(Duration(seconds: 3), () {
    print("Stop delay");
  });

  try {
    UserCredential authResult;
    final _auth = FirebaseAuth.instance;
    print("Test Zapisu użytkownika: ${user.toJson()}");
    authResult = await _auth.createUserWithEmailAndPassword(
        email: user.email, password: userPassword);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user.uid)
        .set(user.toJson());

    await saveUserInfo(user);
    return true;
  } on FirebaseAuthException catch (error) {
    handleFirebaseError(context, error);
    return false;
  } catch (error) {
    print(error);
    return false;
  }
}

Future<bool> registerFirm(
    BuildContext context, Firm firm, String password) async {
  //TODO: Delete after testing
  print("Start delay");
  await Future.delayed(Duration(seconds: 3), () {
    print("Stop delay");
  });
  UserCredential authResult;
  final _auth = FirebaseAuth.instance;
  print("Test Zapisu Firmy: ${firm.toJson()}");
  print("Test Zapisu szczegółów: ${firm.details.toJson()}");

  try {
    authResult = await _auth.createUserWithEmailAndPassword(
        email: firm.email, password: password);

    await FirebaseFirestore.instance
        .collection('firms')
        .doc(authResult.user.uid)
        .set(firm.toJson());

    print('Zapisana firma:\n' + firm.toString());
    await saveUserInfo(firm);
    return true;
  } on FirebaseAuthException catch (error) {
    handleFirebaseError(context, error);
    authResult.user.delete();
    return false;
  } catch (error) {
    print(error);
    authResult.user.delete();
    return false;
  }
}

void handleFirebaseError(BuildContext context, FirebaseAuthException error) {
  String errorMessage = "Wystąpił błąd. Proszę sprawedzić dane logowania.";
  if (error.message != null) {
    errorMessage = error.message;
  }
  print(errorMessage);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      duration: Duration(seconds: 3),
      backgroundColor: Theme.of(context).errorColor,
    ),
  );
}

Future<void> createNewChat(BuildContext context, String userID, firmID) async {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');

  chats.add({
    'chatName': userID.substring(0, 4),
    'createdAt': DateTime.now(),
    'users': [userID, firmID]
  }).then((value) {
    print('Added chat with id:${value.id}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Message(
          chatID: value.id,
          chatName: userID.substring(0, 4),
        ),
      ),
    );
  }).catchError((error) => print("Failed to add user: $error"));
}