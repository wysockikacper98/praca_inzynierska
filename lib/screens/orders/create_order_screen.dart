import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/firebaseHelper.dart';
import '../../models/address.dart';
import '../../models/firm.dart';
import '../../models/order.dart';
import 'search_users.dart';

class CreateOrderScreen extends StatefulWidget {
  static const routeName = '/search-user';

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  DocumentSnapshot _user;
  Stream<QuerySnapshot<Map<String, dynamic>>> users;
  Address _address;
  Order _order;
  var _currentCategory;
  bool _isLoading = false;
  bool _showCategoryError = false;
  final _formKey = GlobalKey<FormState>();
  final _formAddressKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    users = FirebaseFirestore.instance
        .collection('users')
        .orderBy('lastName')
        .snapshots();
  }

  void _setUser(DocumentSnapshot user) {
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build -> search_user_screen');
    final provider = Provider.of<FirmProvider>(context, listen: false);
    final _width = MediaQuery.of(context).size.width;
    final _widthOfWidgets = _width * 0.8;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Utwórz zamówienie"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                _user != null ? buildUserPreview(_user) : SizedBox(height: 16),
                buildElevatedButton(context, users),
                SizedBox(height: 10),
                Container(
                  width: _widthOfWidgets,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rodzaj usługi:",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      buildDropdownButton(context, provider),
                    ],
                  ),
                ),
                if (_showCategoryError)
                  Text(
                    'Rozaj usługi jest polem wymaganym',
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                buildTitleAndDescriptionForm(_widthOfWidgets),
                SizedBox(height: 30),
                Container(
                  width: _widthOfWidgets,
                  child: Text(
                    'Adres wykonywanej usługi:',
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: 10),
                buildAddressForm(_widthOfWidgets, _width),
                SizedBox(height: 50),
                buildNewTaskInCalendar(_widthOfWidgets),
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            child: Text("Anuluj"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: Text("Rozpocznij"),
                            onPressed: _user != null
                                ? () {
                                    _trySubmit(context, provider);
                                  }
                                : null,
                          ),
                        ],
                      ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Form buildTitleAndDescriptionForm(double width) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            width: width,
            child: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Tytuł zamówenia',
              ),
              validator: (value) {
                value.trim();
                if (value.isEmpty) {
                  return 'Pole wymagane';
                }
                if (value.length < 5) {
                  return 'Tytuł jest za krótki';
                }
                return null;
              },
              onSaved: (value) {
                _order.title = value.trim();
              },
            ),
          ),
          Container(
            width: width,
            child: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Opis zamównienia',
              ),
              onSaved: (value) {
                _order.description = value.trim();
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildNewTaskInCalendar(double _widthOfWidgets) {
    return Container(
      width: _widthOfWidgets,
      child: Text(
        'Tu będzie wybieranie dat do kalenarza',
        textAlign: TextAlign.center,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
      ),
    );
  }

  Form buildAddressForm(double _widthOfWidgets, double _width) {
    return Form(
      key: _formAddressKey,
      child: Column(
        children: [
          Container(
            width: _widthOfWidgets,
            child: TextFormField(
              decoration: InputDecoration(labelText: "Ulica i numer"),
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                value = value.trim();
                if (value.isEmpty) {
                  return 'Pole wymagane';
                }
                if (value.length < 4) {
                  return 'Podaj poprawną wartość';
                }
                return null;
              },
              onSaved: (value) {
                _address.streetAndHouseNumber = value.trim();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _width * 0.25,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Kod pocztowy"),
                  validator: (value) {
                    value.trim();
                    if (value.isEmpty) {
                      return 'Pole wymagane';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _address.zipCode = value.trim();
                  },
                ),
              ),
              SizedBox(width: _width * 0.05),
              Container(
                width: _width * 0.5,
                child: TextFormField(
                  decoration: InputDecoration(labelText: "Miejscowość"),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    value.trim();
                    if (value.isEmpty) {
                      return 'Pole wymagane';
                    }
                    if (value.length < 5) {
                      return 'Podaj poprawną miejscowość';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _address.city = value.trim();
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  DropdownButton<dynamic> buildDropdownButton(
    BuildContext context,
    FirmProvider provider,
  ) {
    return DropdownButton(
      value: _currentCategory,
      icon: Icon(
        Icons.arrow_downward,
        color: Theme.of(context).colorScheme.secondary,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
      ),
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.secondary,
      ),
      items: provider.firm.category.map((value) {
        return DropdownMenuItem(
          value: value.toString(),
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _currentCategory = newValue;
        });
      },
    );
  }

  ElevatedButton buildElevatedButton(
    BuildContext context,
    Stream<QuerySnapshot<Map<String, dynamic>>> users,
  ) {
    return ElevatedButton.icon(
      icon: Icon(Icons.person_search),
      label: _user != null
          ? Text("Zmień użytkownika")
          : Text("Wybierz użytkownika"),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      onPressed: () {
        showSearch(
          context: context,
          delegate: SearchUsers(users, _setUser),
        );
      },
    );
  }

  Padding buildUserPreview(DocumentSnapshot user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/user.png'),
          foregroundImage:
              user['avatar'] != '' ? NetworkImage(user['avatar']) : null,
        ),
        title: Text(user['firstName'] + ' ' + user['lastName']),
        trailing: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => setState(() {
            _user = null;
          }),
        ),
      ),
    );
  }

  Future<void> _trySubmit(BuildContext context, FirmProvider provider) async {
    final bool _isAddressFormValid = _formAddressKey.currentState.validate();
    final bool _isTitleFormValid = _formKey.currentState.validate();
    final bool _isCategoryValid = validateCategory(_currentCategory);
    FocusScope.of(context).unfocus();

    if (_isAddressFormValid && _isTitleFormValid && _isCategoryValid) {
      setState(() {
        _isLoading = true;
      });

      _address = Address(
        streetAndHouseNumber: '',
        zipCode: '',
        city: '',
      );
      _formAddressKey.currentState.save();

      _order = Order(
        firmID: '',
        firmName: '',
        firmAvatar: '',
        userID: '',
        userName: '',
        userAvatar: '',
        title: '',
        status: Status.PENDING_CONFIRMATION,
        category: '',
        description: '',
        address: _address,
      );
      _formKey.currentState.save();

      _order.firmID = FirebaseAuth.instance.currentUser.uid.toString();
      _order.firmName = provider.firm.firmName;
      _order.firmAvatar = provider.firm.avatar;
      _order.userID = _user.id;
      _order.userName = _user['firstName'] + ' ' + _user['lastName'];
      _order.userAvatar = _user['avatar'];
      _order.category = _currentCategory;

      print("To jest obiekt to zapisu ${_order.toJson()}");

      await addOrderInFirebase(_order);

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
    }
  }

  bool validateCategory(category) {
    if (category == null) {
      setState(() {
        _showCategoryError = true;
      });
      return false;
    } else {
      setState(() {
        _showCategoryError = false;
      });
      return true;
    }
  }
}
