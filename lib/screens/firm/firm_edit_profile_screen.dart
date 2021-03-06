import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fraction/fraction.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';

import '../../helpers/firebase_firestore.dart';
import '../../helpers/firebase_storage.dart';
import '../../helpers/permission_handler.dart';
import '../../models/address.dart';
import '../../models/firm.dart';
import '../../models/useful_data.dart';
import '../../models/users.dart';
import '../../widgets/calculate_rating.dart';
import '../../widgets/pickers/image_picker.dart';
import '../full_screen_image.dart';
import '../location/pick_location_screen.dart';
import 'buildCategories.dart';

class FirmEditProfileScreen extends StatefulWidget {
  static const routeName = '/firm-edit-profile';

  @override
  State<FirmEditProfileScreen> createState() => _FirmEditProfileScreenState();
}

class _FirmEditProfileScreenState extends State<FirmEditProfileScreen> {
  bool _dirty = false;
  bool _dataInitialized = false;
  final _formKey = GlobalKey<FormState>();
  late Firm _updatedFirm;
  List<String> _categoriesList = [];

  TextEditingController _firmNameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _streetController = TextEditingController();
  TextEditingController _zipCodeController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _subAdministrativeAreaController =
      TextEditingController();
  TextEditingController _administrativeAreaController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _firmNameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _phoneNumberController.dispose();
    _streetController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _subAdministrativeAreaController.dispose();
    _administrativeAreaController.dispose();
    _descriptionController.dispose();
  }

  void uselessFunction() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final firmProvider = Provider.of<FirmProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    setUpControllers(firmProvider.firm!);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_dirty) {
              showDialog(context: context, builder: (ctx) => confirmExit());
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: AutoSizeText('Edycja profilu firmy', maxLines: 1),
        actions: [
          if (_dataInitialized && _dirty)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => setState(() {
                _dataInitialized = false;
                makeClean();
              }),
            ),
          if (_dirty)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                _trySubmit();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.0),
            imagePickerFirm(firmProvider, userProvider, _width),
            buildRatingBarIndicator(userProvider, firmProvider),
            BuildCategories(
              firmProvider.firm!.category!.cast<String>(),
              Provider.of<UsefulData>(context, listen: false).categoriesList,
              makeDirty,
              _updateCategories,
            ),
            buildFirmData(context, firmProvider.firm!, _width),
            SizedBox(height: 16),
            buildPictureEditor(context, firmProvider),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget buildPictureEditor(BuildContext context, FirmProvider firmProvider) {
    var amountOfPictures = firmProvider.firm!.details!.pictures!.length;
    return Column(
      children: [
        ListTile(
          title: Text(
            'Zdj??cia:',
            style: Theme.of(context).textTheme.headline6,
          ),
          trailing: amountOfPictures < 5
              ? ElevatedButton.icon(
                  label: Text(amountOfPictures == 0
                      ? 'Dodaj zdjecie'
                      : 'Dodaj zdjecie ${Fraction(amountOfPictures, 5).toStringAsGlyph()}'),
                  icon: Icon(Icons.add_photo_alternate),
                  onPressed: () => addPictureToFirmProfile(context),
                )
              : null,
        ),
        SizedBox(height: 16.0),
        amountOfPictures > 0
            ? CarouselSlider.builder(
                options: CarouselOptions(
                  aspectRatio: 2.5,
                  disableCenter: true,
                  autoPlayInterval: const Duration(seconds: 8),
                  enlargeCenterPage: true,
                  autoPlay: false,
                ),
                itemCount: amountOfPictures,
                itemBuilder: (ctx, index, tag) {
                  return GestureDetector(
                    child: Hero(
                      tag: tag,
                      child: Container(
                        child: CachedNetworkImage(
                          imageUrl:
                              firmProvider.firm!.details!.pictures![index],
                        ),
                        color: Colors.white30,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) {
                          return FullScreenImage(
                            imageURLPath:
                                firmProvider.firm!.details!.pictures![index],
                            tag: tag,
                            editable: true,
                          );
                        }),
                      );
                    },
                  );
                },
              )
            : Center(
                child: Text('Brak zdj????.'),
              ),
      ],
    );
  }

  Column buildFirmData(BuildContext context, Firm firm, double width) {
    return Column(
      children: [
        ListTile(
          title: Text(
            "Dane Firmy:",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Form(
          key: _formKey,
          child: Container(
            width: width * 0.9,
            child: Column(
              children: [
                TextFormField(
                  key: ValueKey('firmName'),
                  controller: _firmNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Nazwa Firmy',
                    labelText: 'Nazwa Firmy',
                  ),
                  onChanged: (_) => makeDirty(),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole wymagane';
                    }
                    value = value.trim();
                    if (value.isEmpty || value.length < 3) {
                      return 'Prosz?? poda?? przyanjmniej 3 znaki.';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _updatedFirm.firmName = value!.trim();
                  },
                ),
                TextFormField(
                  key: ValueKey('name'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Imie w??a??ciciela',
                    labelText: 'Imie w??a??ciciela',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole jest wymagane';
                    }
                    value = value.trim();
                    if (value.isEmpty || value.length < 2) {
                      return 'Imi?? za kr??tkie.';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {
                    _updatedFirm.firstName = value!.trim();
                  },
                ),
                TextFormField(
                  key: ValueKey('surname'),
                  controller: _surnameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Nazwisko w??a??ciciela',
                    labelText: 'Nazwisko w??a??ciciela',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole jest wymagane';
                    }
                    value = value.trim();
                    if (value.isEmpty || value.length < 2) {
                      return 'Nazwisko za kr??tkie.';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {
                    _updatedFirm.lastName = value!.trim();
                  },
                ),
                TextFormField(
                  key: ValueKey('phone'),
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    MaskedInputFormatter('000-000-000'),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Numer Telefonu',
                    labelText: 'Numer Telefonu',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole jest wymagane';
                    }
                    value = value.replaceAll('-', '');
                    if (int.tryParse(value) == null) {
                      return 'Podaj numer telefonu';
                    }
                    if (value.isEmpty || value.length < 9) {
                      return 'Podaj poprawny numer telefonu';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {
                    _updatedFirm.telephone = value!.replaceAll('-', '');
                  },
                ),
                SizedBox(height: 16.0),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Adres:",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  trailing: ElevatedButton.icon(
                    icon: Icon(Icons.location_on),
                    label: Text('Wybierz adres'),
                    onPressed: () {
                      locationPermissions().then((value) {
                        if (value == ph.PermissionStatus.granted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PickLocationScreen(updateAddress),
                            ),
                          );
                        } else if (value ==
                            ph.PermissionStatus.permanentlyDenied) {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return buildAlertDialogForPermissionsPermanentlyDenied(
                                ctx,
                              );
                            },
                          );
                        }
                      });
                    },
                  ),
                ),
                TextFormField(
                  key: ValueKey('street'),
                  controller: _streetController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Ulica i numer domu',
                    hintText: 'Ulica i numer domu',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole wymagane';
                    }
                    value = value.trim();
                    if (value.isEmpty || value.length < 3) {
                      return 'Nazwa ulicy jest za kr??tka.';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {
                    if (_updatedFirm.address == null) {
                      _updatedFirm.address = Address.empty();
                    }
                    _updatedFirm.address!.streetAndHouseNumber = value!.trim();
                  },
                ),
                TextFormField(
                  key: ValueKey('zipCode'),
                  controller: _zipCodeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    MaskedInputFormatter('00-000'),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Kod pocztowy',
                    hintText: 'Kod pocztowy',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole wymagane!';
                    }
                    final regexp = RegExp(r'^\d{2}-\d{3}$');
                    if (!regexp.hasMatch(value)) {
                      return 'Wprowadzono nie poprawny kod pocztowy.';
                    }
                    return null;
                  },
                  onChanged: (String value) => makeDirty(),
                  onSaved: (String? value) {
                    if (_updatedFirm.address == null) {
                      _updatedFirm.address = Address.empty();
                    }
                    _updatedFirm.address!.zipCode = value!;
                  },
                ),
                TextFormField(
                  key: ValueKey('city'),
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Miejscowo????',
                    hintText: 'Miejscowo????',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole jest wymagane';
                    }
                    value = value.trim();
                    if (value.isEmpty || value.length < 3) {
                      return 'Nazwa miejscowo??ci jest za kr??tka';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {
                    if (_updatedFirm.address == null) {
                      _updatedFirm.address = Address.empty();
                    }
                    _updatedFirm.address!.city = value!.trim();
                  },
                ),
                //Niepotrzebne informacje
                // TextFormField(
                //   key: ValueKey('subAdministrativeArea'),
                //   controller: _subAdministrativeAreaController,
                //   textCapitalization: TextCapitalization.words,
                //   decoration: InputDecoration(
                //     labelText: 'Powiat',
                //     hintText: 'Powiat',
                //   ),
                //   validator: (_) {
                //     return null;
                //   },
                //   onChanged: (_) => makeDirty(),
                //   onSaved: (String? value) {
                //     if (_updatedFirm.address == null) {
                //       _updatedFirm.address = Address.empty();
                //     }
                //     _updatedFirm.address!.subAdministrativeArea =
                //         value == null ? '' : value.trim();
                //   },
                // ),
                // TextFormField(
                //   key: ValueKey('administrativeArea'),
                //   controller: _administrativeAreaController,
                //   textCapitalization: TextCapitalization.words,
                //   decoration: InputDecoration(
                //     labelText: 'Wojew??dztwo',
                //     hintText: 'Wojew??dztwo',
                //   ),
                //   validator: (_) {
                //     return null;
                //   },
                //   onChanged: (_) => makeDirty(),
                //   onSaved: (String? value) {
                //     if (_updatedFirm.address == null) {
                //       _updatedFirm.address = Address.empty();
                //     }
                //     _updatedFirm.address!.administrativeArea =
                //         value == null ? '' : value.trim();
                //   },
                // ),
                SizedBox(height: 16.0),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'O Firmie:',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                TextFormField(
                  key: ValueKey('description'),
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 6,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Opis firmy',
                    hintText: 'Opis firmy',
                  ),
                  validator: (_) {
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {
                    _updatedFirm.details!.description =
                        value == null ? '' : value.trimRight();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column buildRatingBarIndicator(
      UserProvider userProvider, FirmProvider firmProvider) {
    return Column(
      children: [
        RatingBarIndicator(
          rating: userProvider.user!.rating!,
          itemBuilder: (_, index) => Icon(Icons.star, color: Colors.amber),
          itemCount: 5,
          itemSize: 40.0,
        ),
        Text(
          '${calculateRating(firmProvider.firm!.rating!, firmProvider.firm!.ratingNumber!)} (${firmProvider.firm!.ratingNumber})',
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }

  void _updateCategories(Map<String, bool> categoriesMap) {
    _categoriesList.clear();
    categoriesMap.forEach((String key, bool value) {
      if (value) _categoriesList.add(key);
    });
  }

  void makeDirty() {
    if (!_dirty)
      setState(() {
        _dirty = true;
      });
  }

  void makeClean() {
    if (_dirty)
      setState(() {
        _dirty = false;
      });
  }

  SnackBar snackBarCategories() {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Wykonawca musi posiada?? przynajmiej jedn?? kategori??'),
    );
  }

  AlertDialog confirmExit() {
    return AlertDialog(
      title: Text('Wyj???? bez zapisywania?'),
      content: Text(
          'Wszystkie nie zapisane zmiany zostan?? utracone.\nCzy na pewno chcesz wyj?????'),
      actions: [
        TextButton(
          child: Text('Anuluj'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Opu????'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void setUpControllers(Firm firm) {
    if (!_dataInitialized) {
      _updatedFirm = firm;

      _firmNameController.text = firm.firmName;
      _nameController.text = firm.firstName;
      _surnameController.text = firm.lastName;
      _phoneNumberController.text = firm.telephone == null
          ? ''
          : firm.telephone!.replaceAllMapped(
              RegExp(r'(\d{3})(\d{3})(\d{3})'),
              (Match match) => '${match[1]}-${match[2]}-${match[3]}',
            );

      _streetController.text = firm.address!.streetAndHouseNumber;
      _zipCodeController.text = firm.address!.zipCode;
      _cityController.text = firm.address!.city;
      _subAdministrativeAreaController.text =
          firm.address!.subAdministrativeArea ?? '';
      _administrativeAreaController.text =
          firm.address!.administrativeArea ?? '';
      if (firm.details != null) {
        _descriptionController.text = firm.details!.description!;
      } else {
        _descriptionController.text = '';
      }
      _dataInitialized = true;
    }
  }

  void updateAddress(Address address) {
    _streetController.text = address.streetAndHouseNumber;
    _zipCodeController.text = address.zipCode;
    _cityController.text = address.city;
    _subAdministrativeAreaController.text = address.subAdministrativeArea ?? '';
    _administrativeAreaController.text = address.administrativeArea ?? '';
    setState(() {
      _dirty = true;
    });
  }

  Future<void> _trySubmit() async {
    final _isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      _formKey.currentState!.save();
      _updatedFirm.category = _categoriesList;
      print(_updatedFirm.category);
      await updateFirmInFirebase(context, _updatedFirm);
      makeClean();
    }
  }
}
