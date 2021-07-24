import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:praca_inzynierska/helpers/firebaseHelper.dart';
import 'package:praca_inzynierska/models/firm.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/widgets/pickers/image_picker.dart';
import 'package:provider/provider.dart';

class EditFirmForm extends StatefulWidget {
  @override
  _EditFirmFormState createState() => _EditFirmFormState();
}

class _EditFirmFormState extends State<EditFirmForm> {
  final _formFirmNameKey = GlobalKey<FormState>();
  final _formNameAndSurnameKey = GlobalKey<FormState>();
  final _formPhoneNumberKey = GlobalKey<FormState>();
  final _formLocationKey = GlobalKey<FormState>();

  bool _editFirmName = false;
  bool _editNameAndSurname = false;
  bool _editPhoneNumber = false;
  bool _editLocation = false;

  bool _isLoading = false;

  var _firmNameController = TextEditingController();
  var _nameController = TextEditingController();
  var _surnameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _locationController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _firmNameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
  }

  String _firmName;
  String _name;
  String _surname;
  String _phone;
  String _location;

  Future<void> _trySubmit(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    final firmProvider = Provider.of<FirmProvider>(context, listen: false);
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    final _isValid = formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });

      formKey.currentState.save();

      Firm updatedFirm = firmProvider.firm;

      //update Firm
      if (_firmName != null) {
        updatedFirm.firmName = _firmName;
      }
      if (_name != null && _surname != null) {
        updatedFirm.firstName = _name;
        updatedFirm.lastName = _surname;
      }
      if (_phone != null) {
        updatedFirm.telephone = _phone;
      }
      if(_location != null){
        updatedFirm.location = _location;
      }

      await updateFirmInFirebase(context, updatedFirm);

      firmProvider.firm = updatedFirm;

      setState(() {
        _isLoading = false;
        _editFirmName = false;
        _editNameAndSurname = false;
        _editPhoneNumber = false;
        _editLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmProvider = Provider.of<FirmProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final sizeMediaQuery = MediaQuery.of(context).size;
    final width = sizeMediaQuery.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 15),
          imagePickerFirm(firmProvider, userProvider, width),
          SizedBox(height: 15),
          RatingBarIndicator(
            rating: double.parse(userProvider.user.rating),
            itemBuilder: (_, index) => Icon(Icons.star, color: Colors.amber),
            itemCount: 5,
            itemSize: 40.0,
          ),
          Text(
            firmProvider.firm.rating +
                ' (' +
                firmProvider.firm.ratingNumber +
                ')',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 15),
          ListTile(
            title: Text("Nazwa Firmy:"),
            trailing: IconButton(
              color: _editFirmName
                  ? Theme.of(context).errorColor
                  : Theme.of(context).primaryColor,
              icon: _editFirmName ? Icon(Icons.close) : Icon(Icons.edit),
              onPressed: () {
                if (!_editFirmName)
                  _firmNameController.text = firmProvider.firm.firmName;
                setState(() {
                  _editFirmName = !_editFirmName;
                });
              },
            ),
          ),
          !_editFirmName
              ? Text(
                  firmProvider.firm.firmName,
                  style: Theme.of(context).textTheme.headline6,
                )
              : Form(
                  key: _formFirmNameKey,
                  child: Column(
                    children: [
                      Container(
                        width: width * 0.80,
                        child: TextFormField(
                          key: ValueKey("firmName"),
                          controller: _firmNameController,
                          decoration: InputDecoration(
                            hintText: "Nazwa Firmy",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _firmNameController.clear,
                            ),
                          ),
                          validator: (value) {
                            value = value.trim();

                            if (value.isEmpty || value.length < 3) {
                              return 'Proszę podać przynajmniej 3 znaki.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            value = value.trim();

                            _firmName = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              child: SizedBox(
                                width: width * 0.8,
                                child: Text(
                                  "Zapisz",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onPressed: () {
                                _trySubmit(
                                  context,
                                  _formFirmNameKey,
                                );
                              },
                            ),
                    ],
                  ),
                ),
          ListTile(
            title: Text("Właściciel:"),
            trailing: IconButton(
              color: _editNameAndSurname
                  ? Theme.of(context).errorColor
                  : Theme.of(context).primaryColor,
              icon: _editNameAndSurname ? Icon(Icons.close) : Icon(Icons.edit),
              onPressed: () {
                if (!_editNameAndSurname) {
                  _nameController.text = firmProvider.firm.firstName;
                  _surnameController.text = firmProvider.firm.lastName;
                }
                setState(() {
                  _editNameAndSurname = !_editNameAndSurname;
                });
              },
            ),
          ),
          !_editNameAndSurname
              ? Text(
                  firmProvider.firm.firstName +
                      " " +
                      firmProvider.firm.lastName,
                  style: Theme.of(context).textTheme.headline6,
                )
              : Form(
                  key: _formNameAndSurnameKey,
                  child: Column(
                    children: [
                      Container(
                        width: width * 0.80,
                        child: TextFormField(
                          key: ValueKey("firmName"),
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Nazwa Firmy",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _nameController.clear,
                            ),
                          ),
                          validator: (value) {
                            value = value.trim();

                            if (value.isEmpty || value.length < 3) {
                              return 'Proszę podać przynajmniej 3 znaki.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            value = value.trim();

                            _name = value;
                          },
                        ),
                      ),
                      Container(
                        width: width * 0.80,
                        child: TextFormField(
                          key: ValueKey("firmName"),
                          controller: _surnameController,
                          decoration: InputDecoration(
                            hintText: "Nazwa Firmy",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _surnameController.clear,
                            ),
                          ),
                          validator: (value) {
                            value = value.trim();
                            if (value.isEmpty || value.length < 3) {
                              return 'Proszę podać przynajmniej 3 znaki.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            value = value.trim();
                            _surname = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              child: SizedBox(
                                width: width * 0.8,
                                child: Text(
                                  "Zapisz",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onPressed: () {
                                _trySubmit(
                                  context,
                                  _formNameAndSurnameKey,
                                );
                              },
                            ),
                    ],
                  ),
                ),
          SizedBox(height: 15),
          ListTile(
            title: Text("Numer Telefonu:"),
            trailing: IconButton(
              color: _editPhoneNumber
                  ? Theme.of(context).errorColor
                  : Theme.of(context).primaryColor,
              icon: _editPhoneNumber ? Icon(Icons.close) : Icon(Icons.edit),
              onPressed: () {
                if (!_editPhoneNumber) {
                  _phoneController.text = firmProvider.firm.telephone;
                }
                setState(() {
                  _editPhoneNumber = !_editPhoneNumber;
                });
              },
            ),
          ),
          !_editPhoneNumber
              ? Text(
                  _formatPhoneNumber(firmProvider.firm.telephone),
                  style: Theme.of(context).textTheme.headline6,
                )
              : Form(
                  key: _formPhoneNumberKey,
                  child: Column(
                    children: [
                      Container(
                        width: width * 0.80,
                        child: TextFormField(
                          key: ValueKey("phone"),
                          controller: _phoneController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Numer Telefonu",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _phoneController.clear,
                            ),
                          ),
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
                            _phone = value.replaceAll(' ', '');
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              child: SizedBox(
                                width: width * 0.8,
                                child: Text(
                                  "Zapisz",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onPressed: () {
                                _trySubmit(
                                  context,
                                  _formPhoneNumberKey,
                                );
                              },
                            ),
                    ],
                  ),
                ),
          SizedBox(height: 15),
          ListTile(
            title: Text("Lokalizacja:"),
            trailing: IconButton(
              color: _editLocation
                  ? Theme.of(context).errorColor
                  : Theme.of(context).primaryColor,
              icon: _editLocation ? Icon(Icons.close) : Icon(Icons.edit),
              onPressed: () {
                if (!_editLocation) {
                  _locationController.text = firmProvider.firm.location;
                }
                setState(() {
                  _editLocation = !_editLocation;
                });
              },
            ),
          ),
          !_editLocation
              ? Text(
                  firmProvider.firm.location,
                  style: Theme.of(context).textTheme.headline6,
                )
              : Form(
                  key: _formLocationKey,
                  child: Column(
                    children: [
                      Container(
                        width: width * 0.80,
                        child: TextFormField(
                          key: ValueKey("location"),
                          controller: _locationController,
                          decoration: InputDecoration(
                            hintText: "Lokalizacja",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _locationController.clear,
                            ),
                          ),
                          validator: (value) {
                            value = value.trim();

                            if (value.isEmpty || value.length < 3) {
                              return 'Proszę podać przynajmniej 3 znaki.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _location = value.trim();
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              child: SizedBox(
                                width: width * 0.8,
                                child: Text(
                                  "Zapisz",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onPressed: () {
                                _trySubmit(
                                  context,
                                  _formLocationKey,
                                );
                              },
                            ),
                    ],
                  ),
                ),
          SizedBox(height: 15),
          Text(firmProvider.firm.toString()),
        ],
      ),
    );
  }
}

String _formatPhoneNumber(String phone) {
  String temp = phone.substring(0, 3) +
      '-' +
      phone.substring(3, 6) +
      '-' +
      phone.substring(6);
  return temp;
}
