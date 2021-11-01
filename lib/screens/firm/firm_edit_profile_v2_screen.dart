import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:provider/provider.dart';

import '../../helpers/permission_handler.dart';
import '../../models/firm.dart';
import '../../models/useful_data.dart';
import '../../models/users.dart';
import '../../widgets/calculate_rating.dart';
import '../../widgets/pickers/image_picker.dart';
import '../location/pick_location_screen.dart';
import 'buildCategories.dart';

class FirmEditProfileV2Screen extends StatefulWidget {
  static const routeName = '/firm-edit-profile-v2';

  @override
  State<FirmEditProfileV2Screen> createState() =>
      _FirmEditProfileV2ScreenState();
}

class _FirmEditProfileV2ScreenState extends State<FirmEditProfileV2Screen> {
  bool _dirty = false;
  bool _dataInitialized = false;
  final _formKey = GlobalKey<FormState>();

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
        title: AutoSizeText('Edycja profilu firmy 2', maxLines: 1),
        actions: [
          if (_dataInitialized)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => setState(() {
                _dataInitialized = false;
              }),
            ),
          if (_dirty)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () => makeClean(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Dirty:$_dirty'),
            Text('Data Initialized:$_dataInitialized'),
            // Text('Category Provider:\n${firmProvider.firm!.category!}\n'),
            SizedBox(height: 20),
            Text(firmProvider.firm.toString()),
            SizedBox(height: 20),
            imagePickerFirm(firmProvider, userProvider, _width),
            buildRatingBarIndicator(userProvider, firmProvider),
            // buildCategories(context, firmProvider.firm!.category!),
            BuildCategories(
              firmProvider.firm!.category!.cast<String>(),
              Provider.of<UsefulData>(context, listen: false).categoriesList,
              makeDirty,
            ),
            buildFirmData(context, firmProvider.firm!, _width),
            Container(),
          ],
        ),
      ),
    );
  }

  Widget buildFirmData(BuildContext context, Firm firm, double width) {
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
                      return 'Proszę podać przyanjmniej 3 znaki.';
                    }
                    return null;
                  },
                  onSaved: (String? value) {},
                ),
                TextFormField(
                  key: ValueKey('name'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Imie właściciela',
                    labelText: 'Imie właściciela',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole jest wymagane';
                    }
                    value = value.trim();
                    if (value.isEmpty || value.length < 2) {
                      return 'Imię za krótkie.';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {},
                ),
                TextFormField(
                  key: ValueKey('surname'),
                  controller: _surnameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Nazwisko właściciela',
                    labelText: 'Nazwisko właściciela',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole jest wymagane';
                    }
                    value = value.trim();
                    if (value.isEmpty || value.length < 2) {
                      return 'Nazwisko za krótkie.';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {},
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
                  onSaved: (String? value) {},
                ),
                SizedBox(height: 16.0),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Lokalizacja:",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  trailing: ElevatedButton.icon(
                    icon: Icon(Icons.location_on),
                    label: Text('Wybierz lokalizację'),
                    onPressed: () {
                      locationPermissions().then((value) {
                        if (value == ph.PermissionStatus.granted) {
                          Navigator.of(context)
                              .pushNamed(PickLocationScreen.routeName);
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
                      return 'Nazwa ulicy jest za krótka.';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {},
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
                  onSaved: (String? value) {},
                ),
                TextFormField(
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Miejscowość',
                    hintText: 'Miejscowość',
                  ),
                  validator: (String? value) {
                    if (value == null) {
                      return 'Pole jest wymagane';
                    }
                    value = value.trim();
                    if (value.isEmpty || value.length < 3) {
                      return 'Nazwa miejscowości jest za krótka';
                    }
                    return null;
                  },
                  onChanged: (_) => makeDirty(),
                  onSaved: (String? value) {},
                ),
                TextFormField(
                  controller: _subAdministrativeAreaController,
                  decoration: InputDecoration(labelText: 'Powiat'),
                ),
                TextFormField(
                  controller: _administrativeAreaController,
                  decoration: InputDecoration(labelText: 'Województwo'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget editAddress() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _streetController,
            decoration: InputDecoration(labelText: 'Ulica i numer domu'),
          ),
          TextFormField(
            controller: _zipCodeController,
            decoration: InputDecoration(labelText: 'Kod pocztowy'),
          ),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(labelText: 'Miejscowość'),
          ),
          TextFormField(
            controller: _subAdministrativeAreaController,
            decoration: InputDecoration(labelText: 'Powiat'),
          ),
          TextFormField(
            controller: _administrativeAreaController,
            decoration: InputDecoration(labelText: 'Województwo'),
          ),
        ],
      ),
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
      content: Text('Wykonawca musi posiadać przynajmiej jedną kategorię'),
    );
  }

  AlertDialog confirmExit() {
    return AlertDialog(
      title: Text('Wyjść bez zapisywania?'),
      content: Text(
          'Wszystkie nie zapisane zmiany zostaną utracone.\nCzy na pewno chcesz wyjść?'),
      actions: [
        TextButton(
          child: Text('Anuluj'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Opuść'),
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
      // setState(() {
      _dataInitialized = true;
      // });
    }
  }
}
