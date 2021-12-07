import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../helpers/colorful_print_messages.dart';
import '../../models/users.dart';
import 'messages.dart';

class ChatsScreen extends StatelessWidget {
  static const routeName = '/chat-screen';

  final Key key;

  ChatsScreen({
    required this.key,
  });

  @override
  Widget build(BuildContext context) {
    printColor(text: 'ChatsScreen', color: PrintColor.black);

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final UserType userType = Provider.of<UserProvider>(context).user!.type;

    return Scaffold(
      appBar: AppBar(
        title: Text("Wiadomości"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: userId)
            .snapshots(),
        builder: (ctx,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> chatSnapshot,) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (chatSnapshot.data!.docs.length == 0) {
            return Center(child: Text('Brak wiadomości tekstowych'));
          } else {
            print(chatSnapshot.data!.docs.length.toString());
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> chatDocs =
                chatSnapshot.data!.docs;

            chatDocs.sort((a, b) =>
                b['updatedAt'].toDate().compareTo(a['updatedAt'].toDate()));

            return ListView.builder(
                itemCount: chatDocs.length,
                itemBuilder: (ctx, index) {
                  final String currentChatName = getChatName(
                    chatDocs,
                    index,
                    userId,
                  );

                  return ListTile(
                    title: Text(currentChatName),
                    trailing: Text(
                      DateFormat.yMd('pl_PL')
                          .add_Hm()
                          .format(chatDocs[index]['updatedAt'].toDate()),
                    ),
                    onTap: () {
                      printColor(
                        text: chatDocs[index].id,
                        color: PrintColor.blue,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Message(
                            chatID: chatDocs[index].id,
                            chatName: currentChatName,
                            addresseeID: userType == UserType.Firm
                                ? chatDocs[index]['users'][0]
                                : chatDocs[index]['users'][1],
                          ),
                        ),
                      );
                    },
                  );
                });
          }
        },
      ),
    );
  }

  String getChatName(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> chatDocs,
    int index,
    String userId,
  ) {
    return chatDocs[index]['users'][0] == userId
        ? chatDocs[index]['chatName'][1]
        : chatDocs[index]['chatName'][0];
  }
}
