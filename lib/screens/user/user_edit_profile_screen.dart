import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:praca_inzynierska/helpers/firebaseHelper.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/widgets/pickers/image_picker.dart';
import 'package:provider/provider.dart';

class UserEditProfileScreen extends StatefulWidget {
  static const routeName = '/user-edit-profile';

  @override
  _UserEditProfileScreenState createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final userID = FirebaseAuth.instance.currentUser.uid;
  final _formKey = GlobalKey<FormState>();

  bool _userNameEdit = false;
  bool _userPhoneEdit = false;
  bool _isLoading = false;

  var _nameController = TextEditingController();
  var _surnameController = TextEditingController();
  var _phoneController = TextEditingController();

  var _name;
  var _surname;
  var _phone;

  Future<void> _trySubmit(BuildContext context, UserProvider provider, ) async {
    final _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState.save();
      print("Name:"+_name.toString());
      print("Surname:"+_surname.toString());
      print("Phone:"+_phone.toString());

      if(_name == null || _surname == null){
        _name = provider.user.firstName;
        _surname = provider.user.lastName;
      }
      if(_phone == null){
        _phone = provider.user.telephone;
      }

      await updateUserInFirebase(context, _name, _surname, _phone);

      setState(() {
        _isLoading = false;
        _userNameEdit = !_userNameEdit;
      });

    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeMediaQuery = MediaQuery.of(context).size;
    final width = sizeMediaQuery.width;
    final height = sizeMediaQuery.height;
    final provider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Użytkownika"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(snapshot.data.data().toString()),
              SizedBox(height: 20),
              imagePicker(provider, width),
              SizedBox(height: 15),
              RatingBarIndicator(
                rating: double.parse(provider.user.rating),
                itemBuilder: (_, index) =>
                    Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 40.0,
              ),
              Text(
                provider.user.rating + ' (' + provider.user.ratingNumber + ')',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 15),
              ListTile(
                title: Text("Imie i nazwisko:"),
                trailing: IconButton(
                    color: _userNameEdit
                        ? Theme.of(context).errorColor
                        : Theme.of(context).primaryColor,
                    icon: _userNameEdit ? Icon(Icons.close) : Icon(Icons.edit),
                    onPressed: _userNameEdit
                        ? () {
                            setState(() {
                              _userNameEdit = !_userNameEdit;
                            });
                          }
                        : () {
                            _nameController.text = provider.user.firstName;
                            _surnameController.text = provider.user.lastName;
                            setState(() {
                              _userNameEdit = !_userNameEdit;
                            });
                          }),
              ),
              !_userNameEdit
                  ? Text(
                      provider.user.firstName + ' ' + provider.user.lastName,
                      style: Theme.of(context).textTheme.headline6,
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            width: width * 0.80,
                            child: TextFormField(
                              key: ValueKey("imie"),
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: "Imie",
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: _nameController.clear,
                                ),
                              ),
                              validator: (value) {
                                if (value.isEmpty || value.length < 3) {
                                  return 'Proszę podać przynajmniej 3 znaki.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _name = value;
                              },
                            ),
                          ),
                          Container(
                            width: width * 0.80,
                            child: TextFormField(
                              key: ValueKey("nazwisko"),
                              controller: _surnameController,
                              decoration: InputDecoration(
                                hintText: "Nazwisko",
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: _surnameController.clear,
                                ),
                              ),
                              validator: (value) {
                                if (value.isEmpty || value.length < 3) {
                                  return 'Proszę podać przynajmniej 3 znaki.';
                                }
                                return null;
                              },
                              onSaved: (value) {
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
                                    _trySubmit(context, provider);
                                  },
                                ),
                        ],
                      ),
                    ),
              SizedBox(height: 15),
              ListTile(
                title: Text('Numer Telefonu:'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => print("Hello"),
                ),
              ),
              Text(
                _formatPhoneNumber(provider.user.telephone),
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPhoneNumber(String phone) {
    String temp = phone.substring(0, 3) +
        '-' +
        phone.substring(3, 6) +
        '-' +
        phone.substring(6);
    return temp;
  }
}
