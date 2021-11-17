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

  final List<String>? _defaultCategories;
  final String? _defaultAdministrativeArea;
  final List<double>? _defaultRageMinMax;
  final List<int>? _defaultPopularityMinMax;

  FilterScreen(
    this._applyFilters, [
    this._defaultCategories,
    this._defaultAdministrativeArea,
    this._defaultRageMinMax,
    this._defaultPopularityMinMax,
  ]);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool _dirty = false;
  late final List<String> _availableCategories;

  late List<String> _selectedCategories;
  String? _selectedAdministrativeArea;
  late List<double> _selectedRageMinMax;
  late List<int> _selectedPopularityMinMax;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _availableCategories =
        Provider.of<UsefulData>(context, listen: false).categoriesList;

    _selectedCategories = widget._defaultCategories ?? [];
    _selectedAdministrativeArea = widget._defaultAdministrativeArea;
    _selectedRageMinMax = widget._defaultRageMinMax ?? [];
    _selectedPopularityMinMax = widget._defaultPopularityMinMax ?? [];
  }

  void _makeDirty() {
    printColor(text: 'Dirty', color: PrintColor.red);
    setState(() => _dirty = true);
  }

  void _updateCategories(Map<String, bool> value) {
    _selectedCategories = [];
    value.entries.forEach((e) {
      if (e.value) _selectedCategories.add(e.key);
    });
    printColor(text: _selectedCategories.toString(), color: PrintColor.black);
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
        actions: [
          if (_dirty)
            TextButton.icon(
              icon: Icon(
                Icons.cleaning_services,
                color: Colors.white,
              ),
              label: Text(
                'Wyczyść',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                printColor(text: 'Czyszczenie', color: PrintColor.blue);
                setState(() {
                  _selectedCategories.clear();
                  _selectedAdministrativeArea = null;
                  _selectedRageMinMax.clear();
                  _selectedPopularityMinMax.clear();
                  _dirty = false;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //TODO: Kategorie
            BuildCategories(
              _selectedCategories,
              _availableCategories,
              _makeDirty,
              _updateCategories,
            ),
            //TODO: Województwa
            //TODO: Minimalna ocena
            //TODO: Minimalna ilość ocen

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
                  onPressed: _dirty
                      ? () {
                          widget._applyFilters(
                            _selectedCategories,
                            _selectedAdministrativeArea,
                            _selectedRageMinMax,
                            _selectedPopularityMinMax,
                          );
                        }
                      : null,
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
