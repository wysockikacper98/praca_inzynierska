import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:praca_inzynierska/screens/messages.dart';

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
      appBar: AppBar(
        title: Text("Wiadomości"),
      ),
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
                trailing: Text(DateFormat('dd-MM-yyyy hh:mm')
                    .format(chatDocs[index]['updatedAt'].toDate())),
                onTap: () {
                  print(chatDocs[index].reference.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Message(
                        chatID: chatDocs[index].reference.id,
                        chatName: chatDocs[index]['chatName'],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
