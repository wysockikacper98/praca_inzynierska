import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/search/build_firm_list_with_filter.dart';
import 'package:praca_inzynierska/widgets/search/filter.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/search';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Wyszukaj'),
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
