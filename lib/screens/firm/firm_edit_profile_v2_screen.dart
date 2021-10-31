import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../models/firm.dart';
import '../../models/useful_data.dart';
import '../../models/users.dart';
import '../../widgets/calculate_rating.dart';
import '../../widgets/pickers/image_picker.dart';
import 'buildCategories.dart';

class FirmEditProfileV2Screen extends StatefulWidget {
  static const routeName = '/firm-edit-profile-v2';

  @override
  State<FirmEditProfileV2Screen> createState() =>
      _FirmEditProfileV2ScreenState();
}

class _FirmEditProfileV2ScreenState extends State<FirmEditProfileV2Screen> {
  bool _editCategory = false;
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final firmProvider = Provider.of<FirmProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

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
        title: Text('Edycja profilu firmy 2'),
        actions: [
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
            Text('Category Provider:\n${firmProvider.firm!.category!}\n'),
            imagePickerFirm(firmProvider, userProvider, _width),
            buildRatingBarIndicator(userProvider, firmProvider),
            // buildCategories(context, firmProvider.firm!.category!),
            BuildCategories(
              firmProvider.firm!.category!.cast<String>(),
              Provider.of<UsefulData>(context, listen: false).categoriesList,
              makeDirty,
            ),
            Container(),
          ],
        ),
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
    setState(() {
      _dirty = true;
    });
  }

  void makeClean() {
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
}
