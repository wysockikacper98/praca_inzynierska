import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../helpers/firebase_firestore.dart';
import '../../helpers/regex_patterns.dart';
import 'pick_register_screen.dart';

class LoginFormScreen extends StatefulWidget {
  @override
  _LoginFormScreenState createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  late String _userEmail;
  late String _userPassword;
  bool _isLoading = false;
  bool _passwordVisible = false;

  Future<void> _trySubmit() async {
    setState(() {
      _isLoading = true;
    });

    final _isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      _formKey.currentState!.save();

      await loginUser(context, _userEmail.trim(), _userPassword.trim())
          .then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _passwordController.text = '';
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build -> login_form');
    final double _windowWith = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -160,
                child: Align(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/svg/welcome_cats.svg',
                    width: _windowWith * 0.8,
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: buildLoginForm(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Form buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            key: ValueKey('email'),
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Proszę podać adres email.';
              } else if (!RegExp(RegexPatterns.emailPattern).hasMatch(value)) {
                return 'Proszę podać poprawny adres email.';
              }
              return null;
            },
            onSaved: (value) {
              _userEmail = value!;
            },
          ),
          TextFormField(
            key: ValueKey('password'),
            controller: _passwordController,
            decoration: InputDecoration(
                labelText: 'Hasło',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() {
                    _passwordVisible = !_passwordVisible;
                  }),
                )),
            obscureText: !_passwordVisible,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Proszę podać hasło';
              } else if (value.length < 7) {
                return 'Hasło musi mieć przynajmniej 7 znaków.';
              }
              return null;
            },
            onSaved: (value) {
              _userPassword = value!;
            },
          ),
          SizedBox(height: 20),
          if (!_isLoading)
            ElevatedButton(
              child: Text('Zaloguj się'),
              onPressed: () {
                _trySubmit();
              },
            ),
          if (!_isLoading)
            TextButton(
              child: Text('Zarejestruj się'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).pushNamed(PickRegisterScreen.routerName);
              },
            ),
          if (_isLoading) CircularProgressIndicator(),
        ],
      ),
    );
  }
}
