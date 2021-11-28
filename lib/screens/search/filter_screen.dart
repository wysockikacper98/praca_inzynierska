import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../models/useful_data.dart';

class FilterScreen extends StatefulWidget {
  final void Function(
    List<String> categories,
    double ratingMin,
    int popularityMin,
  ) _applyFilters;

  final List<String>? _defaultCategories;
  final double? _defaultRatingMin;
  final int? _defaultPopularityMin;

  FilterScreen(
    this._applyFilters, [
    this._defaultCategories,
    this._defaultRatingMin,
    this._defaultPopularityMin,
  ]);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool _editCategory = false;
  late Map<String, bool> _categoriesMap;
  late List<String> _availableCategories;

  late List<String> _selectedCategories;
  late double _selectedMinRating;
  late int _selectedPopularityMin;

  late TextEditingController _textPopularityController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _availableCategories =
        Provider.of<UsefulData>(context, listen: false).categoriesList;

    _selectedCategories = widget._defaultCategories ?? [];
    _categoriesMap = Map.fromIterable(_availableCategories,
        key: (e) => e,
        value: (e) => _selectedCategories.contains(e) ? true : false);

    _selectedMinRating = widget._defaultRatingMin ?? 0.0;
    _selectedPopularityMin = widget._defaultPopularityMin ?? 0;
    _textPopularityController =
        TextEditingController(text: _selectedPopularityMin.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _textPopularityController.dispose();
  }

  void _updateCategories(Map<String, bool> value) {
    _selectedCategories = [];
    value.entries.forEach((e) {
      if (e.value) _selectedCategories.add(e.key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
        ),
        title: Text('Filtry'),
        actions: [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: cleanFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildCategories(context),
                  buildRating(),
                  buildPopularity(_theme),
                ],
              ),
            ),
          ),
          buildConfirmButton(_theme),
        ],
      ),
    );
  }

  Padding buildPopularity(ThemeData _theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 20.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Minimalna ilość ocen:",
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _textPopularityController,
              style: _theme.textTheme.headline6,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                hintText: 'np: 150',
              ),
              textAlign: TextAlign.center,
              onChanged: (String? value) {
                if (value != null)
                  _selectedPopularityMin = int.tryParse(value) ?? 0;
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding buildConfirmButton(ThemeData _theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          child: Text('Zastosuj'),
          style: ElevatedButton.styleFrom(
            textStyle: _theme.textTheme.headline6!
                .copyWith(color: _theme.colorScheme.onPrimary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            widget._applyFilters(
              _selectedCategories,
              _selectedMinRating,
              _selectedPopularityMin,
            );
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Widget buildRating() {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Minimalna ocena:",
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBar.builder(
                  initialRating: _selectedMinRating,
                  itemCount: 5,
                  maxRating: 5.0,
                  allowHalfRating: true,
                  itemBuilder: (_, __) => Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (double value) {
                    setState(() {
                      _selectedMinRating = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void cleanFilters() {
    setState(() {
      _categoriesMap.updateAll((key, value) => false);
      _updateCategories(_categoriesMap);
      _textPopularityController.clear();
      _selectedCategories.clear();
      _selectedMinRating = 0.0;
      _selectedPopularityMin = 0;
    });
  }

  Column buildCategories(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            "Kategorie:",
            style: Theme.of(context).textTheme.headline6,
          ),
          trailing: IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(
              _editCategory ? Icons.expand_less : Icons.expand_more,
              size: 30.0,
            ),
            onPressed: () => setState(() {
              _editCategory = !_editCategory;
            }),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _editCategory ? 16.0 : 0.0),
          child: Container(
            width: double.infinity,
            child: _editCategory
                ? Wrap(
                    spacing: 5.0,
                    children: buildChips(),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 5.0,
                      children: [
                        SizedBox(width: 16.0),
                        ...buildChips(),
                        SizedBox(width: 16.0),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  List<StatelessWidget> buildChips() {
    List<InputChip> list = [];

    _categoriesMap.forEach((key, value) {
      if (_editCategory || value) {
        list.add(
          InputChip(
            showCheckmark: true,
            selected: value,
            label: Text(key),
            onSelected: (bool newValue) {
              setState(() {
                _categoriesMap.update(key, (value) => newValue);
                _updateCategories(_categoriesMap);
              });
            },
          ),
        );
      }
    });
    return list;
  }
}
