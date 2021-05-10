import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/message_buble.dart';
import 'package:praca_inzynierska/widgets/new_message.dart';

class Message extends StatelessWidget {
  final String chatID;
  final String chatName;

  Message({this.chatID, this.chatName});

  @override
  Widget build(BuildContext context) {
    final userID = FirebaseAuth.instance.currentUser.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(this.chatName),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatID)
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (ctx, messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!messageSnapshot.hasData) {
                    return Center(child: Text("Brak wiadomości tekstowych"));
                  } else {
                    print("TO SĄ WIADOMOŚCI");
                    // print(messageSnapshot.data.docs['messages'].toString());
                    // print(messageSnapshot.data['messages'].docs);
                    print(messageSnapshot.data.docs.length.toString());

                    final messageDoc = messageSnapshot.data.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messageDoc.length,
                      itemBuilder: (ctx, index) => MessageBubble(
                        messageDoc[index].data()['text'],
                        messageDoc[index].data()['userName'],
                        messageDoc[index].data()['creatorID'] == userID,
                      ),
                    );
                  }
                },
              ),
            ),
            NewMessage(chatID),
          ],
        ),
      ),
    );
  }
}
