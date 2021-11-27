import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';

import '../../helpers/firebase_firestore.dart';
import '../../helpers/regex_patterns.dart';
import '../../models/users.dart';

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

  late String _userFirstName;
  late String _userLastName;
  late String _userTelephone;
  late String _userEmail;
  late String _userPassword;

  void _trySubmit(BuildContext context) {
    final _isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState!.save();

      Users _currentUser = Users(
        firstName: _userFirstName,
        lastName: _userLastName,
        email: _userEmail,
        rating: 0,
        ratingNumber: 0,
        telephone: _userTelephone,
        avatar: '',
        type: UserType.PrivateUser,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(RegexPatterns.nameOrSurnamePattern),
                          ),
                        ],
                        validator: (value) {
                          if (value!.isEmpty)
                            return 'Pole imie jest wymagane';
                          else if (value.length < 3) {
                            return 'Podane imie jest za krótkie';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userFirstName = value!;
                        },
                      ),
                      TextFormField(
                        key: ValueKey('nazwisko'),
                        decoration: InputDecoration(labelText: 'Nazwisko'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(RegexPatterns.nameOrSurnamePattern),
                          ),
                        ],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Pole jest wymagane';
                          } else if (value.length < 3) {
                            return 'Proszę podać przynajmniej 3 znaki.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userLastName = value!;
                        },
                      ),
                      // TODO: Dodać osobne pole na numer kierunkowy
                      TextFormField(
                        key: ValueKey('telephone'),
                        decoration: InputDecoration(labelText: 'Nr. Telefonu'),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          MaskedInputFormatter('000-000-000'),
                        ],
                        validator: (value) {
                          value = value!.replaceAll(RegExp('[-\s]'), '');
                          if (int.tryParse(value) == null) {
                            return 'Podaj numer telefonu';
                          } else if (value.isEmpty || value.length < 9) {
                            return 'Podaj poprawny numer telefonu';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userTelephone = value!;
                        },
                      ),
                      TextFormField(
                        key: ValueKey('email'),
                        decoration: InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Adres e-mail jest wymagany';
                          } else if (!RegExp(RegexPatterns.emailPattern)
                              .hasMatch(value)) {
                            return 'Podany adres e-mail jest nie poprawny';
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
                        decoration: InputDecoration(labelText: 'Hasło'),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Hasło jest wymagane';
                          } else if (value.length < 7) {
                            return 'Hasło musi mieć przynajmniej 7 znaków.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userPassword = value!;
                        },
                      ),
                      TextFormField(
                        key: ValueKey('repeatPassword'),
                        controller: _repeatPasswordController,
                        decoration: InputDecoration(labelText: 'Powtórz hasło'),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Hasło jest wymagane';
                          } else if (value.length < 7) {
                            return 'Hasło musi mieć przynajmniej 7 znaków.';
                          } else if (value != _passwordController.text) {
                            return 'Hasła muszą być takie same!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      if (!_isLoading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              child: const Text("Cofnij"),
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      Theme.of(context).colorScheme.secondary),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            ElevatedButton(
                              child: const Text("Zarejestruj"),
                              onPressed: () => _trySubmit(context),
                            ),
                          ],
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
