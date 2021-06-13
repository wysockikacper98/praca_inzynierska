import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/loginHelper.dart';
import 'package:praca_inzynierska/models/users.dart';

class RegisterUserScreen extends StatefulWidget {
  static const routerName = '/register-user';

  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _isLoading = false;

  var _userFirstName = '';
  var _userLastName = '';
  var _userTelephone = '';
  var _userEmail = '';
  var _userPassword = '';

  void _trySubmit(BuildContext context) {
    final _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState.save();

      Users _currentUser = Users(
        firstName: _userFirstName,
        lastName: _userLastName,
        email: _userEmail,
        rating: '',
        telephone: _userTelephone,
        avatar: '',
      );

      registerUser(context, _currentUser, _userPassword).then((value) {
        if (value) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          _passwordController.clear();
          _repeatPasswordController.clear();
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build -> pick_register_screen');

    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                      TextFormField(
                        key: ValueKey('repeatPassword'),
                        controller: _repeatPasswordController,
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
                      if (!_isLoading)
                        ElevatedButton(
                          child: const Text("Zarejestruj"),
                          onPressed: () => _trySubmit(context),
                        ),
                      if (_isLoading) CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
