import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  LoginForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;

  final void Function(
    String firstName,
    String lastName,
    String telephone,
    String email,
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
  var _userFirstName = '';
  var _userLastName = '';
  var _userTelephone = '';
  var _userEmail = '';
  var _userPassword = '';

  void _trySubmit() {
    final _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      _formKey.currentState.save();

      widget.submitFn(
        _userFirstName.trim(),
        _userLastName.trim(),
        _userTelephone.trim(),
        _userEmail.trim(),
        _userPassword.trim(),
        _isLogin,
      );
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
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('imie'),
                      decoration: InputDecoration(labelText: 'Imie'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 3) {
                          return 'Proszę podać przynajmniej 3 znaki.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userFirstName = value;
                      },
                    ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('nazwisko'),
                      decoration: InputDecoration(labelText: 'Nazwisko'),
                      validator: (value) {
                        if (value.isEmpty || value.length < 3) {
                          return 'Proszę podać przynajmniej 3 znaki.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userLastName = value;
                      },
                    ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('telephone'),
                      decoration: InputDecoration(labelText: 'Nr. Telefonu'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        value = value.replaceAll(' ', '');
                        if (int.tryParse(value) == null) {
                          return 'Podaj numer telefonu';
                        } else if (value.isEmpty || value.length < 9) {
                          return 'Podaj poprawny numer telefonu';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userTelephone = value;
                      },
                    ),
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
                    ),
                  SizedBox(height: 20),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    ElevatedButton(
                      child: Text(_isLogin ? 'Zaloguj' : 'Zarejestruj'),
                      onPressed: _trySubmit,
                    ),
                  if (!widget.isLoading)
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
