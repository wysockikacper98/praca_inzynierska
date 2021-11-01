import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BuildCategories extends StatefulWidget {
  final List<String> _selectedCategoriesList;
  final List<String> _allCategories;
  final Function _makeDirty;
  final Function(Map<String, bool> categories) _updateCategories;

  BuildCategories(
    this._selectedCategoriesList,
    this._allCategories,
    this._makeDirty,
    this._updateCategories,
  );

  @override
  _BuildCategoriesState createState() => _BuildCategoriesState();
}

class _BuildCategoriesState extends State<BuildCategories> {
  bool _editCategory = false;
  late Map<String, bool> _categoriesMap;
  int _categoriesAmount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoriesAmount = widget._selectedCategoriesList.length;
    _categoriesMap = Map.fromIterable(widget._allCategories,
        key: (e) => e,
        value: (e) =>
            widget._selectedCategoriesList.contains(e) ? true : false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            "Kategorie:$_categoriesAmount",
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
              if (_editCategory && (_categoriesAmount > 1 || newValue)) {
                setState(() {
                  _categoriesMap.update(key, (value) => newValue);
                  value ? _categoriesAmount-- : _categoriesAmount++;
                  widget._updateCategories(_categoriesMap);
                  widget._makeDirty();
                });
              }
            },
          ),
        );
      }
    });

    return list;
  }
}
