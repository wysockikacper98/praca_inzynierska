import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/login/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;

  Future<void> _submitLoginForm(
    String email,
    String login,
    String password,
    bool isLogin,
  ) async {
    UserCredential authResult;
    try {
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      var errorMessage = 'Wystąpił błąd. Proszę sprawdzić dane logowania.';
      if (error.message != null) {
        errorMessage = errorMessage;
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build -> login_screen');

    return Scaffold(
      body: LoginForm(_submitLoginForm),
    );
  }
}
