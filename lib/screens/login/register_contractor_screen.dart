import 'package:flutter/material.dart';

import '../../helpers/firebaseHelper.dart';
import '../../models/details.dart';
import '../../models/firm.dart';
import '../../models/users.dart';

class RegisterContractorScreen extends StatefulWidget {
  static const routeName = '/register-contractor';
  Map<String, bool> _categoriesMap;

  RegisterContractorScreen({List categories}) {
    _categoriesMap = Map.fromIterable(
      categories,
      key: (item) => item.toString(),
      value: (item) => false,
    );
  }

  @override
  _RegisterContractorScreenState createState() =>
      _RegisterContractorScreenState();
}

class _RegisterContractorScreenState extends State<RegisterContractorScreen> {
  var _countSelected = 0;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _scrollController = ScrollController();

  Firm _firm = Firm(
    firmName: "",
    firstName: "",
    lastName: "",
    telephone: "",
    email: "",
    location: "",
    range: "",
    nip: "",
    avatar: "",
    rating: '0',
    ratingNumber: '0',
    category: [],
    type: UserType.Firm,
    details: Details(
        pictures: List.empty(),
        calendar: "Not implemented yet ¯\\_(ツ)_/¯",
        prices: "Brak informacji",
        description: "Dodaj opis firmy"),
  );
  String _userPassword;

  bool _isLoading = false;
  bool _pickCategory = true;

  void _trySubmit(BuildContext context) {
    final _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState.save();

      widget._categoriesMap.forEach((key, value) {
        if (value) {
          _firm.category.add(key);
        }
      });

      registerFirm(context, _firm, _userPassword).then((value) {
        print("Wynik zapisania użytkownika:$value");
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
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Rejestracja jako wykonawca',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(height: 20),
                    if (_pickCategory)
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Zaznacz, czym się zajmujesz:',
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    SizedBox(height: 20),
                    _pickCategory
                        ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget._categoriesMap.length,
                            itemBuilder: (context, index) {
                              String key =
                                  widget._categoriesMap.keys.elementAt(index);
                              return CheckboxListTile(
                                  value: widget._categoriesMap[key],
                                  title: Text("$key"),
                                  onChanged: (value) {
                                    setState(() {
                                      widget._categoriesMap[key] = value;
                                      if (value) {
                                        _countSelected++;
                                      } else {
                                        _countSelected--;
                                      }
                                    });
                                  });
                            },
                          )
                        : Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'Nazwa firmy lub Wykonawcy'),
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Pole wymagane';
                                    } else if (value.length < 3) {
                                      return 'Nazwa za krótka';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _firm.firmName = value;
                                  },
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'Imie właściciela'),
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Pole wymagane';
                                    } else if (value.length < 3) {
                                      return 'Imie za krótkie';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _firm.firstName = value;
                                  },
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'Nazwisko właściciela'),
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Pole wymagane';
                                    } else if (value.length < 3) {
                                      return 'Nazwisko za krótkie';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _firm.lastName = value;
                                  },
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                      labelText: 'Nr. Telefonu'),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (int.tryParse(value) == null) {
                                      return 'Podaj numer telefonu';
                                    } else if (value.isEmpty) {
                                      return 'Pole wymagane';
                                    } else if (value.length < 9) {
                                      return 'Podaj poprawny numer telefonu';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _firm.telephone = value;
                                  },
                                ),
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Email'),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value.isEmpty || !value.contains('@')) {
                                      return 'Proszę podać poprawy adres email.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _firm.email = value;
                                  },
                                ),
                                TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Lokalizacja'),
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Pole wymagane';
                                    } else if (value.length < 4) {
                                      return 'Podaj poprawną nazwę miejscowości';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _firm.location = value;
                                  },
                                ),
                                // TextFormField(
                                //   decoration: InputDecoration(
                                //       labelText:
                                //           'Zasięg prowadzonych usług w km od lokalizacji'),
                                //   keyboardType: TextInputType.number,
                                //   validator: (value) {
                                //     if (int.tryParse(value) == null) {
                                //       return 'Podaj numer';
                                //     }
                                //     return null;
                                //   },
                                //   onSaved: (value) {
                                //     _firm.range = value;
                                //   },
                                // ),
                                TextFormField(
                                  decoration: InputDecoration(labelText: 'NIP'),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (int.tryParse(value) == null) {
                                      return 'Podaj numer';
                                    } else if (value.length != 10) {
                                      return 'Podano niepoprawny numer NIP';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _firm.nip = value;
                                  },
                                ),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration:
                                      InputDecoration(labelText: 'Hasło'),
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
                                  controller: _repeatPasswordController,
                                  decoration: InputDecoration(
                                      labelText: 'Powtórz hasło'),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value.isEmpty || value.length < 7) {
                                      return 'Hasło musi mieć przynajmniej 7 znaków.';
                                    } else if (value !=
                                        _passwordController.text) {
                                      return 'Hasła muszą być takie same!';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 20),
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            child: const Text("Cofnij"),
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).colorScheme.secondary),
                            onPressed: _pickCategory
                                ? () => Navigator.of(context).pop()
                                : () {
                                    _scrollController.animateTo(
                                      0,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                    setState(() {
                                      _pickCategory = !_pickCategory;
                                    });
                                  },
                          ),
                          if (_pickCategory)
                            ElevatedButton(
                              child: Text('Dalej ($_countSelected)'),
                              onPressed: _countSelected == 0
                                  ? null
                                  : () {
                                      _scrollController.animateTo(
                                        0,
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                      setState(() {
                                        _pickCategory = !_pickCategory;
                                      });
                                    },
                            ),
                          if (!_pickCategory)
                            ElevatedButton(
                              child: Text("Zarejestruj"),
                              onPressed: () {
                                _trySubmit(context);
                              },
                            )
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
    );
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
  }
}
