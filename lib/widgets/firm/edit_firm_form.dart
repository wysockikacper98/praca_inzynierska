import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/firm.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/widgets/pickers/image_picker.dart';
import 'package:provider/provider.dart';

class EditFirmForm extends StatefulWidget {
  final BuildContext context;
  final Firm _firm;

  EditFirmForm(this.context, this._firm);

  @override
  _EditFirmFormState createState() => _EditFirmFormState();
}

class _EditFirmFormState extends State<EditFirmForm> {
  @override
  Widget build(BuildContext context) {
    final firmProvider = Provider.of<FirmProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sizeMediaQuery = MediaQuery.of(context).size;
    final width = sizeMediaQuery.width;
    // final height = sizeMediaQuery.height;

    return Column(
      children: [
        SizedBox(height: 15),
        imagePickerFirm(firmProvider, userProvider, width),
        Text(widget._firm.firmName),
        Text(widget._firm.toString()),
      ],
    );
  }
}
