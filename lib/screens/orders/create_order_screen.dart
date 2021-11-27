import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../helpers/firebase_firestore.dart';
import '../../models/address.dart';
import '../../models/firm.dart';
import '../../models/meeting.dart';
import '../../models/notification.dart';
import '../../models/order.dart';
import '../../models/users.dart';
import 'order_details_screen.dart';
import 'orders_screen.dart';
import 'search_users.dart';
import 'widget/alerts_dialog_for_orders.dart';

class CreateOrderScreen extends StatefulWidget {
  static const routeName = '/search-user';

  final String? defaultUser;

  CreateOrderScreen([this.defaultUser]);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  DocumentSnapshot? _user;
  late Stream<QuerySnapshot<Map<String, dynamic>>> users;
  late Address _address;
  late Order _order;
  PickerDateRange? _range;
  Color? _color;
  var _currentCategory;
  bool _isLoading = false;
  bool _showCategoryError = false;
  final _formKey = GlobalKey<FormState>();
  final _formAddressKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.defaultUser != null) initUser(widget.defaultUser!);

    users = FirebaseFirestore.instance
        .collection('users')
        .orderBy('lastName')
        .limit(20)
        .snapshots();
  }

  Future<void> initUser(String userID) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get()
        .then((value) => _setUser(value));
  }

  void _setUser(DocumentSnapshot user) {
    setState(() {
      _user = user;
    });
  }

  void _setRange(PickerDateRange range) {
    if (range.endDate != null && range.startDate != null) {
      print('''
New Range:
Start Date: ${range.startDate}
End Date: ${range.endDate}
''');
      setState(() {
        _range = range;
      });
    } else {
      print(
          'setRange value ignored. (range.endDate or range.startDate are null)');
    }
  }

  void _setColor(Color color) {
    print('New Color: $color');
    setState(() {
      _color = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build -> search_user_screen');
    final provider = Provider.of<FirmProvider>(context, listen: false);
    final _width = MediaQuery.of(context).size.width;
    final _widthOfWidgets = _width * 0.8;

    return GestureDetector(
      onTap: () => unfocusedContext(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Utwórz zamówienie"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                _user != null ? buildUserPreview(_user!) : SizedBox(height: 16),
                buildSearchForUser(context, users),
                SizedBox(height: 10),
                Container(
                  width: _widthOfWidgets,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rodzaj usługi:',
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
                buildDataAndTimePicker(context, _widthOfWidgets, _range),
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.cancel_outlined),
                            label: Text('Anuluj'),
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add_circle_outline_outlined),
                            label: Text('Utwórz'),
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

  void unfocusedContext(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
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
                value!.trim();
                if (value.isEmpty) {
                  return 'Pole wymagane';
                }
                if (value.length < 5) {
                  return 'Tytuł jest za krótki';
                }
                return null;
              },
              onSaved: (value) {
                _order.title = value!.trim();
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
                _order.description = value!.trim();
              },
            ),
          ),
        ],
      ),
    );
  }

  Container buildDataAndTimePicker(
    BuildContext context,
    double _widthOfWidgets,
    PickerDateRange? _range,
  ) {
    return Container(
      width: _widthOfWidgets,
      child: Column(
        children: [
          buildDateRangeText(context, _range),
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.date_range_outlined),
            label: Text(_range != null ? 'Zmień datę' : 'Wybierz datę'),
            onPressed: () {
              unfocusedContext(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => BuildAlertDialogForDatePicker(
                    _setRange,
                    _setColor,
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildDateRangeText(BuildContext context, PickerDateRange? _range) {
    if (_range == null || _range.endDate == null) return Text('Wybierz datę');
    if (_range.startDate!.year != _range.endDate!.year ||
        _range.startDate!.month != _range.endDate!.month ||
        _range.startDate!.day != _range.endDate!.day) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(DateFormat.yMMMMEEEEd('pl_PL').format(_range.startDate!)),
          Icon(Icons.arrow_right_alt),
          Text(DateFormat.yMMMMEEEEd('pl_PL').format(_range.endDate!)),
        ],
      );
    } else {
      return Text(
        DateFormat.Hm('pl_PL').format(_range.startDate!) +
            ' - ' +
            DateFormat.Hm('pl_PL').format(_range.endDate!) +
            ' ' +
            DateFormat.yMMMMEEEEd('pl_PL').format(_range.startDate!),
      );
    }
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
                value = value!.trim();
                if (value.isEmpty) {
                  return 'Pole wymagane';
                }
                if (value.length < 4) {
                  return 'Podaj poprawną wartość';
                }
                return null;
              },
              onSaved: (value) {
                _address.streetAndHouseNumber = value!.trim();
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
                    value!.trim();
                    if (value.isEmpty) {
                      return 'Pole wymagane';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _address.zipCode = value!.trim();
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
                    value!.trim();
                    if (value.isEmpty) {
                      return 'Pole wymagane';
                    }
                    if (value.length < 2) {
                      return 'Podaj poprawną miejscowość';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _address.city = value!.trim();
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
      items: provider.firm!.category!.map((value) {
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

  ElevatedButton buildSearchForUser(
    BuildContext context,
    Stream<QuerySnapshot<Map<String, dynamic>>>? users,
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
    final bool _isAddressFormValid = _formAddressKey.currentState!.validate();
    final bool _isTitleFormValid = _formKey.currentState!.validate();
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
      _formAddressKey.currentState!.save();

      _order = Order(
        firmID: '',
        firmName: '',
        firmAvatar: '',
        userID: '',
        userName: '',
        userAvatar: '',
        title: '',
        status: Status.PENDING,
        category: '',
        description: '',
        dateFrom: null,
        dateTo: null,
        address: _address,
      );
      _formKey.currentState!.save();

      _order.firmID = FirebaseAuth.instance.currentUser!.uid.toString();
      _order.firmName = provider.firm!.firmName;
      _order.firmAvatar = provider.firm!.avatar!;
      _order.userID = _user!.id;
      _order.userName = _user!['firstName'] + ' ' + _user!['lastName'];
      _order.userAvatar = _user!['avatar'];
      _order.category = _currentCategory;
      _order.dateFrom = _range?.startDate;
      _order.dateTo = _range?.endDate;
      print("To jest obiekt to zapisu ${_order.toJson()}");

      await addOrderInFirebase(_order).then((value) async {
        if (_order.dateFrom != null && _order.dateTo != null) {
          Meeting _meeting = Meeting(
              eventName: _order.title,
              orderId: value.id,
              from: _order.dateFrom!,
              to: _order.dateTo!,
              background: _color == null
                  ? Theme.of(context).colorScheme.primary
                  : _color!,
              isAllDay: (_order.dateTo!.day - _order.dateFrom!.day) > 0);

          await addMeetingToUser(
            meeting: _meeting,
            userType: UserType.Firm,
            userID: FirebaseAuth.instance.currentUser!.uid,
          ).catchError((error) {
            print('Failed to add meeting: $error');
          });
        }

        sendPushMessage(
          _user!.id,
          NotificationData(
            title: 'Dodano nowe zamówienie',
            body: _order.title,
          ),
          NotificationDetails(
            name: OrderDetailsScreen.routeName,
            details: value.id,
          ),
        );
      }).catchError((error) {
        print('Failed to add user: $error');
      });

      setState(() {
        _isLoading = false;
      });
      if (widget.defaultUser != null) {
        Navigator.of(context).popAndPushNamed(OrdersScreen.routeName);
      } else {
        Navigator.of(context).pop();
      }
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
