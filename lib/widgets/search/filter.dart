import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/theme/theme_dark.dart' as dark;
import 'package:praca_inzynierska/widgets/theme/theme_light.dart' as light;

Widget buildFilter(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: ElevatedButton(
      style: MediaQuery.of(context).platformBrightness == Brightness.light
          ? light.elevatedButtonFilterStyle()
          : dark.elevatedButtonFilterStyle(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Filtr', style: Theme.of(context).textTheme.headline4),
            SizedBox(width: 5),
            Icon(
              Icons.filter_alt,
              size: 35,
            ),
          ],
        ),
      ),
      onPressed: () {
        print('Filtr');
      },
    ),
  );
}
