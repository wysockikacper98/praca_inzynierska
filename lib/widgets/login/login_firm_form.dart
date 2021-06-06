import 'package:flutter/material.dart';

class LoginFirmForm extends StatelessWidget {
  // const LoginFirmForm({Key? key}) : super(key: key);

  LoginFirmForm(this.submitLoginForm, this.isLoading);

  final void Function(
    String firstName,
    String lastName,
    String telephone,
    String email,
    String password,
    bool isLogin,
  ) submitLoginForm;

  final bool isLoading;


  @override
  Widget build(BuildContext context) {
    return Text("Login Firm Form");
  }
}
