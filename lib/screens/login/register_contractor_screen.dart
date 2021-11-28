import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../helpers/colorfull_print_messages.dart';
import '../../helpers/firebase_firestore.dart';
import '../../helpers/regex_patterns.dart';
import '../../models/address.dart';
import '../../models/details.dart';
import '../../models/firm.dart';
import '../../models/useful_data.dart';
import '../../models/users.dart';

class RegisterContractorScreen extends StatefulWidget {
  static const routeName = '/register-contractor';

  @override
  _RegisterContractorScreenState createState() =>
      _RegisterContractorScreenState();
}

class _RegisterContractorScreenState extends State<RegisterContractorScreen> {
  int _currentStep = 0;
  int _categoriesSelected = 0;

  final _formFirmInfoKey = GlobalKey<FormState>();
  final _formOwnerInfoKey = GlobalKey<FormState>();
  final _formLoginInfoKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _scrollController = ScrollController();

  late final Map<String, bool> _categoriesMap;

  @override
  void initState() {
    super.initState();
    _categoriesMap = Map.fromIterable(
      Provider.of<UsefulData>(context, listen: false).categoriesList,
      key: (item) => item.toString(),
      value: (item) => false,
    );
  }

  Firm _firm = Firm(
    firmName: '',
    firstName: '',
    lastName: '',
    telephone: '',
    email: '',
    address: Address.empty(),
    range: '',
    nip: '',
    avatar: '',
    rating: 0.0,
    ratingNumber: 0.0,
    category: [],
    type: UserType.Firm,
    details: Details(
        pictures: List.empty(),
        prices: "Brak informacji",
        description: "Dodaj opis firmy"),
  );

  late String _userPassword;

  bool _isLoading = false;

  void setLoading(bool value) {
    return setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stepper(
          type: StepperType.vertical,
          physics: ScrollPhysics(),
          currentStep: _currentStep,
          controlsBuilder: (BuildContext context,
              {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        ElevatedButton(
                          child: _currentStep == 4
                              ? Text('Zarejestruj')
                              : Text('Dalej'),
                          onPressed:
                              _categoriesSelected > 0 ? onStepContinue : null,
                        ),
                        TextButton(
                          child: const Text('Anuluj'),
                          onPressed: onStepCancel,
                        ),
                      ],
                    ),
            );
          },
          onStepTapped: tapped,
          onStepContinue: continued,
          onStepCancel: cancel,
          steps: [
            Step(
              title: const Text('Kategorie'),
              subtitle: const Text('Zaznacz czym zajmuje się twoja firma.'),
              isActive: _currentStep >= 0,
              state: _currentStep == 0 ? StepState.editing : StepState.complete,
              content: buildCategories(context),
            ),
            Step(
              title: const Text('Dane firmy'),
              isActive: _currentStep >= 1,
              state: _currentStep == 1
                  ? StepState.editing
                  : _currentStep > 1
                      ? StepState.complete
                      : StepState.disabled,
              content: Form(
                key: _formFirmInfoKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Nazwa firmy lub Wykonawcy'),
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(RegexPatterns.nameOrSurnamePattern),
                        ),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Pole wymagane';
                        } else if (value.length < 3) {
                          return 'Nazwa za krótka';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _firm.firmName = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'NIP'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            RegexPatterns.nipNumberPattern,
                          ),
                        ),
                      ],
                      validator: (value) {
                        if (int.tryParse(value!) == null) {
                          return 'Podaj numer';
                        } else if (value.length != 10) {
                          return 'Podano niepoprawny numer NIP';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _firm.nip = value!;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Step(
              title: Text('Dane właściciela firmy'),
              isActive: _currentStep >= 2,
              state: _currentStep == 2
                  ? StepState.editing
                  : _currentStep > 2
                      ? StepState.complete
                      : StepState.disabled,
              content: Form(
                key: _formOwnerInfoKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Imie właściciela'),
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(RegexPatterns.nameOrSurnamePattern),
                        ),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Pole wymagane';
                        } else if (value.length < 3) {
                          return 'Imie za krótkie';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _firm.firstName = value!;
                      },
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: 'Nazwisko właściciela'),
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(RegexPatterns.nameOrSurnamePattern),
                        ),
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Pole wymagane';
                        } else if (value.length < 3) {
                          return 'Nazwisko za krótkie';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _firm.lastName = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Nr. Telefonu'),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        MaskedInputFormatter('000-000-000'),
                      ],
                      validator: (value) {
                        value = value!.replaceAll(RegExp('[-\s]'), '');
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
                  ],
                ),
              ),
            ),
            Step(
              title: Text('Dane Logowania'),
              isActive: _currentStep >= 3,
              state: _currentStep == 3
                  ? StepState.editing
                  : _currentStep > 3
                      ? StepState.complete
                      : StepState.disabled,
              content: Form(
                key: _formLoginInfoKey,
                child: Column(
                  children: [
                    TextFormField(
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
                        _firm.email = value!;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Hasło'),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Hasło musi mieć przynajmniej 7 znaków.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userPassword = value!;
                      },
                    ),
                    TextFormField(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    switch (_currentStep) {
      case 0:
        setState(() => _currentStep++);
        break;
      case 1:
        final bool _isFirmInfoValid = _formFirmInfoKey.currentState!.validate();
        FocusScope.of(context).unfocus();

        if (_isFirmInfoValid) {
          _formFirmInfoKey.currentState!.save();
          setState(() => _currentStep++);
        }
        break;
      case 2:
        final bool _isOwnerInfoValid =
            _formOwnerInfoKey.currentState!.validate();
        FocusScope.of(context).unfocus();

        if (_isOwnerInfoValid) {
          _formOwnerInfoKey.currentState!.save();
          setState(() => _currentStep++);
        }
        break;
      case 3:
        final bool _isLoginInfoValid =
            _formLoginInfoKey.currentState!.validate();
        FocusScope.of(context).unfocus();

        if (_isLoginInfoValid) {
          setLoading(true);
          _formLoginInfoKey.currentState!.save();

          _firm.category = [];
          _categoriesMap.forEach((key, value) {
            if (value) _firm.category!.add(key);
          });

          printColor(text: _firm.toString(), color: PrintColor.cyan);

          registerFirm(context, _firm, _userPassword, setLoading).then((value) {
            printColor(
                text: 'Wynik zapisania użytkownika:$value',
                color: PrintColor.cyan);

            if (value) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else {
              _passwordController.clear();
              _repeatPasswordController.clear();
            }
            if (mounted) {
              setLoading(false);
            }
          });
        }
        break;
    }
  }

  cancel() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
    } else if (_currentStep == 3) {
      _passwordController.clear();
      _repeatPasswordController.clear();
      setState(() => _currentStep--);
    } else {
      setState(() => _currentStep--);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
  }

  Widget buildCategories(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      child: Container(
        width: double.infinity,
        child: Wrap(
          spacing: 5.0,
          children: buildChips(),
        ),
      ),
    );
  }

  List<Widget> buildChips() {
    List<Widget> list = [];

    _categoriesMap.forEach((key, value) {
      list.add(
        InputChip(
          showCheckmark: true,
          selected: value,
          label: Text(
            key,
            style: TextStyle(fontSize: 12.0),
          ),
          onSelected: (bool newValue) {
            setState(() {
              newValue ? _categoriesSelected++ : _categoriesSelected--;
              _categoriesMap.update(key, (value) => newValue);
            });
          },
        ),
      );
    });
    return list;
  }
}
