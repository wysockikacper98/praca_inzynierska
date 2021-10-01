import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/search/build_firm_list_with_filter.dart';
import '../../widgets/search/filter.dart';
import 'search_firms.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFilter(context),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Wyszukane firmy:',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 20),
            buildFirmListWithFilter(),
          ],
        ),
      ),
    );
  }
}
