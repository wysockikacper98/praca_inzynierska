import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/firm/build_firm_info.dart';

import '../../models/firm.dart';

class SearchFirms extends SearchDelegate<Firm?> {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _firms = FirebaseFirestore
      .instance
      .collection('firms')
      .orderBy('firmName')
      .limit(20)
      .snapshots();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: _firms,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Brak firm'),
          );
        }

        final result = snapshot.data!.docs.where((element) {
          return ((element['firstName'] + ' ' + element['lastName'])
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              element['firmName']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()));
        });

        return ListView(
          children: result.map((DocumentSnapshot current) {
            return buildFirmInfo(context, current);
          }).toList(),
        );
      },
    );
  }
}
