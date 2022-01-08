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
        builder: (
          ctx,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> chatSnapshot,
        ) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (chatSnapshot.data!.docs.length == 0) {
            return Center(child: Text('Brak wiadomości tekstowych'));
          } else {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> chatDocs =
                chatSnapshot.data!.docs;

            chatDocs.sort((a, b) =>
                b['updatedAt'].toDate().compareTo(a['updatedAt'].toDate()));

            final _durationToday = const Duration(days: 1);
            final _durationCurrentWeek = const Duration(days: 7);

            return ListView.builder(
                itemCount: chatDocs.length,
                itemBuilder: (ctx, index) {
                  final String currentChatName = getChatName(
                    chatDocs,
                    index,
                    userId,
                  );

                  final DateTime lastMessageDate =
                      chatDocs[index]['updatedAt'].toDate();

                  final Duration lastMessageSendDuration =
                      DateTime.now().difference(lastMessageDate);

                  final String timeToDisplay = lastMessageSendDuration <
                          _durationToday
                      ? DateFormat.Hm('pl_PL').format(lastMessageDate)
                      : lastMessageSendDuration < _durationCurrentWeek
                          ? DateFormat.E('pl_PL')
                              .add_Hm()
                              .format(lastMessageDate)
                          : DateFormat.yMMMd('pl_PL').format(lastMessageDate);

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/images/user.png'),
                      foregroundImage: userType == UserType.Firm
                          ? chatDocs[index]['userAvatar'] != ''
                              ? NetworkImage(chatDocs[index]['userAvatar'])
                              : null
                          : chatDocs[index]['firmAvatar'] != ''
                              ? NetworkImage(chatDocs[index]['firmAvatar'])
                              : null,
                    ),
                    title: Text(currentChatName),
                    subtitle: Text(
                        chatDocs[index]['latestMessage']?.toString() ?? ''),
                    trailing: Text(timeToDisplay),
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
