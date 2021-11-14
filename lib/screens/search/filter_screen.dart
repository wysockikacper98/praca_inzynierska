import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/colorfull_print_messages.dart';
import '../../models/useful_data.dart';
import '../firm/buildCategories.dart';

class FilterScreen extends StatefulWidget {
  final void Function(
    List<String>? categories,
    String? administrativeArea,
    List<double>? rageMinMax,
    List<int>? popularityMinMax,
  ) _applyFilters;

  static List<String>? categories;
  static String? administrativeArea;
  static List<double>? rageMinMax;
  static List<int>? popularityMinMax;

  FilterScreen(
    this._applyFilters, [
    categories,
    administrativeArea,
    rageMinMax,
    popularityMinMax,
  ]);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool _dirty = false;
  late final List<String> _categoriesList;

  @override
  void initState() {
    super.initState();

    _categoriesList =
        Provider.of<UsefulData>(context, listen: false).categoriesList;
  }

  void _makeDirty() {
    printColor(text: 'Dirty', color: PrintColor.red);
    setState(() => _dirty = true);
  }

  void _updateCategories(Map<String, bool> value) {
    value.forEach((key, value) {
      if (value) printColor(text: key.toString(), color: PrintColor.green);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
        ),
        title: Text('Filtry'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildTODOText(context, 'TODO: Kategorie'),
            BuildCategories([], _categoriesList, _makeDirty, _updateCategories),
            buildTODOText(context, 'TODO: Województwa'),
            buildTODOText(context, 'TODO: Minimalna ocena'),
            buildTODOText(context, 'TODO: Minimalna ilość ocen'),
            if (_dirty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    child: Text(
                      'Zastosuj',
                    ),
                    style: ElevatedButton.styleFrom(
                      textStyle: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                    ),
                    onPressed: () {
                      widget._applyFilters(null, null, null, null);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Text buildTODOText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .headline5!
          .copyWith(color: Theme.of(context).errorColor),
    );
  }
}
