
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/sharedPreferences.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';


Future<void> loginUsed(
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
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user.uid)
        .get();
    print("Login as User:" + authResult.user.uid);
    setCurrentUser(Users.fromJson(data.data()));
    saveUserInfo(Users.fromJson(data.data()));

  } on FirebaseAuthException catch (error) {
    handleFirebaseError(context, error);
  } catch (error) {
    print(error);
  }
}


Future<bool> registerUser(BuildContext context,Users user, String userPassword) async {
  //TODO: Delete after testing
  print("Start delay");
  await Future.delayed(Duration(seconds: 3), () {
    print("Stop delay");
  });

  try {
    UserCredential authResult;
    final _auth = FirebaseAuth.instance;

    authResult = await _auth.createUserWithEmailAndPassword(
        email: user.email, password: userPassword);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user.uid)
        .set({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'telephone': user.telephone,
      'email': user.email,
      'avatar': user.avatar,
      'rating': "0",
    });

    setCurrentUser(user);
    print("User saved successfully!!!");
    saveUserInfo(user);
    print(user.toString());
    return true;
  }on FirebaseAuthException catch(error){
    handleFirebaseError(context, error);
    return false;
  }catch(error){
    print(error);
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