import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/screens/orders/create_order_screen.dart';
import 'package:provider/provider.dart';

import '../../widgets/message_buble.dart';
import '../../widgets/new_message.dart';

class Message extends StatelessWidget {
  final String chatID;
  final String chatName;
  final String? defaultUserID;

  Message({required this.chatID, required this.chatName, this.defaultUserID});

  @override
  Widget build(BuildContext context) {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final Users user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(title: Text(this.chatName), actions: [
        if (user.type == UserType.Firm)
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.post_add),
                  title: Text('Utwórz zamówienie'),
                  onTap: () {
                    print('$defaultUserID');
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrderScreen(defaultUserID),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      ]),
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
                builder: (ctx,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!messageSnapshot.hasData) {
                    return Center(child: Text("Brak wiadomości tekstowych"));
                  } else {
                    final messageDoc = messageSnapshot.data!.docs;

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
