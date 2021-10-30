import 'package:flutter/material.dart';

import '../../models/address.dart';

Widget editAddress(
  BuildContext context,
  Address address,
) {
  final _formKey = GlobalKey<FormState>();
  TextEditingController streetController =
      TextEditingController(text: address.streetAndHouseNumber);
  TextEditingController zipCodeController =
      TextEditingController(text: address.zipCode);
  TextEditingController cityController =
      TextEditingController(text: address.city);
  TextEditingController subAdministrativeAreaController =
      TextEditingController(text: address.subAdministrativeArea);
  TextEditingController administrativeAreaController =
      TextEditingController(text: address.administrativeArea);

  return Form(
    key: _formKey,
    child: Column(
      children: [
        TextFormField(
          controller: streetController,
          decoration: InputDecoration(labelText: 'Ulica i numer domu'),
        ),
        TextFormField(
          controller: zipCodeController,
          decoration: InputDecoration(labelText: 'Kod pocztowy'),
        ),
        TextFormField(
          controller: cityController,
          decoration: InputDecoration(labelText: 'Miejscowość'),
        ),
        TextFormField(
          controller: subAdministrativeAreaController,
          decoration: InputDecoration(labelText: 'Powiat'),
        ),
        TextFormField(
          controller: administrativeAreaController,
          decoration: InputDecoration(labelText: 'Województwo'),
        ),
      ],
    ),
  );
}
