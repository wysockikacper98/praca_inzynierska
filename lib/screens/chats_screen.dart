import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:praca_inzynierska/helpers/sharedPreferences.dart';

class ChatsScreen extends StatelessWidget {
  static const routeName = '/chat-screen';

  final user;
  final Key key;

  ChatsScreen({
    @required this.user,
    @required this.key,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser.uid;

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: userId)
            // .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (!chatSnapshot.hasData) {
            return Center(child: Text("Brak wiadomości tekstowych"));
          } else {
            print(chatSnapshot.toString());
            print(chatSnapshot.data.docs.length.toString());

            final chatDocs = chatSnapshot.data.docs;
            //TODO: sortowanie listy przed budowaniem
            return ListView.builder(
              itemCount: chatDocs.length,
              itemBuilder: (ctx, index) => ListTile(
                title: Text(chatDocs[index]['chatName']),
                onTap: () {
                  print(chatDocs[index].reference.id);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
