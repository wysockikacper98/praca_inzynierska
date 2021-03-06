import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:provider/provider.dart';

import '../../helpers/colorful_print_messages.dart';
import '../../helpers/firebase_firestore.dart';
import '../../widgets/calculate_rating.dart';
import '../../widgets/firm/build_firm_info.dart';
import '../../widgets/theme/theme_Provider.dart';
import 'filter_screen.dart';
import 'search_firms.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  final String? _defaultCategories;

  SearchScreen([this._defaultCategories]);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _allFirmList;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _filterFirmsList;

  late FilterOptions _dropdownValue;
  int _numberOfFilters = 0;

  late ScrollController _scrollController;
  bool _showBackToTopButton = false;

  late List<String> _categories;
  late double _ratingMin;
  late int _popularityMin;

  @override
  void initState() {
    super.initState();

    initializeFirms();

    _categories = [];
    _ratingMin = 0.0;
    _popularityMin = 0;

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
    getFirmList().then((value) {
      _allFirmList = value.docs;
      if (mounted) {
        setState(() => _filterFirmsList = _allFirmList);
      }
      if (widget._defaultCategories != null)
        _applyFilters([widget._defaultCategories!], 0.0, 0);
      else
        _sortFirm();
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 3), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final bool _isDarkTheme =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

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
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildFilterButton(_theme, _isDarkTheme),
                  buildSortDropdown(_theme),
                ],
              ),
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
            (_filterFirmsList == null || _filterFirmsList!.isEmpty)
                ? Center(child: Text('Brak wynik??w'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _filterFirmsList!.length,
                    itemBuilder: (ctx, index) => buildFirmInfo(
                      ctx,
                      _filterFirmsList![index],
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

  Badge buildFilterButton(ThemeData _theme, bool _isDarkTheme) {
    return Badge(
      badgeContent: Text(_numberOfFilters.toString()),
      showBadge: _numberOfFilters > 0,
      animationType: BadgeAnimationType.slide,
      child: ElevatedButton(
          child: Text(
            'Filtry',
            style: TextStyle(
              color: _isDarkTheme ? Colors.white : Colors.black,
              fontSize: 20,
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => FilterScreen(
                  _applyFilters,
                  _categories,
                  _ratingMin,
                  _popularityMin,
                ),
              ),
            );
          }),
    );
  }

  void _applyFilters(
    List<String> categories,
    double ratingMin,
    int popularityMin,
  ) {
    bool _shouldUpdate = false;
    int tempCounter = 0;

    if (categories != _categories) {
      _categories = categories;
      _shouldUpdate = true;
    }
    if (ratingMin != _ratingMin) {
      _ratingMin = ratingMin;
      _shouldUpdate = true;
    }
    if (popularityMin != _popularityMin) {
      _popularityMin = popularityMin;
      _shouldUpdate = true;
    }

    if (_shouldUpdate) {
      tempCounter += categories.length;
      tempCounter += ratingMin != 0.0 ? 1 : 0;
      tempCounter += popularityMin != 0 ? 1 : 0;

      // applying categories filter
      _filterFirmsList = categories.isNotEmpty
          ? _allFirmList?.where((element) {
              return containsAll(element.data()['category'], categories);
            }).toList()
          : _allFirmList;

      // applying min rating filter
      if (ratingMin != 0.0)
        _filterFirmsList = _filterFirmsList?.where((element) {
          return calculateRating(
                element.data()['rating'],
                element.data()['ratingNumber'],
              ) >=
              ratingMin;
        }).toList();

      // applying min popularity filter
      if (popularityMin != 0)
        _filterFirmsList = _filterFirmsList?.where((element) {
          return element.data()['ratingNumber'] >= popularityMin;
        }).toList();

      _sortFirm();

      setState(() {
        _numberOfFilters = tempCounter;
      });
      _shouldUpdate = false;
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
            child: Text('Ocena od najwi??kszej'),
          ),
          DropdownMenuItem(
            value: FilterOptions.rating_worst_best,
            child: Text('Ocena od najmnijeszej'),
          ),
          DropdownMenuItem(
            value: FilterOptions.popularity_most_least,
            child: Text('Ilo???? ocen od najwi??kszej'),
          ),
          DropdownMenuItem(
            value: FilterOptions.popularity_least_most,
            child: Text('Ilo???? ocen od najmniejszej'),
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
          _sortFirm();
        },
      ),
    );
  }

  void _sortFirm() {
    printColor(text: '_sortFirm called', color: PrintColor.black);
    if (_filterFirmsList != null && _filterFirmsList!.length > 0) {
      printColor(text: '_sortFirm run', color: PrintColor.red);

      switch (_dropdownValue) {
        case FilterOptions.rating_best_worst:
          _filterFirmsList!.sort((a, b) {
            if (calculateRating(a.data()['rating'], a.data()['ratingNumber']) >
                calculateRating(b.data()['rating'], b.data()['ratingNumber']))
              return -1;
            else if (calculateRating(
                    a.data()['rating'], a.data()['ratingNumber']) <
                calculateRating(b.data()['rating'], b.data()['ratingNumber']))
              return 1;
            else
              return 0;
          });
          break;
        case FilterOptions.rating_worst_best:
          _filterFirmsList!.sort((a, b) {
            if (calculateRating(a.data()['rating'], a.data()['ratingNumber']) >
                calculateRating(b.data()['rating'], b.data()['ratingNumber']))
              return 1;
            else if (calculateRating(
                    a.data()['rating'], a.data()['ratingNumber']) <
                calculateRating(b.data()['rating'], b.data()['ratingNumber']))
              return -1;
            else
              return 0;
          });
          break;
        case FilterOptions.popularity_most_least:
          _filterFirmsList!.sort((a, b) {
            if (a.data()['ratingNumber'] > b.data()['ratingNumber'])
              return -1;
            else if (a.data()['ratingNumber'] < b.data()['ratingNumber'])
              return 1;
            else
              return 0;
          });
          break;
        case FilterOptions.popularity_least_most:
          _filterFirmsList!.sort((a, b) {
            if (a.data()['ratingNumber'] > b.data()['ratingNumber'])
              return 1;
            else if (a.data()['ratingNumber'] < b.data()['ratingNumber'])
              return -1;
            else
              return 0;
          });
          break;
      }
    }
  }
}

enum FilterOptions {
  rating_best_worst,
  rating_worst_best,
  popularity_most_least,
  popularity_least_most,
}

// return True if every element in filter contains in Original iteralbe
bool containsAll(List<Object?> original, List<Object?> filter) {
  for (var element in filter) {
    if (!original.contains(element)) return false;
  }
  return true;
}
