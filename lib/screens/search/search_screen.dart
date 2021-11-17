import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:praca_inzynierska/helpers/colorfull_print_messages.dart';
import 'package:praca_inzynierska/helpers/firebase_firestore.dart';
import 'package:praca_inzynierska/screens/search/filter_screen.dart';
import 'package:praca_inzynierska/widgets/firm/build_firm_info.dart';

import 'search_firms.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _allFirmList;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _filterFirmsList;

  List<String> _selectedCategories = [];

  late FilterOptions _dropdownValue;
  int _numberOfFilters = 0;

  late ScrollController _scrollController;
  bool _showBackToTopButton = false;

  List<String>? _categories;
  String? _administrativeArea;
  List<double>? _rangeMinMax;
  List<int>? _popularityMinMax;

  @override
  void initState() {
    super.initState();

    initializeFirms();

    _dropdownValue = FilterOptions.rating_best_worst;

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true; // show the back-to-top button
          } else {
            _showBackToTopButton = false; // hide the back-to-top button
          }
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> initializeFirms() async {
    printColor(text: 'initializeFirms', color: PrintColor.red);
    getFirmList().then((value) {
      _allFirmList = value.docs;
      setState(() => _filterFirmsList = _allFirmList);
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 3), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wyszukaj'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchFirms(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildFilterButton(_theme),
                buildSortDropdown(_theme),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Wyszukane firmy:',
                style: _theme.textTheme.headline5,
              ),
            ),
            SizedBox(height: 20),
            _filterFirmsList == null
                ? Center(child: Text('Brak wyników'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _filterFirmsList!.length * 4,
                    itemBuilder: (ctx, index) => buildFirmInfo(
                      ctx,
                      _filterFirmsList![index % 3],
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              child: Icon(Icons.arrow_upward),
              onPressed: _scrollToTop,
            )
          : null,
    );
  }

  Badge buildFilterButton(ThemeData _theme) {
    return Badge(
      badgeContent: Text(_numberOfFilters.toString()),
      showBadge: _numberOfFilters > 0,
      animationType: BadgeAnimationType.slide,
      child: TextButton(
          child: Text(
            'Filtry',
            style: _theme.textTheme.headline6!
                .copyWith(color: _theme.colorScheme.primary),
            // style: Theme.of(context).textTheme.subtitle1,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => FilterScreen(
                  _applyFilters,
                  _categories,
                  _administrativeArea,
                  _rangeMinMax,
                  _popularityMinMax,
                ),
              ),
            );
          }),
    );
  }

  void _applyFilters(
    List<String>? categories,
    String? administrativeArea,
    List<double>? rangeMinMax,
    List<int>? popularityMinMax,
  ) {
    bool _shouldUpdate = false;

    if (categories != null) {
      _categories = categories;
      _shouldUpdate = true;
    }
    if (administrativeArea != null) {
      _administrativeArea = administrativeArea;
      _shouldUpdate = true;
    }
    if (rangeMinMax != null) {
      _rangeMinMax = rangeMinMax;
      _shouldUpdate = true;
    }
    if (popularityMinMax != null) {
      _popularityMinMax = popularityMinMax;
      _shouldUpdate = true;
    }

    if (_shouldUpdate) {
      printColor(text: 'Should be updated', color: PrintColor.black);
    }
  }

  Widget buildSortDropdown(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: DropdownButton(
        value: _dropdownValue,
        icon: Icon(Icons.sort),
        isDense: false,
        items: [
          DropdownMenuItem(
            value: FilterOptions.rating_best_worst,
            child: Text('Ocena od największej'),
          ),
          DropdownMenuItem(
            value: FilterOptions.rating_worst_best,
            child: Text('Ocena od najmnijeszej'),
          ),
          DropdownMenuItem(
            value: FilterOptions.popularity_most_least,
            child: Text('Ilość ocen od największej'),
          ),
          DropdownMenuItem(
            value: FilterOptions.popularity_least_most,
            child: Text('Ilość ocen od najmniejszej'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _dropdownValue = enumFromString(
                  FilterOptions.values,
                  value.toString().split('.').last,
                ) ??
                FilterOptions.rating_best_worst;
          });
        },
      ),
    );
  }
}

enum FilterOptions {
  rating_best_worst,
  rating_worst_best,
  popularity_most_least,
  popularity_least_most,
}
