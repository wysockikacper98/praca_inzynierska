import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/users.dart';

class SearchUsers extends SearchDelegate<Users?> {
  final Stream<QuerySnapshot<Map<String, dynamic>>>? users;
  final void Function(DocumentSnapshot) setUser;

  SearchUsers(this.users, this.setUser);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
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
      stream: users,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('Brak użytkowników'),
          );
        }

        final result = snapshot.data!.docs.where((element) {
          return ((element['firstName'] + ' ' + element['lastName'])
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
              element['email']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()));
        });

        return ListView(
          children: result.map((DocumentSnapshot current) {
            return ListTile(
              leading: CircleAvatar(
                radius: 30,
                foregroundImage: current['avatar'] != ''
                    ? CachedNetworkImageProvider(current['avatar'])
                    : null,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              title: Text(current['firstName'] + ' ' + current['lastName']),
              subtitle: Text(current['email']),
              trailing: Text(current.id.substring(0, 5) + '...'),
              onTap: () {
                // print('User selected: ' + current.id.toString());
                setUser(current);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }
}
