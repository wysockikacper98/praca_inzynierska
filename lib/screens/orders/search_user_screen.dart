import 'package:flutter/material.dart';

import 'search.dart';

class SearchUserScreen extends StatefulWidget {
  static const routeName = '/search-user';

  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wyszukaj Klienta"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: Search(),
              );
            },
          ),
        ],
      ),
    );
  }
}
