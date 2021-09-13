import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/order.dart';
import 'package:provider/provider.dart';

import '../../models/firm.dart';
import 'search_users.dart';

class CreateOrderScreen extends StatefulWidget {
  static const routeName = '/search-user';

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  DocumentSnapshot _user;
  Order _order;
  var _currentCategory;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerDescription = TextEditingController();

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

    Stream<QuerySnapshot<Map<String, dynamic>>> users = FirebaseFirestore
        .instance
        .collection('users')
        .orderBy('lastName')
        .snapshots();

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Rodzaj usługi:",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    buildDropdownButton(context, provider),
                  ],
                ),
                buildTextFormField(_widthOfWidgets, _controllerTitle),
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
                Row(
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
                              _trySubmit(context);
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
      key: _formKey,
      child: Column(
        children: [
          Container(
            width: _widthOfWidgets,
            child: TextFormField(
              decoration: InputDecoration(labelText: "Ulica i numer"),
              validator: (value) {
                // value.trim();
                if (value.isEmpty) {
                  return 'Pole wymagane';
                }
                return null;
              },
              onSaved: (value) {
                _order.address.streetAndHouseNumber = value;
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
                    _order.address.streetAndHouseNumber = value;
                  },
                ),
              ),
              SizedBox(width: _width * 0.05),
              Container(
                width: _width * 0.5,
                child: TextFormField(
                  decoration: InputDecoration(labelText: "Miejscowość"),
                  validator: (value) {
                    value.trim();
                    if (value.isEmpty) {
                      return 'Pole wymagane';
                    }
                    return null;
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Padding buildTextFormField(double _width, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: _width,
        child: TextFormField(
          controller: controller,
          autocorrect: true,
          decoration: const InputDecoration(
            labelText: 'Tytuł zamówienia',
          ),
        ),
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
      BuildContext context, Stream<QuerySnapshot<Map<String, dynamic>>> users) {
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

  void _trySubmit(BuildContext context) {
    final bool _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState.save();
    }
  }
}
