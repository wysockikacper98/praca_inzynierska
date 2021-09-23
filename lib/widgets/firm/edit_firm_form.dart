import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../helpers/firebaseHelper.dart';
import '../../models/firm.dart';
import '../../models/users.dart';
import '../../screens/full_screen_image.dart';
import '../pickers/image_picker.dart';

class EditFirmForm extends StatefulWidget {
  @override
  _EditFirmFormState createState() => _EditFirmFormState();
}

class _EditFirmFormState extends State<EditFirmForm> {
  final _formFirmNameKey = GlobalKey<FormState>();
  final _formNameAndSurnameKey = GlobalKey<FormState>();
  final _formPhoneNumberKey = GlobalKey<FormState>();
  final _formLocationKey = GlobalKey<FormState>();
  final _formDescriptionKey = GlobalKey<FormState>();

  bool _editFirmName = false;
  bool _editNameAndSurname = false;
  bool _editPhoneNumber = false;
  bool _editLocation = false;
  bool _editDescription = false;
  bool _editPicture = false;

  bool _isLoading = false;

  TextEditingController _firmNameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _firmNameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
  }

  String? _firmName;
  String? _name;
  String? _surname;
  String? _phone;
  String? _location;
  String? _description;
  // List<String>? _picture;

  Future<void> _trySubmit(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    final firmProvider = Provider.of<FirmProvider>(context, listen: false);
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    final _isValid = formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      setState(() {
        _isLoading = true;
      });

      formKey.currentState!.save();

      Firm updatedFirm = firmProvider.firm;

      //update Firm
      if (_firmName != null) {
        updatedFirm.firmName = _firmName!;
      }
      if (_name != null && _surname != null) {
        updatedFirm.firstName = _name!;
        updatedFirm.lastName = _surname!;
      }
      if (_phone != null) {
        updatedFirm.telephone = _phone;
      }
      if (_location != null) {
        updatedFirm.location = _location;
      }
      if (_description != null) {
        updatedFirm.details!.description = _description;
      }

      await updateFirmInFirebase(context, updatedFirm);

      firmProvider.firm = updatedFirm;

      setState(() {
        _isLoading = false;
        _editFirmName = false;
        _editNameAndSurname = false;
        _editPhoneNumber = false;
        _editLocation = false;
        _editDescription = false;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Column(
          children: [
            imagePickerFirm(firmProvider, userProvider, width),
            SizedBox(height: 15),
            RatingBarIndicator(
              rating: double.parse(userProvider.user.rating!),
              itemBuilder: (_, index) => Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 40.0,
            ),
            Text(
              firmProvider.firm.rating! +
                  ' (' +
                  firmProvider.firm.ratingNumber! +
                  ')',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nazwa Firmy:',
                  style: Theme.of(context).textTheme.headline6,
                ),
                !_editFirmName
                    ? TextButton(
                        child: Text(
                          firmProvider.firm.firmName,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        onPressed: () {
                          _firmNameController.text = firmProvider.firm.firmName;
                          setState(() {
                            _editFirmName = !_editFirmName;
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _editFirmName = !_editFirmName;
                          });
                        },
                      ),
              ],
            ),
            if (_editFirmName)
              Form(
                key: _formFirmNameKey,
                child: Column(
                  children: [
                    Container(
                      width: width * 0.80,
                      child: TextFormField(
                        key: ValueKey("firmName"),
                        controller: _firmNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: "Nazwa Firmy",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _firmNameController.clear,
                          ),
                        ),
                        validator: (value) {
                          value = value!.trim();

                          if (value.isEmpty || value.length < 3) {
                            return 'Proszę podać przynajmniej 3 znaki.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          value = value!.trim();

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
            // ListTile(
            //   title: Text("Nazwa Firmy:"),
            //   trailing: IconButton(
            //     color: _editFirmName
            //         ? Theme.of(context).errorColor
            //         : Theme.of(context).primaryColor,
            //     icon: _editFirmName ? Icon(Icons.close) : Icon(Icons.edit),
            //     onPressed: () {
            //       if (!_editFirmName)
            //         _firmNameController.text = firmProvider.firm.firmName;
            //       setState(() {
            //         _editFirmName = !_editFirmName;
            //       });
            //     },
            //   ),
            // ),
            // !_editFirmName
            //     ? Text(
            //         firmProvider.firm.firmName,
            //         style: Theme.of(context).textTheme.headline6,
            //       )
            //     : Form(
            //         key: _formFirmNameKey,
            //         child: Column(
            //           children: [
            //             Container(
            //               width: width * 0.80,
            //               child: TextFormField(
            //                 key: ValueKey("firmName"),
            //                 controller: _firmNameController,
            //                 textCapitalization: TextCapitalization.words,
            //                 decoration: InputDecoration(
            //                   hintText: "Nazwa Firmy",
            //                   suffixIcon: IconButton(
            //                     icon: Icon(Icons.clear),
            //                     onPressed: _firmNameController.clear,
            //                   ),
            //                 ),
            //                 validator: (value) {
            //                   value = value.trim();
            //
            //                   if (value.isEmpty || value.length < 3) {
            //                     return 'Proszę podać przynajmniej 3 znaki.';
            //                   }
            //                   return null;
            //                 },
            //                 onSaved: (value) {
            //                   value = value.trim();
            //
            //                   _firmName = value;
            //                 },
            //               ),
            //             ),
            //             SizedBox(height: 20),
            //             _isLoading
            //                 ? Center(child: CircularProgressIndicator())
            //                 : ElevatedButton(
            //                     child: SizedBox(
            //                       width: width * 0.8,
            //                       child: Text(
            //                         "Zapisz",
            //                         textAlign: TextAlign.center,
            //                       ),
            //                     ),
            //                     onPressed: () {
            //                       _trySubmit(
            //                         context,
            //                         _formFirmNameKey,
            //                       );
            //                     },
            //                   ),
            //           ],
            //         ),
            //       ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Właściciel:",
                  style: Theme.of(context).textTheme.headline6,
                ),
                !_editNameAndSurname
                    ? TextButton(
                        child: Text(
                          firmProvider.firm.firstName +
                              " " +
                              firmProvider.firm.lastName,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        onPressed: () {
                          if (!_editNameAndSurname) {
                            _nameController.text = firmProvider.firm.firstName;
                            _surnameController.text =
                                firmProvider.firm.lastName;
                          }
                          setState(() {
                            _editNameAndSurname = !_editNameAndSurname;
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _editNameAndSurname = !_editNameAndSurname;
                          });
                        }),
              ],
            ),
            if (_editNameAndSurname)
              Form(
                key: _formNameAndSurnameKey,
                child: Column(
                  children: [
                    Container(
                      width: width * 0.80,
                      child: TextFormField(
                        key: ValueKey("name"),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: "Imie",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _nameController.clear,
                          ),
                        ),
                        validator: (value) {
                          value = value!.trim();

                          if (value.isEmpty || value.length < 3) {
                            return 'Proszę podać przynajmniej 3 znaki.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          value = value!.trim();

                          _name = value;
                        },
                      ),
                    ),
                    Container(
                      width: width * 0.80,
                      child: TextFormField(
                        key: ValueKey("surname"),
                        controller: _surnameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: "Nazwisko",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _surnameController.clear,
                          ),
                        ),
                        validator: (value) {
                          value = value!.trim();
                          if (value.isEmpty || value.length < 3) {
                            return 'Proszę podać przynajmniej 3 znaki.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          value = value!.trim();
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
            // ListTile(
            //   title: Text("Właściciel:"),
            //   trailing: IconButton(
            //     color: _editNameAndSurname
            //         ? Theme.of(context).errorColor
            //         : Theme.of(context).primaryColor,
            //     icon:
            //         _editNameAndSurname ? Icon(Icons.close) : Icon(Icons.edit),
            //     onPressed: () {
            //       if (!_editNameAndSurname) {
            //         _nameController.text = firmProvider.firm.firstName;
            //         _surnameController.text = firmProvider.firm.lastName;
            //       }
            //       setState(() {
            //         _editNameAndSurname = !_editNameAndSurname;
            //       });
            //     },
            //   ),
            // ),
            // !_editNameAndSurname
            //     ? Text(
            //         firmProvider.firm.firstName +
            //             " " +
            //             firmProvider.firm.lastName,
            //         style: Theme.of(context).textTheme.headline6,
            //       )
            //     : Form(
            //         key: _formNameAndSurnameKey,
            //         child: Column(
            //           children: [
            //             Container(
            //               width: width * 0.80,
            //               child: TextFormField(
            //                 key: ValueKey("name"),
            //                 controller: _nameController,
            //                 textCapitalization: TextCapitalization.words,
            //                 decoration: InputDecoration(
            //                   hintText: "Imie",
            //                   suffixIcon: IconButton(
            //                     icon: Icon(Icons.clear),
            //                     onPressed: _nameController.clear,
            //                   ),
            //                 ),
            //                 validator: (value) {
            //                   value = value.trim();
            //
            //                   if (value.isEmpty || value.length < 3) {
            //                     return 'Proszę podać przynajmniej 3 znaki.';
            //                   }
            //                   return null;
            //                 },
            //                 onSaved: (value) {
            //                   value = value.trim();
            //
            //                   _name = value;
            //                 },
            //               ),
            //             ),
            //             Container(
            //               width: width * 0.80,
            //               child: TextFormField(
            //                 key: ValueKey("surname"),
            //                 controller: _surnameController,
            //                 textCapitalization: TextCapitalization.words,
            //                 decoration: InputDecoration(
            //                   hintText: "Nazwisko",
            //                   suffixIcon: IconButton(
            //                     icon: Icon(Icons.clear),
            //                     onPressed: _surnameController.clear,
            //                   ),
            //                 ),
            //                 validator: (value) {
            //                   value = value.trim();
            //                   if (value.isEmpty || value.length < 3) {
            //                     return 'Proszę podać przynajmniej 3 znaki.';
            //                   }
            //                   return null;
            //                 },
            //                 onSaved: (value) {
            //                   value = value.trim();
            //                   _surname = value;
            //                 },
            //               ),
            //             ),
            //             SizedBox(height: 20),
            //             _isLoading
            //                 ? Center(child: CircularProgressIndicator())
            //                 : ElevatedButton(
            //                     child: SizedBox(
            //                       width: width * 0.8,
            //                       child: Text(
            //                         "Zapisz",
            //                         textAlign: TextAlign.center,
            //                       ),
            //                     ),
            //                     onPressed: () {
            //                       _trySubmit(
            //                         context,
            //                         _formNameAndSurnameKey,
            //                       );
            //                     },
            //                   ),
            //           ],
            //         ),
            //       ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Numer Telefonu:',
                  style: Theme.of(context).textTheme.headline6,
                ),
                !_editPhoneNumber
                    ? TextButton(
                        child: Text(
                          _formatPhoneNumber(firmProvider.firm.telephone!),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        onPressed: () {
                          _phoneController.text = firmProvider.firm.telephone!;
                          setState(() {
                            _editPhoneNumber = !_editPhoneNumber;
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _editPhoneNumber = !_editPhoneNumber;
                          });
                        },
                      ),
              ],
            ),
            if (_editPhoneNumber)
              Form(
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
                        ),
                        validator: (value) {
                          value = value!.replaceAll(' ', '');
                          if (int.tryParse(value) == null) {
                            return 'Podaj numer telefonu';
                          } else if (value.isEmpty || value.length < 9) {
                            return 'Podaj poprawny numer telefonu';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _phone = value!.replaceAll(' ', '');
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
            // SizedBox(height: 15),
            // ListTile(
            //   title: Text("Numer Telefonu:"),
            //   trailing: IconButton(
            //     color: _editPhoneNumber
            //         ? Theme.of(context).errorColor
            //         : Theme.of(context).primaryColor,
            //     icon: _editPhoneNumber ? Icon(Icons.close) : Icon(Icons.edit),
            //     onPressed: () {
            //       if (!_editPhoneNumber) {
            //         _phoneController.text = firmProvider.firm.telephone;
            //       }
            //       setState(() {
            //         _editPhoneNumber = !_editPhoneNumber;
            //       });
            //     },
            //   ),
            // ),
            // !_editPhoneNumber
            //     ? Text(
            //         _formatPhoneNumber(firmProvider.firm.telephone),
            //         style: Theme.of(context).textTheme.headline6,
            //       )
            //     : Form(
            //         key: _formPhoneNumberKey,
            //         child: Column(
            //           children: [
            //             Container(
            //               width: width * 0.80,
            //               child: TextFormField(
            //                 key: ValueKey("phone"),
            //                 controller: _phoneController,
            //                 textAlign: TextAlign.center,
            //                 keyboardType: TextInputType.phone,
            //                 decoration: InputDecoration(
            //                   hintText: "Numer Telefonu",
            //                   suffixIcon: IconButton(
            //                     icon: Icon(Icons.clear),
            //                     onPressed: _phoneController.clear,
            //                   ),
            //                 ),
            //                 validator: (value) {
            //                   value = value.replaceAll(' ', '');
            //                   if (int.tryParse(value) == null) {
            //                     return 'Podaj numer telefonu';
            //                   } else if (value.isEmpty || value.length < 9) {
            //                     return 'Podaj poprawny numer telefonu';
            //                   }
            //                   return null;
            //                 },
            //                 onSaved: (value) {
            //                   _phone = value.replaceAll(' ', '');
            //                 },
            //               ),
            //             ),
            //             SizedBox(height: 20),
            //             _isLoading
            //                 ? Center(child: CircularProgressIndicator())
            //                 : ElevatedButton(
            //                     child: SizedBox(
            //                       width: width * 0.8,
            //                       child: Text(
            //                         "Zapisz",
            //                         textAlign: TextAlign.center,
            //                       ),
            //                     ),
            //                     onPressed: () {
            //                       _trySubmit(
            //                         context,
            //                         _formPhoneNumberKey,
            //                       );
            //                     },
            //                   ),
            //           ],
            //         ),
            //       ),
            SizedBox(height: 15),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Lokalizacja:"),
              trailing: IconButton(
                color: _editLocation
                    ? Theme.of(context).errorColor
                    : Theme.of(context).primaryColor,
                icon: _editLocation ? Icon(Icons.close) : Icon(Icons.edit),
                onPressed: () {
                  if (!_editLocation) {
                    _locationController.text = firmProvider.firm.location!;
                  }
                  setState(() {
                    _editLocation = !_editLocation;
                  });
                },
              ),
            ),
            !_editLocation
                ? Text(
                    firmProvider.firm.location!,
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
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: "Lokalizacja",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: _locationController.clear,
                              ),
                            ),
                            validator: (value) {
                              value = value!.trim();

                              if (value.isEmpty || value.length < 3) {
                                return 'Proszę podać przynajmniej 3 znaki.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _location = value!.trim();
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Opis firmy:"),
              trailing: IconButton(
                color: _editDescription
                    ? Theme.of(context).errorColor
                    : Theme.of(context).primaryColor,
                icon: _editDescription ? Icon(Icons.close) : Icon(Icons.edit),
                onPressed: () {
                  if (!_editDescription) {
                    _descriptionController.text =
                        firmProvider.firm.details!.description!;
                  }
                  setState(() {
                    _editDescription = !_editDescription;
                  });
                },
              ),
            ),
            !_editDescription
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: firmProvider.firm.details!.description),
                      ],
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    textAlign: TextAlign.justify,
                  )
                : Form(
                    key: _formDescriptionKey,
                    child: Column(
                      children: [
                        Container(
                          width: width * 0.90,
                          child: TextFormField(
                            key: ValueKey("description"),
                            controller: _descriptionController,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Opis firmy",
                              // suffixIcon: IconButton(
                              //   icon: Icon(Icons.clear),
                              //   onPressed: _descriptionController.clear,
                              // ),
                            ),
                            validator: (value) {
                              value = value!.trimRight();

                              if (value.isEmpty || value.length < 30) {
                                return 'Proszę podać przynajmniej 30 znaki.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _description = value!.trimRight();
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
                                    _formDescriptionKey,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
            SizedBox(height: 15),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Zdjęcia:"),
              trailing: IconButton(
                color: _editPicture
                    ? Theme.of(context).errorColor
                    : Theme.of(context).primaryColor,
                icon: _editPicture ? Icon(Icons.close) : Icon(Icons.edit),
                onPressed: () {
                  if (!_editPicture) {
                    _descriptionController.text =
                        firmProvider.firm.details!.description!;
                  }
                  setState(() {
                    _editPicture = !_editPicture;
                  });
                },
              ),
            ),
            firmProvider.firm.details!.pictures!.length > 0
                ? CarouselSlider.builder(
                    options: CarouselOptions(
                      aspectRatio: 2.5,
                      disableCenter: true,
                      autoPlayInterval: const Duration(seconds: 8),
                      enlargeCenterPage: true,
                      autoPlay: true,
                    ),
                    itemCount: firmProvider.firm.details!.pictures!.length,
                    itemBuilder: (ctx, index, tag) {
                      return GestureDetector(
                        child: Hero(
                          tag: tag,
                          child: Container(
                            child: Image.asset(
                                firmProvider.firm.details!.pictures![index]),
                            color: Colors.white30,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) {
                              return FullScreenImage(
                                  imageAssetsPath:
                                      firmProvider.firm.details!.pictures![index],
                                  tag: tag);
                            }),
                          );
                        },
                      );
                    },
                  )
                : Center(
                    child: Text('Brak zdjęć.'),
                  ),
            SizedBox(height: 15),
            Text(firmProvider.firm.toString()),
          ],
        ),
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
