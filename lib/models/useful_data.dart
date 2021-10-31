import 'package:flutter/foundation.dart';

class UsefulData with ChangeNotifier {
  late List<String> _categoriesList;

  List<String> get categoriesList {
    return _categoriesList;
  }

  set categoriesList(List<String> value) {
    print('Categories Updated');
    _categoriesList = value;
    notifyListeners();
  }
}
