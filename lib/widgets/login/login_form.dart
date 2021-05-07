import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  LoginForm(this.submitFn);

  final void Function(
    String email,
    String login,
    String password,
    bool isLogin,
  ) submitFn;

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  var _isLogin = true;
  var _userEmail = '';
  var _userLogin = '';
  var _userPassword = '';
  var _userRepeatPassword = '';

  void _trySubmit() {
    final _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      _formKey.currentState.save();

      widget.submitFn(
        _userEmail,
        _userLogin,
        _userPassword,
        _isLogin,
      );

      //TODO: sending data to Flutter Database

    }
  }

  @override
  Widget build(BuildContext context) {
    print('build -> login_form');

    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: ValueKey('email'),
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Proszę podać poprawy adres email.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('login'),
                      decoration: InputDecoration(labelText: 'Login'),
                      onSaved: (value) {
                        _userLogin = value;
                      },
                      validator: (value) {
                        if (value.isEmpty || value.length < 4) {
                          return 'Proszę podać przynajmniej 4 znaki.';
                        }
                        return null;
                      },
                    ),
                  TextFormField(
                    key: ValueKey('password'),
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Hasło'),
                    obscureText: true,
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Hasło musi mieć przynajmniej 7 znaków.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('repeatPassword'),
                      decoration: InputDecoration(labelText: 'Powtórz hasło'),
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty || value.length < 7) {
                          return 'Hasło musi mieć przynajmniej 7 znaków.';
                        } else if (value != _passwordController.text) {
                          return 'Hasła muszą być takie same!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userRepeatPassword = value;
                      },
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(_isLogin ? 'Zaloguj' : 'Zarejestruj'),
                    onPressed: _trySubmit,
                  ),
                  TextButton(
                    child: Text(_isLogin ? 'Zarejestruj się' : 'Zaloguj się'),
                    style: TextButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
