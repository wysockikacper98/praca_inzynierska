import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/firm.dart';
import 'package:praca_inzynierska/widgets/pickers/image_picker.dart';
import 'package:provider/provider.dart';

class EditFirmForm extends StatefulWidget {
  final BuildContext context;
  final AsyncSnapshot<dynamic> snapshot;

  EditFirmForm(this.context, this.snapshot);

  @override
  _EditFirmFormState createState() => _EditFirmFormState();
}

class _EditFirmFormState extends State<EditFirmForm> {



  @override
  Widget build(BuildContext context) {
    final sizeMediaQuery = MediaQuery.of(context).size;
    final width = sizeMediaQuery.width;
    final height = sizeMediaQuery.height;

    final provider = Provider.of<FirmProvider>(context);


    return Column(
      children: [
        SizedBox(height: 15),
        imagePickerFirm(provider, width),
        Text(widget.snapshot.data.data().toString()),
      ],
    );
  }
}
