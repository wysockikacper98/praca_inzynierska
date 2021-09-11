import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/firm.dart';
import 'search_users.dart';

class CreateOrderScreen extends StatefulWidget {
  static const routeName = '/search-user';

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  DocumentSnapshot _user;

  void _setUser(DocumentSnapshot user) {
    setState(() {
      _user = user;
    });
  }

  var _currentSelectedValue;

  @override
  Widget build(BuildContext context) {
    print('build -> search_user_screen');
    final provider = Provider.of<FirmProvider>(context, listen: false);

    Stream<QuerySnapshot<Map<String, dynamic>>> users = FirebaseFirestore
        .instance
        .collection('users')
        .orderBy('lastName')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Utwórz zamówienie"),
      ),
      body: Center(
        child: Column(
          children: [
            _user != null ? buildUserPreview(_user) : SizedBox(height: 16),
            buildElevatedButton(context, users),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Rodzaj usługi:"),
                DropdownButton(
                  value: _currentSelectedValue,
                  icon: Icon(
                    Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  items: provider.firm.category.map((value) {
                    return DropdownMenuItem(
                      value: value.toString(),
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    print('New value: ' + newValue);
                    setState(() {
                      _currentSelectedValue = newValue;
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

  ElevatedButton buildElevatedButton(
      BuildContext context, Stream<QuerySnapshot<Map<String, dynamic>>> users) {
    return ElevatedButton.icon(
      icon: Icon(Icons.person_search),
      label: _user != null
          ? Text("Zmień użytkownika")
          : Text("Wybierz użytkownika"),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      onPressed: () {
        showSearch(
          context: context,
          delegate: SearchUsers(users, _setUser),
        );
      },
    );
  }

  Padding buildUserPreview(DocumentSnapshot user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/user.png'),
          foregroundImage:
              user['avatar'] != '' ? NetworkImage(user['avatar']) : null,
        ),
        title: Text(user['firstName'] + ' ' + user['lastName']),
        trailing: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => setState(() {
            _user = null;
          }),
        ),
      ),
    );
  }
}
