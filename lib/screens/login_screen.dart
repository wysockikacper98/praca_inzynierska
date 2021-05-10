import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/login/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  Future<void> _submitLoginForm(
    String firstName,
    String lastName,
    String telephone,
    String email,
    String password,
    bool isLogin,
  ) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("Zapis użytkownika");
        await saveUserInfo(authResult.user.uid);
        _isLoading = false;
      } else {
        //Create new User
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'telephone': telephone,
          'email': email,
          'avatar': '',
          'rating': "0",
        });
        // //udane utoworznie konta
        // final user =
        //     Users(firstName: firstName, email: email, lastName: lastName);
        // SharedPreferences user_shared = await SharedPreferences.getInstance();
        // user_shared.setString('user', jsonEncode(user));
        //
        // SharedPreferences get_User = await SharedPreferences.getInstance();
        // print("Wyświetlanie nowego użytkownika");
        // print(get_User.getString('user'));
        // Map userMap = jsonDecode(get_User.getString('user'));
        // var userek = Users.fromJson(userMap);
        //
        // print("FirstName:" +
        //     userek.firstName +
        //     "\nLastName:" +
        //     userek.lastName +
        //     "\nEmail:" +
        //     userek.email);

        await saveUserInfo(authResult.user.uid);
        _isLoading = false;
      }
    } on FirebaseAuthException catch (error) {
      var errorMessage = 'Wystąpił błąd. Proszę sprawdzić dane logowania.';
      if (error.message != null) {
        errorMessage = error.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 3),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build -> login_screen');
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.hasData) {
          return HomeScreen();
        } else {
          return Scaffold(body: LoginForm(_submitLoginForm, _isLoading));
        }
      },
    );

  }

  Future<void> saveUserInfo(String uid) async {
    print("saveUserInfo");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    final data =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    var tempUser = Users.fromJson(data.data());

    sharedPreferences.setString('user', jsonEncode(tempUser));
  }
}
